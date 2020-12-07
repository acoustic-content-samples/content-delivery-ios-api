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

class URLRequestLoaderTests: XCTestCase {
    
    private var mockedSession: MockedUrlSession!
    private var requestLoader: URLRequestLoader!
    
    override func setUp() {
        mockedSession = MockedUrlSession()
        requestLoader = URLRequestLoader(urlSession: mockedSession)
    }
    
    override func tearDown() {
        requestLoader = nil
    }
    
    func testRequestWithEmptyURLRequest() {
        requestLoader.load(request: EmptyRequest()) { result in
            guard case URLRequestResult.failure(URLRequestLoaderError.unknown, let response) = result else {
                XCTFail()
                return
            }
            XCTAssertNil(response)
        }
    }
    
    func testNoResponseFromRequest() {
        mockedSession.nextResult = (nil, nil, nil)
        requestLoader.load(request: MockedRequest()) { result in
            guard case URLRequestResult.failure(URLRequestLoaderError.noResponse, let response) = result else {
                XCTFail()
                return
            }
            XCTAssertNil(response)
        }
    }
    
    func testErrorFromRequest() {
        let inputError: Error = NSError(domain: "test", code: 400, userInfo: [:])
        let inputResponse = HTTPURLResponse()
        mockedSession.nextResult = (nil, inputResponse, inputError)
        requestLoader.load(request: MockedRequest()) { result in
            guard case URLRequestResult.failure(let resultinError, let response) = result else {
                XCTFail()
                return
            }
            XCTAssert((resultinError as NSError) == (inputError as NSError))
            XCTAssert(response == inputResponse)
            XCTAssertNotNil(response)
        }
    }
    
    func testNoResponseDataFromRequest() {
        let inputResponse = HTTPURLResponse()
        mockedSession.nextResult = (nil, inputResponse, nil)
        requestLoader.load(request: MockedRequest()) { result in
            guard case URLRequestResult.failure(URLRequestLoaderError.noResponseData, let response) = result else {
                XCTFail()
                return
            }
            XCTAssert(response == inputResponse)
            XCTAssertNotNil(response)
        }
    }
    
    func testSuccessFromRequest() {
        let inputData = "Data".data(using: .utf8)
        let inputResponse = HTTPURLResponse()
        mockedSession.nextResult = (inputData, inputResponse, nil)
        requestLoader.load(request: MockedRequest()) { result in
            guard case URLRequestResult.success(let data, let response) = result else {
                XCTFail()
                return
            }
            XCTAssert(String(data: data, encoding: .utf8) == "Data")
            XCTAssert(response == inputResponse)
            XCTAssertNotNil(response)
        }
    }
}
