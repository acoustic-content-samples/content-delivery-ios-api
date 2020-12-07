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

class DeliverySearchErrorsTests: XCTestCase {
    
    func getError(code: Int) -> DeliverySearchError? {
        let response = HTTPURLResponse(url: NSURL() as URL, statusCode: code, httpVersion: nil, headerFields: nil)
        return try? DeliverySearchError.fromResponse(httpRespose: response!, responseData: try JSONResponseFile.error.get())
    }
    
    func testCode400ReturnsBadRequest() {
        if let error = getError(code: 400), case DeliverySearchError.badRequest = error {} else {
            XCTFail("DeliverySearchError.fromResponse should convert error code to appropriate DeliverySearchError error")
        }
    }
    
    func testCode403ReturnsAccessForbidden() {
        if let error = getError(code: 403), case DeliverySearchError.accessForbidden = error {} else {
            XCTFail("DeliverySearchError.fromResponse should convert error code to appropriate DeliverySearchError error")
        }
    }
    
    func testCode404ReturnsNotFound() {
        if let error = getError(code: 404), case DeliverySearchError.notFound = error {} else {
            XCTFail("DeliverySearchError.fromResponse should convert error code to appropriate DeliverySearchError error")
        }
    }
    
    func testCode414ReturnsResponseIsTooLarge() {
        if let error = getError(code: 414), case DeliverySearchError.responseIsTooLarge = error {} else {
            XCTFail("DeliverySearchError.fromResponse should convert error code to appropriate DeliverySearchError error")
        }
    }
    
    func testCode429ReturnsTooManyRequests() {
        if let error = getError(code: 429), case DeliverySearchError.tooManyRequests = error {} else {
            XCTFail("DeliverySearchError.fromResponse should convert error code to appropriate DeliverySearchError error")
        }
    }
    
    func testCode500ReturnsInternalError() {
        if let error = getError(code: 500), case DeliverySearchError.internalError = error {} else {
            XCTFail("DeliverySearchError.fromResponse should convert error code to appropriate DeliverySearchError error")
        }
    }
    
    func testUnknownCodeReturnsUnknownError() {
        if let error = getError(code: 12345654), case DeliverySearchError.unknown = error {} else {
            XCTFail("DeliverySearchError.fromResponse should convert error code to appropriate DeliverySearchError error")
        }
    }
    
    func testAnyCodeAndUnrecognizedDataReturnsNil() {
        let response = HTTPURLResponse(url: NSURL() as URL, statusCode: 500, httpVersion: nil, headerFields: nil)
        let error = try? DeliverySearchError.fromResponse(httpRespose: response!, responseData: Data(count: 5))
        XCTAssertNil(error)
    }
}
