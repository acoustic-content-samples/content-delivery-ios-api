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

class DocumentsTests: XCTestCase {

    var testRequestSession = AcousticTestContext.getSessionMock(.assets)
    
    var deliverySearch: DeliverySearch!
    
    override func setUp() {
        let config = AcousticContentSDK.Config(apiURL: AcousticTestContext.apiURL)
        deliverySearch = DeliverySearch(config: config, requestSession: testRequestSession)
    }
    
    override func tearDown() {
        deliverySearch = nil
    }

    func testGetAssetsShouldReturnNewInstance() {
        let doc1 = deliverySearch.assets()
        let doc2 = deliverySearch.assets()
        
        let doc1Addr = Unmanaged.passUnretained(doc1).toOpaque().debugDescription
        let doc2Addr = Unmanaged.passUnretained(doc2).toOpaque().debugDescription
        
        XCTAssertNotEqual(doc1Addr, doc2Addr)
    }
    
    func testGetContentItemsShouldReturnNewInstance() {
        let doc1 = deliverySearch.contentItems()
        let doc2 = deliverySearch.contentItems()
        
        let doc1Addr = Unmanaged.passUnretained(doc1).toOpaque().debugDescription
        let doc2Addr = Unmanaged.passUnretained(doc2).toOpaque().debugDescription
        
        XCTAssertNotEqual(doc1Addr, doc2Addr)
    }
    
    func testIncorrectDataShouldRaiseDecodingError() {
        let config = AcousticContentSDK.Config(apiURL: AcousticTestContext.apiURL)
        let delivery = DeliverySearch(config: config, requestSession: RandomSuccessDataSessionMock())
        let documents = delivery.contentItems()
        
        let expectation = XCTestExpectation()
        
        documents.get { (result) in
            XCTAssertNotNil(result.error)
            guard let error = result.error,
                case DeliverySearchError.documentError(let docError) = error,
                case DocumentsError.decodingError = docError else {
                    XCTFail(); return
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testFailureShouldContainError() {
        let config = AcousticContentSDK.Config(apiURL: AcousticTestContext.apiURL)
        let delivery = DeliverySearch(config: config, requestSession: FailureDataSessionMock())
        let documents = delivery.contentItems()
        
        let expectation = XCTestExpectation()
        
        documents.get { (result) in
            XCTAssertNotNil(result.error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
}


