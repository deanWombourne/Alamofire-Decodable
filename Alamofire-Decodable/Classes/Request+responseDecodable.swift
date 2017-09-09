import Alamofire
import protocol Decodable.Decodable
import Decodable


/**
 Errors returned from decoding the response
 */
public enum DecodableResponseError: Error {
    case network(error: Error)
    case serialization(error: Error)
    case decoding(error: Error)
}


/**
 Add a responseDecodable method to Alamofire's `DataRequest` to return already decoded objects.
 
 Also add a method which does the same to arrays of decodable, because we can't yet define in Swift that
 an array of `Decodable` is also itself `Decodable`.
 */
extension DataRequest {

    /**
     Provide a `Response<T, DecodableResponseError>` where `T` is something `Decodable`.

     - parameter completionHandler: This function is passed the `Response` after decoding is complete
     */
    @discardableResult
    public func responseDecodable<T: Decodable>(completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {

        let responseSerializer: DataResponseSerializer<T> = DataRequest.decodableResponseSerializer()

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

    /**
     Provide a `Response<[T], DecodableResponseError>` where T is something `Decodable`.
     
     If the response is not an array, then a `serialisation(TypeMismatchError)` is thrown
     
     - parameter partial: If this is true then individual items in the array which fail to be decoded into an instance of `T` are skipped. If false, then the entire response fails on the first invalid item.
     - parameter completionHandler: This function is passed the `Response` after decoding is complete
     */
    @discardableResult
    public func responseDecodable<T: Decodable>(partial: Bool = true, completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {

        let responseSerializer: DataResponseSerializer<[T]> = DataRequest.decodableResponseSerializer(partial: partial)

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

    /**
     Internal helper to make the response serializer for a `Decodable`
     */
    static func decodableResponseSerializer<T: Decodable>() -> DataResponseSerializer<T> {
        return DataResponseSerializer<T> { request, response, data, error in
            guard error == nil else {
                return .failure(DecodableResponseError.network(error: error!))
            }

            // Use Alamofire's existing JSON serializer to extract the data, passing the error as nil, as it has already been handled.
            let result = Request.serializeResponseJSON(options: .allowFragments,
                                                       response:response,
                                                       data:data,
                                                       error:nil)

            switch result {

            case .success(let value):
                do {
                    let responseObject = try T.decode(value)
                    return .success(responseObject)
                } catch let e {
                    return .failure(DecodableResponseError.serialization(error: e))
                }

            case .failure(let error):
                return .failure(DecodableResponseError.decoding(error: error))
            }
        }

    }

    /**
     Internal helper to make the response serializer for a collection of `Decodable`s
     */
    static func decodableResponseSerializer<T: Decodable>(partial: Bool) -> DataResponseSerializer<[T]> {
        return DataResponseSerializer<[T]> { request, response, data, error in
            guard error == nil else {
                return .failure(DecodableResponseError.network(error: error!))
            }

            // Use Alamofire's existing JSON serializer to extract the data, passing the error as nil, as it has already been handled.
            let result = Request.serializeResponseJSON(options: .allowFragments,
                                                       response:response,
                                                       data:data,
                                                       error:nil)

            switch result {

            case .success(let value):
                guard let values = value as? Array<AnyObject> else {
                    let metadata = DecodingError.Metadata(object: value)
                    let error = DecodingError.typeMismatch(expected: Array<AnyObject>.self, actual: type(of: value), metadata)
                    return .failure(DecodableResponseError.serialization(error: error))
                }

                do {
                    let responseObject: [T] = try values.flatMap {
                        do {
                            return try T.decode($0)
                        } catch let e {
                            // If we are allowing partial responses, just let it slide
                            if partial {
                                return nil
                            } else {
                                throw e
                            }
                        }
                    }
                    return .success(responseObject)
                } catch let e {
                    return .failure(DecodableResponseError.serialization(error: e))
                }

            case .failure(let error):
                return .failure(DecodableResponseError.decoding(error: error))
            }
        }
    }
}
