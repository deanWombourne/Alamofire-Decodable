import Alamofire
import Decodable


/**
 Errors returned from decoding the response
 */
public enum DecodableResponseError: ErrorType {
    case network(error: ErrorType)
    case serialization(error: ErrorType)
    case decoding(error: ErrorType)
}


/**
 Add a responseDecodable method to Alamo fire's `Request` to return already decoded objects.
 
 Also add a method which does the same to arrays of decodable, because we can't yet define in Swift that
 an array of `Decodable` is also itself `Decodable`.
 */
extension Request {

    /**
     Provide a `Response<T, DecodableResponseError>` where `T` is something `Decodable`.

     - parameter completionHandler: This function is passed the `Response` after decoding is complete
     */
    public func responseDecodable<T: Decodable>(completionHandler: Response<T, DecodableResponseError> -> Void) -> Self {

        let responseSerializer: ResponseSerializer<T, DecodableResponseError> = Request.makeResponseSerializer()

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

    /**
     Provide a `Response<[T], DecodableResponseError>` where T is something `Decodable`.
     
     If the response is not an array, then a `serialisation(TypeMismatchError)` is thrown
     
     - parameter partial: If this is true then individual items in the array which fail to be decoded into an instance of `T` are skipped. If false, then the entire response fails on the first invalid item.
     - parameter completionHandler: This function is passed the `Response` after decoding is complete
     */
    public func responseDecodable<T: Decodable>(partial: Bool = true, completionHandler: Response<[T], DecodableResponseError> -> Void) -> Self {

        let responseSerializer: ResponseSerializer<[T], DecodableResponseError> = Request.makeResponseSerializer(partial: partial)

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

    /**
     Internal helper to make the response serializer for a `Decodable`
     */
    static func makeResponseSerializer<T: Decodable>() -> ResponseSerializer<T, DecodableResponseError> {
        return ResponseSerializer<T, DecodableResponseError> { request, response, data, error in
            guard error == nil else {
                return .Failure(.network(error: error!))
            }

            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

            switch result {

            case .Success(let value):
                do {
                    let responseObject = try T.decode(value)
                    return .Success(responseObject)
                } catch let e {
                    return .Failure(.serialization(error: e))
                }

            case .Failure(let error):
                return .Failure(.decoding(error: error))
            }
        }

    }

    /**
     Internal helper to make the response serializer for a collection of `Decodable`s
     */
    static func makeResponseSerializer<T: Decodable>(partial partial: Bool) -> ResponseSerializer<[T], DecodableResponseError> {
        return ResponseSerializer<[T], DecodableResponseError> { request, response, data, error in
            guard error == nil else {
                return .Failure(.network(error: error!))
            }

            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

            switch result {

            case .Success(let value):
                guard let values = value as? Array<AnyObject> else {
                    let error = TypeMismatchError(expectedType: Array<AnyObject>.self, receivedType: value.dynamicType, object: value)
                    return .Failure(.serialization(error: error))
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
                    return .Success(responseObject)
                } catch let e {
                    return .Failure(.serialization(error: e))
                }

            case .Failure(let error):
                return .Failure(.decoding(error: error))
            }
        }
    }
}
