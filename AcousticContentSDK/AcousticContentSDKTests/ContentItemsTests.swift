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

class ContentItemsTests: XCTestCase {
    
    var testRequestSession = AcousticTestContext.getSessionMock(.content)
    
    var sdk: AcousticContentSDK!
    var deliverySearch: DeliverySearch!
    
    override func setUp() {
        let config = AcousticContentSDK.Config(apiURL: AcousticTestContext.apiURL)
        sdk = AcousticContentSDK(withConfig: config)
        deliverySearch = DeliverySearch(config: config, requestSession: testRequestSession)
    }
    
    override func tearDown() {
        deliverySearch = nil
    }
    
    func testNoError() {
        let expectation = XCTestExpectation()
        deliverySearch.contentItems().get() { (result) in
            XCTAssertNil(result.error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testHasDocuments() {
        let expectation = XCTestExpectation()
        deliverySearch.contentItems().get() { (result) in
            XCTAssert(result.documents.count > 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testClassificationIsContent() {
        let expectation = XCTestExpectation()
        deliverySearch.contentItems().get() { (result) in
            XCTAssert(result.documents.first?.classification == "content")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testProtectedContentFailIfLoggedOut() {
        sdk.logout({})
        let requestExpect = XCTestExpectation()
        
        sdk.deliverySearch().contentItems()
            .protectedContent()
            .get() { (result) in
                XCTAssertNil(result.documents.first)
                requestExpect.fulfill()
        }
        
        wait(for: [requestExpect], timeout: AcousticTestContext.timeout)
    }
}

class ContentItemsProtectedTests: XCTestCase {
    
    fileprivate var sdk: AcousticContentSDKConfigurable!
    
    override func setUp() {
        let config = AcousticContentSDK.Config(apiURL: AcousticTestContext.apiURL)
        sdk = AcousticContentSDKConfigurable(withConfig: config)
        sdk.mockedRequestSession = AcousticTestContext.getSessionMock(.contentProtected)
    }
    
    override func tearDown() {
        sdk = nil
    }
    
    /// Perform test login with assertions for it
    func performTestLogin() {
        if (AcousticTestContext.sessionType == .mocked) { return }
        
        let loginExpect = XCTestExpectation()
        sdk.login(username: AcousticTestContext.username, password: AcousticTestContext.password) { (success, error) in
            XCTAssertTrue(success)
            loginExpect.fulfill()
        }
        wait(for: [loginExpect], timeout: AcousticTestContext.timeout)
    }
    
    func testProtectedContentSucceedIfLoggedIn() {
        performTestLogin()
        
        let requestExpect = XCTestExpectation()
        sdk.deliverySearch().contentItems()
            .protectedContent()
            .get() { (result) in
                XCTAssertNotNil(result.documents.first)
                requestExpect.fulfill()
        }
        wait(for: [requestExpect], timeout: AcousticTestContext.timeout)
    }
    
    func testIncludeDraftSucceedIfLoggedIn() {
        performTestLogin()
        
        let requestExpect = XCTestExpectation()
        sdk.deliverySearch().assets()
            .includeDraft()
            .get() { (result) in
                XCTAssertNotNil(result.documents.first)
                requestExpect.fulfill()
        }
        wait(for: [requestExpect], timeout: AcousticTestContext.timeout)
    }
    
    func testIncludeRetiredSucceedIfLoggedIn() {
        performTestLogin()
        
        let requestExpect = XCTestExpectation()
        sdk.deliverySearch().assets()
            .includeRetired()
            .get() { (result) in
                XCTAssertNotNil(result.documents.first)
                requestExpect.fulfill()
        }
        wait(for: [requestExpect], timeout: AcousticTestContext.timeout)
    }
    
    func testGetRenderingContext() {
        let expectation = XCTestExpectation()
        sdk.deliverySearch().contentItems()
            .completeContentContext()
            .get() { (result) in
                XCTAssertNil(result.error)
                XCTAssertNotNil(result.documents.first)
                expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testGetRenderingContextProtected() {
        performTestLogin()
        
        let requestExpect = XCTestExpectation()
        sdk.deliverySearch().contentItems()
            .completeContentContext()
            .protectedContent()
            .get() { (result) in
                XCTAssertNil(result.error)
                XCTAssertNotNil(result.documents.first)
                requestExpect.fulfill()
        }
        wait(for: [requestExpect], timeout: AcousticTestContext.timeout)
    }

    func testContentFilterByNameGetter() {
        sdk.mockedRequestSession = AcousticTestContext.getSessionMock(.contentFilteredByName)
        
        let expectation = XCTestExpectation()
        sdk.deliverySearch().contentItems()
            .filterByName("North*")
            .get() { (result) in
                XCTAssertNil(result.error)
                XCTAssertTrue(result.documents.count > 0, "Test assumes that test data contains at least one `content` with `name` starting with North*")
                XCTAssertTrue(result.documents.first?.name.contains("North") ?? false)
                expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testContentFilterByIdGetter() {
        sdk.mockedRequestSession = AcousticTestContext.getSessionMock(.contentFilteredById)
        
        let expectation = XCTestExpectation()
        sdk.deliverySearch().contentItems()
            .filterById("25a94a03-407e-4f94-8ccc-ab2ec75c7899")
            .get() { (result) in
                XCTAssertNil(result.error)
                XCTAssertTrue(result.documents.count > 0, "Test assumes that test data contains at least one `content` with specified `id`")
                XCTAssertEqual(result.documents.first?.id, "25a94a03-407e-4f94-8ccc-ab2ec75c7899")
                expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testContentFilterByCategoryGetter() {
        sdk.mockedRequestSession = AcousticTestContext.getSessionMock(.contentFilteredByCategory)
        
        let expectation = XCTestExpectation()
        sdk.deliverySearch().contentItems()
            .filterByCategory("Locations/Asia/Japan")
            .get() { (result) in
                XCTAssertNil(result.error)
                XCTAssertTrue(result.documents.count > 0, "Test assumes that test data contains at least one `content` with specified `category`")
                XCTAssertEqual(result.documents.first?.categories?.first ?? "", "Locations/Asia/Japan")
                expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testContentFilterByTagsGetter() {
        sdk.mockedRequestSession = AcousticTestContext.getSessionMock(.contentFilteredByTags)
        
        let expectation = XCTestExpectation()
        sdk.deliverySearch().contentItems()
            .filterByTags(["travel site sample", "travel site original"])
            .get() { (result) in
                XCTAssertNil(result.error)
                XCTAssertTrue(result.documents.count > 0, "Test assumes that test data contains at least one `content` with specified `tags`")
                XCTAssertEqual(result.documents.first?.tags?.first ?? "", "travel site sample")
                expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testContent() {
        let data = try! JSONResponseFile.contentRawDocument.get()
        let content = try! ContentItem.fromData(data)
        XCTAssert(content.id == "11835ab0-f789-4b33-8122-52dff15f5399")
        XCTAssertNotNil(content.document)
        XCTAssert(content.classification == DocumentClassification.content.rawValue)
    }
}
