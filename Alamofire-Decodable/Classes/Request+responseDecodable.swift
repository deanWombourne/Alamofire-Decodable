import Alamofire
import Decodable



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

    public func responseDecodable<T: Decodable>(completionHandler: Response<T, DecodableResponseError> -> Void) -> Self {

        let responseSerializer = ResponseSerializer<T, DecodableResponseError> { request, response, data, error in
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

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }

    public func responseDecodable<T: Decodable>(completionHandler: Response<[T], DecodableResponseError> -> Void) -> Self {

        let responseSerializer = ResponseSerializer<[T], DecodableResponseError> { request, response, data, error in
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
                        } catch {
                            // Errors on individual objects aren't an issue
                            return nil
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

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}
