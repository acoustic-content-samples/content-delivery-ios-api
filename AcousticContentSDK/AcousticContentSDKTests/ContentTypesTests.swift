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

class ContentTypesTests: XCTestCase {
    
    var testRequestSession = AcousticTestContext.getSessionMock(.contentType)
    
    var deliverySearch: DeliverySearch!
    
    override func setUp() {
        let config = AcousticContentSDK.Config(apiURL: AcousticTestContext.apiURL)
        deliverySearch = DeliverySearch(config: config, requestSession: testRequestSession)
    }
    
    override func tearDown() {
        deliverySearch = nil
    }
    
    func testNoError() {
        let expectation = XCTestExpectation()
        deliverySearch.contentTypes().get() { (result) in
            XCTAssertNil(result.error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testHasDocuments() {
        let expectation = XCTestExpectation()
        deliverySearch.contentTypes().get() { (result) in
            XCTAssert(result.documents.count > 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testClassificationIsContentType() {
        let expectation = XCTestExpectation()
        deliverySearch.contentTypes().get() { (result) in
            XCTAssert(result.documents.first?.classification == "content-type")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
}
