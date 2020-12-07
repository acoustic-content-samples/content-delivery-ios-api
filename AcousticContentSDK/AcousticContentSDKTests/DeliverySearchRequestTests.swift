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

class DeliverySearchRequestTests: XCTestCase {

    let sdkConfig = AcousticContentSDK.Config(apiURL: AcousticTestContext.apiURL)
    
    typealias DR = DeliverySearchRequest.RequestConfig
    
    func urlStr(with requestConfig: DeliverySearchRequest.RequestConfig) -> String {
        let request = DeliverySearchRequest(config: sdkConfig, requestConfig: requestConfig)
        let urlRequest = request.urlRequest
        XCTAssertNotNil(urlRequest?.url?.absoluteString)
        let url = (urlRequest?.url?.absoluteString) ?? ""
        return url
    }
    
    func testDefaultQueryShouldBeSet() {
        let url = urlStr(with: DR(classification: .category, start: nil, rows: nil, sortMap: [], searchText: nil))
        XCTAssert(url.contains("q=*:*"), "Default mandatory query *:* should be set when searchText is nil")
    }
    
    func testDefaultQueryShouldBeSetCaseTwo() {
        let url = urlStr(with: DR(classification: .category, start: nil, rows: nil, sortMap: [], searchText: ""))
        XCTAssert(url.contains("q=*:*"), "Default mandatory query *:* should be set when searchText is empty")
    }
    
    func testIfDefaultFieldListIsSet() {
        let url = urlStr(with: DR(classification: .asset, start: 30, rows: 15, sortMap: [], searchText: ""))
        XCTAssert(url.contains("fl=*"), "Default field list query fl=* should be set to get all fields")
    }
    
    func testIfDefaultSortIsSet() {
        let url = urlStr(with: DR(classification: .asset, start: 30, rows: 15, sortMap: [], searchText: ""))
        XCTAssert(url.contains("sort=lastModified%20asc"), "Default sort query field should be set when sortMap is empty")
    }
    
    func testClassificationFilterQuery() {
        let url = urlStr(with: DR(classification: .asset, start: 30, rows: 15, sortMap: [], searchText: ""))
        XCTAssert(url.contains("fq=classification:asset"), "Classification filter should be set into fq query parameter")
    }
    
    func testNoStartQueryParameter() {
        let url = urlStr(with: DR(classification: .asset, start: nil, rows: 15, sortMap: [], searchText: ""))
        XCTAssertFalse(/* not */url.contains("start=0"), "No start query parameter should appear in query if start is nil")
    }
    
    func testStartQueryParameter() {
        let url = urlStr(with: DR(classification: .asset, start: 30, rows: 15, sortMap: [], searchText: ""))
        XCTAssertTrue(url.contains("start=30"), "Start query parameter should be set to specified value")
    }
    
    func testNoRowsQueryParameter() {
        let url = urlStr(with: DR(classification: .asset, start: 5, rows: nil, sortMap: [], searchText: ""))
        XCTAssertFalse(/* not */url.contains("rows=0"), "No rows query parameter should appear in query if rows is nil")
    }
    
    func testRowsQueryParameter() {
        let url = urlStr(with: DR(classification: .asset, start: 30, rows: 15, sortMap: [], searchText: ""))
        XCTAssertTrue(url.contains("rows=15"), "Rows query parameter should be set to specified value")
    }
    
    func testSortQueryParameters() {
        let url = urlStr(with: DR(classification: .asset, start: 30, rows: 15, sortMap: [("fieldOne", true)], searchText: ""))
        XCTAssertTrue(url.contains("sort=fieldOne%20asc"), "Sort query parameter should be set to specified value")
    }
    
    func testTwoSortQueryParameters() {
        let url = urlStr(with: DR(classification: .asset, start: 30, rows: 15, sortMap: [("fieldOne", true), ("fieldTwo", false)], searchText: ""))
        XCTAssertTrue(url.contains("sort=fieldOne%20asc,fieldTwo%20desc"), "Order of several sort parameters should be retained. Parameters should be separated by comma")
    }
    
    func testFilterQueriesParameters() {
        let url = urlStr(with: DR(classification: .asset, filterQueries: ["fieldOne:valueOne"]))
        XCTAssertTrue(url.contains("fq=fieldOne:valueOne"), "Field query parameter should be added to fq query parameter")
    }
    
    func testTwoFilterQueriesParameters() {
        let url = urlStr(with: DR(classification: .asset, filterQueries: ["fieldOne:valueOne", "fieldTwo:valueTwo"]))
        XCTAssertTrue(url.contains("fq=fieldOne:valueOne") && url.contains("fq=fieldTwo:valueTwo"), "Every field query parameter should be added to own fq query parameter")
    }
    
    func testSearchTextParameter() {
        let url = urlStr(with: DR(classification: .asset, searchText: "name:Some*"))
        XCTAssertTrue(url.contains("q=name:Some*"), "Search text query parameter should be set to q query parameter")
    }
    
    func testProtectedContentURL() {
        let url = urlStr(with: DR(classification: .content, protectedContent: true))
        XCTAssertTrue(url.contains("mydelivery"), "If protected content is requested the URL should point to mydelivery")
    }
    
    func testIncludeDraftParameter() {
        let url = urlStr(with: DR(classification: .asset, includeDraft: true))
        XCTAssertTrue(url.contains("fq=status:(ready%20OR%20draft)%20OR%20draftStatus:*"), "If draft content is requested the URL should contain fl query with specified status")
    }
    
    func testIncludeRetiredParameter() {
        let url = urlStr(with: DR(classification: .asset, includeRetired: true))
        XCTAssertTrue(url.contains("fq=status:(ready%20OR%20retired)"), "If retired content is requested the URL should contain fl query with specified status")
    }
    
    func testIncludeDraftAndRetiredParameters() {
        let url = urlStr(with: DR(classification: .asset, includeDraft: true, includeRetired: true))
        XCTAssertTrue(url.contains("fq=status:(ready%20OR%20draft%20OR%20retired)%20OR%20draftStatus:*"), "If draft and retired content is requested the URL should contain fl query with specified status")
    }
    
    func testIncludeDraftPreviewSubdomain() {
        let url = urlStr(with: DR(classification: .asset, includeDraft: true))
        XCTAssertTrue(url.contains("-preview"), "If draft content is requested the URL should point to -preview subdomain")
    }
    
    func testIncludeRetiredPreviewSubdomain() {
        let url = urlStr(with: DR(classification: .asset, includeRetired: true))
        XCTAssertTrue(url.contains("-preview"), "If retired content is requested the URL should point to -preview subdomain")
    }
    
    func testRendringContextPath() {
        let url = urlStr(with: DR(classification: .content, renderingContent: true))
        XCTAssertTrue(url.contains("/delivery/v1/rendering/search"), "If complete content context is requested the URL path should point to Delivery Render API path")
    }
    
    func testRendringContextProtectedPath() {
        let url = urlStr(with: DR(classification: .content, protectedContent: true, renderingContent: true))
        XCTAssertTrue(url.contains("/mydelivery/v1/rendering/search"), "If complete content context is requested the URL path should point to Delivery Render API path")
    }
}
