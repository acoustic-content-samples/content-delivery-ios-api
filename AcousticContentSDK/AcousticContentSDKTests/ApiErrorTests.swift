//
// Copyright 2020 Acoustic, L.P.
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//

import XCTest
@testable import AcousticContentSDK

class ApiErrorTests: XCTestCase {
    
    func testCreateApiErrorFromData() {
        let data = try! JSONResponseFile.error.get()
        let apiError = try! ApiError.fromData(data)
        XCTAssert(apiError.errors[0].message == "The query contains an undefined field.")
    }
    
    func testCreateApiErrorWithWrongData() {
        let data = "not a json really".data(using: .utf8)!
        do {
            let _ = try ApiError.fromData(data)
            XCTFail()
        } catch { }
    }
    
    func testCreateApiErrorWithWrongJson() {
        let data = "{\"someKey\": 1}".data(using: .utf8)!
        do {
            let _ = try ApiError.fromData(data)
            XCTFail()
        } catch {
            guard case AnyResponseError.decodingError = error else {
                XCTFail()
                return
            }
        }
    }
    
    func testCreateApiErrorWithWrongInnerErrorFormat() {
        let jsonData = """
        {
          "requestId" : "ff669c9231b538aa3c4897a0a907d5b6",
          "service" : "prod-search-service",
          "errors" : [ {
            "message" : "The query contains an undefined field.",
            "code" : 1026,
            "description" : "The search service could not process the query, because it contains a field name that is not defined for the search collection. To solve the issue, make sure the query contains only names of fields that are defined in the search collection schema. Refer to the service API specification for information on available fields.",
            "level" : "ERROR",
            "locale" : "en"
          } ]
        }
        """.data(using: .utf8)!
        do {
            let _ = try ApiError.fromData(jsonData)
        } catch {
            guard case AnyResponseError.decodingError = error else {
                XCTFail()
                return
            }
        }
    }
    
    func testCreateAcousticContentErrorWithWrongFormat() {
        let jsonData = """
              {
                "message": "The query contains an undefined field.",
                "code": 1026,
                "description": "The search service could not process the query, because it contains a field name that is not defined for the search collection. To solve the issue, make sure the query contains only names of fields that are defined in the search collection schema. Refer to the service API specification for information on available fields.",
                "level": "ERROR",
                "locale": "en"
              }
            """.data(using: .utf8)!
        do {
            let _ = try AcousticContentError.fromData(jsonData)
        } catch {
            guard case AnyResponseError.decodingError = error else {
                XCTFail()
                return
            }
        }
    }
    
    func testCorruptedDataErrorInAssets() {
        let config = AcousticContentSDK.Config(apiURL: AcousticTestContext.apiURL)
        let sdk = AcousticContentSDKConfigurable(withConfig: config)
        let session = MockedUrlSession()
        sdk.mockedRequestSession = URLRequestLoader(urlSession: session)
        let documents = sdk.deliverySearch().assets()
        let data = try! JSONResponseFile.error.get()
        session.nextResult = (data, HTTPURLResponse(), nil)
        let expectation = XCTestExpectation()
        documents.get() { result in
            guard let outputError = result.error,
                case DeliverySearchError.unknown(let apiError) = outputError else {
                XCTFail()
                return
            }
            XCTAssertNotNil(apiError)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
}
