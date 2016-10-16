import Foundation
import UIKit
import XCTest

import Decodable
import Alamofire

@testable import Alamofire_Decodable

private struct Model: Decodable {
    let id: Int

    static func decode(_ json: Any) throws -> Model {
        return try Model(id: json => "id")

    }
}

class ResponseDecodableTests: XCTestCase {

    func testValidResponseShouldParse() {
        let valid = "{\"id\": 1}"

        let ser: DataResponseSerializer<Model> = DataRequest.decodableResponseSerializer()

        let request = URLRequest(url: URL(string: "www.example.com")!)
        let response = HTTPURLResponse()
        let data = valid.data(using: String.Encoding.utf8)

        let result = ser.serializeResponse(request, response, data, nil)

        switch result {
        case .failure:
            XCTFail("Should have been valid")

        case .success(let model):
            XCTAssertEqual(model.id, 1)
        }
    }

    func testInvalidJSONShouldNotParse() {
        let valid = "x{\"id\": 1}"

        let ser: DataResponseSerializer<Model> = DataRequest.decodableResponseSerializer()

        let request = URLRequest(url: URL(string: "www.example.com")!)
        let response = HTTPURLResponse()
        let data = valid.data(using: String.Encoding.utf8)

        let result = ser.serializeResponse(request, response, data, nil)

        switch result {
        case .failure(DecodableResponseError.decoding):
            break

        case .failure(let error):
            XCTFail("Unexpected error: \(error)")

        case .success:
            XCTFail("Should not have been valid")
        }
    }

    func testValidButWrongJSONShouldNotParse() {
        let valid = "{\"id\": \"1\"}"

        let ser: DataResponseSerializer<Model> = DataRequest.decodableResponseSerializer()

        let request = URLRequest(url: URL(string: "www.example.com")!)
        let response = HTTPURLResponse()
        let data = valid.data(using: String.Encoding.utf8)
        
        let result = ser.serializeResponse(request, response, data, nil)

        switch result {
        case .failure(DecodableResponseError.serialization):
            break

        case .failure(let error):
            XCTFail("Unexpected error: \(error)")

        case .success:
            XCTFail("Should not have been valid")
        }
    }

    func testErrorIsPassedOn() {
        let valid = "{\"id\": 1}"

        let ser: DataResponseSerializer<Model> = DataRequest.decodableResponseSerializer()

        let request = URLRequest(url: URL(string: "www.example.com")!)
        let response = HTTPURLResponse()
        let data = valid.data(using: String.Encoding.utf8)
        let error = NSError(domain: "TestErrorDomain", code: 0, userInfo: nil)

        let result = ser.serializeResponse(request, response, data, error)

        switch result {
        case .failure(DecodableResponseError.network(let error)):
            XCTAssertEqual((error as NSError).domain, "TestErrorDomain")

        case .failure(let error):
            XCTFail("Unexpected error: \(error)")

        case .success:
            XCTFail("Should not have been valid")
        }
    }

    func testValidArrayIsParsed() {
        let valid = "[ {\"id\": 1}, {\"id\": 2}, {\"id\": 3} ]"

        let ser: DataResponseSerializer<[Model]> = DataRequest.decodableResponseSerializer(partial: false)

        let request = URLRequest(url: URL(string: "www.example.com")!)
        let response = HTTPURLResponse()
        let data = valid.data(using: String.Encoding.utf8)

        let result = ser.serializeResponse(request, response, data, nil)

        switch result {

        case .success(let models):
            XCTAssertEqual(models.count, 3)
            XCTAssertEqual(models[0].id, 1)
            XCTAssertEqual(models[1].id, 2)
            XCTAssertEqual(models[2].id, 3)

        case .failure(let error):
            XCTFail("Should have been valid. \(error)")
        }
    }

    func testInvalidItemStopsParseWhenPartialIsFalse() {
        let valid = "[ {\"id\": 1}, {\"id\": \"2\"}, {\"id\": 3} ]"

        let ser: DataResponseSerializer<[Model]> = DataRequest.decodableResponseSerializer(partial: false)

        let request = URLRequest(url: URL(string: "www.example.com")!)
        let response = HTTPURLResponse()
        let data = valid.data(using: String.Encoding.utf8)

        let result = ser.serializeResponse(request, response, data, nil)

        switch result {

        case .failure:
            break

        case .success:
            XCTFail("Should not have been valid")
        }
    }

    func testInvalidItemIsSkippedParseWhenPartialIsTrue() {
        let valid = "[ {\"id\": 1}, {\"id\": \"2\"}, {\"id\": 3} ]"

        let ser: DataResponseSerializer<[Model]> = DataRequest.decodableResponseSerializer(partial: true)

        let request = URLRequest(url: URL(string: "www.example.com")!)
        let response = HTTPURLResponse()
        let data = valid.data(using: String.Encoding.utf8)

        let result = ser.serializeResponse(request, response, data, nil)

        switch result {

        case .success(let models):
            XCTAssertEqual(models.count, 2)
            XCTAssertEqual(models[0].id, 1)
            XCTAssertEqual(models[1].id, 3)

        case .failure:
            XCTFail("Should have been valid")
        }
    }

}
