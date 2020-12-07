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

class AnyDocumentsTests: XCTestCase {
    
    var testRequestSession = AcousticTestContext.getSessionMock(.nameSearch)
    
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
        deliverySearch.anyDocuments().get() { (result) in
            XCTAssertNil(result.error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testHasDocuments() {
        let expectation = XCTestExpectation()
        deliverySearch.anyDocuments().get() { (result) in
            XCTAssert(result.documents.count > 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testMixedSearchContainsDocuments() {
        let testRequestSession = AcousticTestContext.getSessionMock(.nameSearchMixedDocuments)
        let config = AcousticContentSDK.Config(apiURL: AcousticTestContext.apiURL)
        deliverySearch = DeliverySearch(config: config, requestSession: testRequestSession)
        let expectation = XCTestExpectation()
        deliverySearch.anyDocuments().get() { (result) in
            for document in result.documents {
                switch document {
                case .asset(let asset):
                    XCTAssertNotNil(asset.document)
                case .category(let category):
                    XCTAssertNotNil(category.document)
                case .content(let content):
                    XCTAssertNotNil(content.document)
                case .contentType(let contentType):
                    XCTAssertNotNil(contentType.document)
                case .raw(let rawDoc):
                    XCTAssertNotNil(rawDoc.content)
                }
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testMixedSearchContainsExactNumberOfDocuments() {
        let urlSession = MockedUrlSession()
        let testRequestSession = URLRequestLoader(urlSession: urlSession)
        let data = try! JSONResponseFile.nameSearchMixedDocuments.get()
        urlSession.nextResult = (data, HTTPURLResponse(), nil)
        let config = AcousticContentSDK.Config(apiURL: AcousticTestContext.apiURL)
        deliverySearch = DeliverySearch(config: config, requestSession: testRequestSession)
        let expectation = XCTestExpectation()
        deliverySearch.anyDocuments().get() { (result) in
            XCTAssert(result.numFound == 5)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
}
