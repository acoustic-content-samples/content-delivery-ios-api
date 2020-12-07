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

class DocumentsConfigurableTests: XCTestCase {

    var testRequestSession = AcousticTestContext.getSessionMock(.assets)
    
    var deliverySearch: DeliverySearch!
    
    override func setUp() {
        let config = AcousticContentSDK.Config(apiURL: AcousticTestContext.apiURL)
        deliverySearch = DeliverySearch(config: config, requestSession: testRequestSession)
    }
    
    override func tearDown() {
        deliverySearch = nil
    }

    func testCheckDefaultStartIsNil() {
        let documents = deliverySearch.assets()
        XCTAssertEqual(documents.requestConfig.start, nil)
    }
    
    func testSetDefaultStart() {
        let documents = deliverySearch.assets()
        documents.start()
        XCTAssertEqual(documents.requestConfig.start, 0)
    }

    func testSetStart() {
        let documents = deliverySearch.assets()
        documents.start(15)
        XCTAssertEqual(documents.requestConfig.start, 15)
    }
    
    func testDefaultPageSizeIsNil() {
        let documents = deliverySearch.assets()
        XCTAssertEqual(documents.requestConfig.rows, nil)
    }
    
    func testSetPageSize() {
        let documents = deliverySearch.assets()
        documents.rows(23)
        XCTAssertEqual(documents.requestConfig.rows, 23)
    }
    
    func testSetSingleSortBy() {
        let documents = deliverySearch.assets()
        documents.sortBy("fieldOne", ascending: false)
        XCTAssertEqual(documents.requestConfig.sortMap.count, 1)
        XCTAssertEqual(documents.requestConfig.sortMap.first?.0, "fieldOne")
        XCTAssertEqual(documents.requestConfig.sortMap.first?.1, false)
    }
    
    func testSetSeveralSortBy() {
        let documents = deliverySearch.assets()
        documents
            .sortBy("fieldOne", ascending: false)
            .sortBy("fieldTwo", ascending: false)
            .sortBy("fieldThree")
        XCTAssertEqual(documents.requestConfig.sortMap.count, 3)
        XCTAssertEqual(documents.requestConfig.sortMap[0].0, "fieldOne")
        XCTAssertEqual(documents.requestConfig.sortMap[1].0, "fieldTwo")
        XCTAssertEqual(documents.requestConfig.sortMap[2].0, "fieldThree")
    }
    
    func testCheckDefaultSortOrderingValue() {
        let documents = deliverySearch.assets()
        documents.sortBy("Some")
        XCTAssertEqual(documents.requestConfig.sortMap[0].1, true)
    }
    
    func testCheckSortByDoesNotContainDuplicates() {
        let documents = deliverySearch.assets()
        documents
            .sortBy("fieldOne", ascending: true)
            .sortBy("fieldTwo", ascending: true)
            .sortBy("fieldTwo", ascending: false)
            .sortBy("fieldOne", ascending: false)
        XCTAssertEqual(documents.requestConfig.sortMap.count, 2)
        XCTAssertEqual(documents.requestConfig.sortMap[0].0, "fieldTwo")
        XCTAssertEqual(documents.requestConfig.sortMap[1].0, "fieldOne")
        XCTAssertEqual(documents.requestConfig.sortMap[0].1, false)
        XCTAssertEqual(documents.requestConfig.sortMap[1].1, false)
    }
    
    func testSetFilterBy() {
        let documents = deliverySearch.assets()
        documents.filterBy([
            "fieldOne": "valueOne",
            "fieldTwo": "valueTwo"
        ])
        XCTAssertEqual(documents.requestConfig.filterQueries.count, 2)
        XCTAssert(documents.requestConfig.filterQueries.contains("fieldOne:valueOne"))
        XCTAssert(documents.requestConfig.filterQueries.contains("fieldTwo:valueTwo"))
    }
    
    func testNextFilterBySouldAddNewKeys() {
        let documents = deliverySearch.assets()
        documents.filterBy([
            "fieldOne": "valueOne",
            "fieldTwo": "valueTwo"
        ]).filterBy([
            "fieldThree": "valueThree"
        ])
        XCTAssertEqual(documents.requestConfig.filterQueries.count, 3)
        XCTAssert(documents.requestConfig.filterQueries.contains("fieldOne:valueOne"))
        XCTAssert(documents.requestConfig.filterQueries.contains("fieldTwo:valueTwo"))
        XCTAssert(documents.requestConfig.filterQueries.contains("fieldThree:valueThree"))
    }
    
    func testSearchText() {
        let documents = deliverySearch.assets()
        documents.searchText("some text to search for")
        XCTAssertEqual(documents.requestConfig.searchText, "some text to search for")
    }
    
    func testNextSearchTextCallShouldReplacePreviousValue() {
        let documents = deliverySearch.assets()
        documents
            .searchText("some text to search for")
            .searchText("replaced text")
        XCTAssertEqual(documents.requestConfig.searchText, "replaced text")
    }
    
    func testSingleFilterQuery() {
        let documents = deliverySearch.assets()
        documents.filterQuery("some query to filter with")
        XCTAssertEqual(documents.requestConfig.filterQueries.count, 1)
        XCTAssertEqual(documents.requestConfig.filterQueries.first, "some query to filter with")
    }
    
    func testSeveralFilterQueries() {
        let documents = deliverySearch.assets()
        documents.filterQuery("filter query one")
        documents.filterQuery("filter query two")
        documents.filterQuery("filter query three")
        XCTAssertEqual(documents.requestConfig.filterQueries.count, 3)
        XCTAssertEqual(documents.requestConfig.filterQueries[0], "filter query one")
        XCTAssertEqual(documents.requestConfig.filterQueries[1], "filter query two")
        XCTAssertEqual(documents.requestConfig.filterQueries[2], "filter query three")
    }
    
    func testDefaultProtectedItemsIsFalse() {
        let contentItems = deliverySearch.contentItems()
        XCTAssertEqual(contentItems.requestConfig.protectedContent, false)
    }
    
    func testSetProtectedItemsRequest() {
        let contentItems = deliverySearch.contentItems()
        contentItems.protectedContent()
        XCTAssertEqual(contentItems.requestConfig.protectedContent, true)
    }
    
    func testDefaultIncludeDraftIsFalse() {
        let contentItems = deliverySearch.assets()
        XCTAssertEqual(contentItems.requestConfig.includeDraft, false)
    }
    
    func testSetIncludeDraftRequest() {
        let contentItems = deliverySearch.contentItems()
        contentItems.includeDraft()
        XCTAssertEqual(contentItems.requestConfig.includeDraft, true)
    }
    
    func testDefaultIncludeRetiredIsFalse() {
        let contentItems = deliverySearch.assets()
        XCTAssertEqual(contentItems.requestConfig.includeRetired, false)
    }
    
    func testSetIncludeRetiredRequest() {
        let contentItems = deliverySearch.contentItems()
        contentItems.includeRetired()
        XCTAssertEqual(contentItems.requestConfig.includeRetired, true)
    }
    
    func testDefaultRenderingContextIsFalse() {
        let contentItems = deliverySearch.contentItems()
        XCTAssertFalse(contentItems.requestConfig.renderingContent)
    }
    
    func testSetRenderingContextRequest() {
        let contentItems = deliverySearch.contentItems()
        contentItems.completeContentContext()
        XCTAssertTrue(contentItems.requestConfig.renderingContent)
    }
    
    func testContentCustomNameGetter() {
        let contentItems = deliverySearch.contentItems().filterByName("Safari*")
        XCTAssertEqual(contentItems.requestConfig.filterQueries.first, "name:Safari*")
    }
    
    func testContentCustomTagsGetter() {
        let contentItems = deliverySearch.contentItems().filterByTags(["tagOne", "tagTwo", "Tag Three"])
        XCTAssertEqual(contentItems.requestConfig.filterQueries.first, "tags:(\"tagOne\" OR \"tagTwo\" OR \"Tag Three\")")
    }
    
    func testContentCustomIdGetter() {
        let contentItems = deliverySearch.contentItems().filterById("some-id")
        XCTAssertEqual(contentItems.requestConfig.filterQueries.first, "id:some-id")
    }
    
    func testContentCustomCategoryGetter() {
        let contentItems = deliverySearch.contentItems().filterByCategory("some-category")
        XCTAssertEqual(contentItems.requestConfig.filterQueries.first, "categories:(+\"some-category\")")
    }
}
