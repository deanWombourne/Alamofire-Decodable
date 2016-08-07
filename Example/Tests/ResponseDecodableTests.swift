import Foundation
import UIKit
import XCTest

import Decodable
import Alamofire

@testable import Alamofire_Decodable

private struct Model: Decodable {
    let id: Int

    static func decode(json: AnyObject) throws -> Model {
        return try Model(id: json => "id")
    }
}

class ResponseDecodableTests: XCTestCase {

    func testValidResponseShouldParse() {
        let valid = "{\"id\": 1}"

        let ser: ResponseSerializer<Model, DecodableResponseError> = Request.makeResponseSerializer()

        let request = NSURLRequest()
        let response = NSHTTPURLResponse()
        let data = valid.dataUsingEncoding(NSUTF8StringEncoding)

        let result = ser.serializeResponse(request, response, data, nil)

        switch result {
        case .Failure:
            XCTFail("Should have been valid")

        case .Success(let model):
            XCTAssertEqual(model.id, 1)
        }
    }

    func testInvalidJSONShouldNotParse() {
        let valid = "x{\"id\": 1}"

        let ser: ResponseSerializer<Model, DecodableResponseError> = Request.makeResponseSerializer()

        let request = NSURLRequest()
        let response = NSHTTPURLResponse()
        let data = valid.dataUsingEncoding(NSUTF8StringEncoding)

        let result = ser.serializeResponse(request, response, data, nil)

        switch result {
        case .Failure(.decoding):
            break

        case .Failure(let error):
            XCTFail("Unexpected error: \(error)")

        case .Success:
            XCTFail("Should not have been valid")
        }
    }

    func testValidButWrongJSONShouldNotParse() {
        let valid = "{\"id\": \"1\"}"

        let ser: ResponseSerializer<Model, DecodableResponseError> = Request.makeResponseSerializer()

        let request = NSURLRequest()
        let response = NSHTTPURLResponse()
        let data = valid.dataUsingEncoding(NSUTF8StringEncoding)

        let result = ser.serializeResponse(request, response, data, nil)

        switch result {
        case .Failure(.serialization):
            break

        case .Failure(let error):
            XCTFail("Unexpected error: \(error)")

        case .Success:
            XCTFail("Should not have been valid")
        }
    }

    func testErrorIsPassedOn() {
        let valid = "{\"id\": 1}"

        let ser: ResponseSerializer<Model, DecodableResponseError> = Request.makeResponseSerializer()

        let request = NSURLRequest()
        let response = NSHTTPURLResponse()
        let data = valid.dataUsingEncoding(NSUTF8StringEncoding)
        let error = NSError(domain: "TestErrorDomain", code: 0, userInfo: nil)

        let result = ser.serializeResponse(request, response, data, error)

        switch result {
        case .Failure(.network(let error)):
            XCTAssertEqual((error as NSError).domain, "TestErrorDomain")

        case .Failure(let error):
            XCTFail("Unexpected error: \(error)")

        case .Success:
            XCTFail("Should not have been valid")
        }
    }

    func testValidArrayIsParsed() {
        let valid = "[ {\"id\": 1}, {\"id\": 2}, {\"id\": 3} ]"

        let ser: ResponseSerializer<[Model], DecodableResponseError> = Request.makeResponseSerializer(partial: false)

        let request = NSURLRequest()
        let response = NSHTTPURLResponse()
        let data = valid.dataUsingEncoding(NSUTF8StringEncoding)

        let result = ser.serializeResponse(request, response, data, nil)

        switch result {

        case .Success(let models):
            XCTAssertEqual(models.count, 3)
            XCTAssertEqual(models[0].id, 1)
            XCTAssertEqual(models[1].id, 2)
            XCTAssertEqual(models[2].id, 3)

        case .Failure(let error):
            XCTFail("Should have been valid. \(error)")
        }
    }

    func testInvalidItemStopsParseWhenPartialIsFalse() {
        let valid = "[ {\"id\": 1}, {\"id\": \"2\"}, {\"id\": 3} ]"

        let ser: ResponseSerializer<[Model], DecodableResponseError> = Request.makeResponseSerializer(partial: false)

        let request = NSURLRequest()
        let response = NSHTTPURLResponse()
        let data = valid.dataUsingEncoding(NSUTF8StringEncoding)

        let result = ser.serializeResponse(request, response, data, nil)

        switch result {

        case .Failure:
            break

        case .Success:
            XCTFail("Should not have been valid")
        }
    }

    func testInvalidItemIsSkippedParseWhenPartialIsTrue() {
        let valid = "[ {\"id\": 1}, {\"id\": \"2\"}, {\"id\": 3} ]"

        let ser: ResponseSerializer<[Model], DecodableResponseError> = Request.makeResponseSerializer(partial: true)

        let request = NSURLRequest()
        let response = NSHTTPURLResponse()
        let data = valid.dataUsingEncoding(NSUTF8StringEncoding)

        let result = ser.serializeResponse(request, response, data, nil)

        switch result {

        case .Success(let models):
            XCTAssertEqual(models.count, 2)
            XCTAssertEqual(models[0].id, 1)
            XCTAssertEqual(models[1].id, 3)

        case .Failure:
            XCTFail("Should have been valid")
        }
    }

}
