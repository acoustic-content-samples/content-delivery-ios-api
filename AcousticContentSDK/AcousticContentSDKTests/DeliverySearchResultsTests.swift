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

class DeliverySearchResultsTests: XCTestCase {
    
    fileprivate var sessionMock: aRequestSession!
    
    var documents: Documents<Asset>!
    
    override func setUp() {
        let config = AcousticContentSDK.Config(apiURL: AcousticTestContext.apiURL)
        sessionMock = aRequestSession()
        documents = Documents(
            config: config,
            session: sessionMock
        ).rows(10)
    }
    
    override func tearDown() {
        documents = nil
    }
    
    // MARK: - Previous page tests
    
    /// 1st page => no previous page (0th page makes no sense)
    func testPreviousPageFromFirstPageResult() {
        documents.start(0)
        documents.rows(10)
        sessionMock.numFound = 12
        documents.get { result in
            XCTAssertNil(result.error)
            XCTAssertNil(result.previousPage(), "previous page must be nil for the first page result")
        }
    }
    
    /// 2nd page => must return 1st page
    func testPreviousPageFromSecondPageResult() {
        documents.start(10)
        documents.rows(10)
        sessionMock.numFound = 12
        documents.get { result in
            XCTAssertNil(result.error)
            let previousPage = result.previousPage()
            XCTAssertNotNil(previousPage, "previous page must be present for the second page result - first")
            XCTAssert(previousPage?.requestConfig.start == 0, "previous page for the second page is first")
        }
    }

    /// 12 total - 1st page request => must return 2nd page
    func testNextPageIsPresentForTheIfThereIsMoreDocuments1() {
        documents.start(0)
        documents.rows(10)
        sessionMock.numFound = 12
        documents.get { result in
            XCTAssertNil(result.error)
            XCTAssert(result.nextPage().requestConfig.start == 10)

        }
    }

    /// 21 total - 2nd page request => must return 3rd page
    func testNextPageIsPresentForTheIfThereIsMoreDocuments2() {
        documents.start(10)
        documents.rows(10)
        sessionMock.numFound = 21
        documents.get { result in
            XCTAssertNil(result.error)
            XCTAssert(result.nextPage().requestConfig.start == 20)
        }
    }
}


private class aRequestSession: RequestSession {
    var numFound: Int!
    
    func load(request: Requestable, completion: @escaping RequestCompletion) {
        let jsonString = "{\"numFound\":\(numFound!),\"documents\":[]}"
        completion(.success(Data(jsonString.utf8), HTTPURLResponse()))
    }
}
