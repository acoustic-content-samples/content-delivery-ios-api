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

class LoginErrorTests: XCTestCase {

    private func response(statusCode: Int) -> HTTPURLResponse {
        return HTTPURLResponse(
            url: NSURL() as URL,
            statusCode: statusCode,
            httpVersion: "http/v1",
            headerFields: [:]
        )!
    }
    
    func testAccessForbiddenLoginError() {
        let error = LoginError.init(httpResponse: response(statusCode: 403), responseData: Data())
        guard case LoginError.accessForbidden = error else {
            XCTFail()
            return
        }
    }
    
    func testAccessPreconditionFailedForCredentialsError() {
        let error = LoginError.init(httpResponse: response(statusCode: 412), responseData: Data())
        guard case LoginError.preconditionFailedForCredentials = error else {
            XCTFail()
            return
        }
    }
    
    func testAccessTenantIsLockedError() {
        let error = LoginError.init(httpResponse: response(statusCode: 423), responseData: Data())
        guard case LoginError.tenantIsLocked = error else {
            XCTFail()
            return
        }
    }
    
    func testTooManyRequestsError() {
        let data = try! JSONResponseFile.error.get()
        let error = LoginError.init(httpResponse: response(statusCode: 429), responseData: data)
        guard case LoginError.tooManyRequests(let acousticError) = error else {
            XCTFail()
            return
        }
        XCTAssertNotNil(acousticError)
    }

    
    func testAccessDownstreamServiceNotAvailableError() {
        let error = LoginError.init(httpResponse: response(statusCode: 503), responseData: Data())
        guard case LoginError.downstreamServiceNotAvailable = error else {
            XCTFail()
            return
        }
    }
    
    func testAccessUnknownError() {
        let error = LoginError.init(httpResponse: response(statusCode: 413), responseData: Data())
        guard case LoginError.unknown = error else {
            XCTFail()
            return
        }
    }    
}
