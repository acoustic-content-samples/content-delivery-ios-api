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

class SolrQueryTests: XCTestCase {

    func testAddQueryParameter() {
        let query = Solr.Query()
        let item = Solr.QueryItem.start(1)
        query.add(queryItem: item)
        XCTAssertEqual(query.queryItems.count, 1)
    }
    
    func testQueryStart() {
        let query = Solr.Query()
        let start = Solr.QueryItem.start(1)
        query.add(queryItem: start)
        XCTAssertEqual(query.queryParameters(), "start=1")
    }

    func testQueryRows() {
        let query = Solr.Query()
        let rows = Solr.QueryItem.rows(5)
        query.add(queryItem: rows)
        XCTAssertEqual(query.queryParameters(), "rows=5")
    }
    
    func testStartAndRowsQuery() {
        let query = Solr.Query()
        let rows = Solr.QueryItem.rows(5)
        let start = Solr.QueryItem.start(1)
        query.add(queryItem: rows)
        query.add(queryItem: start)
        XCTAssertEqual(query.queryParameters(), "rows=5&start=1")
    }
    
    func testQueryFilterItemWithValue() {
        let query = Solr.Query()
        let filter = Solr.FilterItem(field: "fieldOne", value: "valueOne")
        let item = Solr.QueryItem.q_filter([filter])
        query.add(queryItem: item)
        XCTAssertEqual(query.queryParameters(), "q=fieldOne:valueOne")
    }
    
    func testQueryFilterItemWithoutValue() {
        let query = Solr.Query()
        let filter = Solr.FilterItem(field: "fieldOne", value: nil)
        let item = Solr.QueryItem.q_filter([filter])
        query.add(queryItem: item)
        XCTAssertEqual(query.queryParameters(), "q=fieldOne")
    }
    
    func testQueryWithTwoFilterItems() {
        let query = Solr.Query()
        let filterOne = Solr.FilterItem(field: "fieldOne", value: "valueOne")
        let filterTwo = Solr.FilterItem(field: "fieldTwo", value: "valueTwo")
        let item = Solr.QueryItem.q_filter([filterOne, filterTwo])
        query.add(queryItem: item)
        XCTAssertEqual(query.queryParameters(), "q=fieldOne:valueOne AND fieldTwo:valueTwo")
    }
    
    func testSortQueryWithOneItem() {
        let query = Solr.Query()
        let sort = Solr.SortItem(field: "sortOne", direction: .asc)
        let item = Solr.QueryItem.sort([sort])
        query.add(queryItem: item)
        XCTAssertEqual(query.queryParameters(), "sort=sortOne asc")
    }
    
    func testSortQueryWithTwoItems() {
        let query = Solr.Query()
        let sortOne = Solr.SortItem(field: "sortOne", direction: .asc)
        let sortTwo = Solr.SortItem(field: "sortTwo", direction: .desc)
        let item = Solr.QueryItem.sort([sortOne, sortTwo])
        query.add(queryItem: item)
        XCTAssertEqual(query.queryParameters(), "sort=sortOne asc,sortTwo desc")
    }
    
    func testFilterQueryItem() {
        let query = Solr.Query()
        let item = Solr.QueryItem.fq("classification:asset")
        query.add(queryItem: item)
        XCTAssertEqual(query.queryParameters(), "fq=classification:asset")
    }
    
    func testComplicatedQuery() {
        let query = Solr.Query()
        let start = Solr.QueryItem.start(45)
        let rows = Solr.QueryItem.rows(15)
        let filterOne = Solr.FilterItem(field: "fieldOne", value: "valueOne")
        let filterTwo = Solr.FilterItem(field: "fieldTwo", value: "valueTwo")
        let filter = Solr.QueryItem.q_filter([filterOne, filterTwo])
        let sortOne = Solr.SortItem(field: "sortOne", direction: .asc)
        let sortTwo = Solr.SortItem(field: "sortTwo", direction: .desc)
        let sort = Solr.QueryItem.sort([sortOne, sortTwo])
        let fq = Solr.QueryItem.fq("classification:asset")
        
        query.add(queryItems: [start,rows,filter,sort,fq])
        XCTAssertEqual(query.queryParameters(), "start=45&rows=15&q=fieldOne:valueOne AND fieldTwo:valueTwo&sort=sortOne asc,sortTwo desc&fq=classification:asset")
    }
    
    func testCreateRealSampleRequest() {
        let query = Solr.Query()
        let start = Solr.QueryItem.start(3)
        let rows = Solr.QueryItem.rows(2)
        let filterOne = Solr.FilterItem(field: "name", value: "De*")
        let filter = Solr.QueryItem.q_filter([filterOne])
        let sortOne = Solr.SortItem(field: "created", direction: .desc)
        let sort = Solr.QueryItem.sort([sortOne])
        let fq = Solr.QueryItem.fq("classification:asset")
        
        query.add(queryItems: [start,rows,filter,sort,fq])
        XCTAssertEqual(query.queryParameters(), "start=3&rows=2&q=name:De\\*&sort=created desc&fq=classification:asset")
    }
    
    func testCreateAnotherRealSampleRequest() {
        let query = Solr.Query()
        let filterOne = Solr.FilterItem(field: "name", value: "De*")
        let filterTwo = Solr.FilterItem(field: "id", value: "[0 TO 10]", operation: .OR)
        let filterThree = Solr.FilterItem(field: "fieldThree", value: "valueThree", operation: .AND)
        let filterFour = Solr.FilterItem(field: "fieldFour", value: "some*value")
        let filter = Solr.QueryItem.q_filter([filterOne, filterTwo, filterThree, filterFour])
        
        query.add(queryItem: filter)
        XCTAssertEqual(query.queryParameters(), "q=name:De\\* OR id:\\[0 TO 10\\] AND fieldThree:valueThree AND fieldFour:some\\*value")
    }
    
    func testEscapingTwoSymbolCharacters() {
        let escapedOne = "||".escaped
        XCTAssertEqual(escapedOne, "\\|\\|")
        let escapedTwo = "&&".escaped
        XCTAssertEqual(escapedTwo, "\\&\\&")
    }
}
