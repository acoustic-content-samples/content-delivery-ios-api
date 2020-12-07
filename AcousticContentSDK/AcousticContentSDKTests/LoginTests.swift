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

class LoginTests: XCTestCase {
    
    let username = AcousticTestContext.username
    let password = AcousticTestContext.password
    
    var url: URL!
    var config: AcousticContentSDK.Config!
    var sdk: AcousticContentSDKConfigurable!
    
    override func setUp() {
        config = AcousticContentSDK.Config(apiURL: AcousticTestContext.apiURL)
        sdk = AcousticContentSDKConfigurable.init(withConfig: config)
    }
    
    func testLoginWithCorrectCredentials() {
        let expectation = XCTestExpectation()
        let testRequestSession = AcousticTestContext.getSessionMock(.login_success)
        if let mocked = testRequestSession as? JSONFileSessionMock {
            mocked.httpResponse = HTTPURLResponse(
                url: URL(string: "https://subdomain-6.domain")!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: [
                    "Set-Cookie":"x-ibm-dx-tenant-id=tenant_id; Path=/api; Secure; HttpOnly, x-ibm-dx-user-auth=auth_token; Expires=Sun, 15 Mar 2020 12:26:51 GMT; Path=/api; Secure; HttpOnly"
                ]
                )!
        }
        sdk.mockedRequestSession = testRequestSession
        sdk.login(
            username: username,
            password: password) { response, error in
                XCTAssertNotNil(response)
                expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testLoginWithWrongCredentials() {
        let expectation = XCTestExpectation()
        let testRequestSession = AcousticTestContext.getSessionMock(.login_error_credentials)
        if let mocked = testRequestSession as? JSONFileSessionMock {
            mocked.httpResponse = HTTPURLResponse(
                url: URL(string: "https://subdomain-6.domain")!,
                statusCode: 401,
                httpVersion: "HTTP/1.1",
                headerFields: [:]
                )!
        }
        
        sdk.mockedRequestSession = testRequestSession
        sdk.login(
            username: "blah-blah@someinc.com",
            password: "qwerty-12345-ASDFG") { success, error in
                XCTAssert(success == false)
                XCTAssertNotNil(error)
                XCTAssertEqual(LoginError.authenticationFailedWithCredentials.localizedDescription, error?.localizedDescription)
                expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testLoginWithUnknownTenant() {
        let url = URL(string: "https://my6.content-cms.com/api/unknown-tenant-id")!
        let config = AcousticContentSDK.Config(apiURL: url)
        sdk = AcousticContentSDKConfigurable.init(withConfig: config)
        let testRequestSession = AcousticTestContext.getSessionMock(.login_error_tenant)
        if let mocked = testRequestSession as? JSONFileSessionMock {
            mocked.httpResponse = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: [:])!
        }
        sdk.mockedRequestSession = testRequestSession
        let expectation = XCTestExpectation()
        sdk.login(
            username: "name",
            password: "pass") { success, error in
                XCTAssert(success == false)
                XCTAssertNotNil(error)
                expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testIsAuthorizedWithoutLoggedInConfig() {
        let expectation = XCTestExpectation()
        let testRequestSession = AcousticTestContext.getSessionMock(.login_success)
        if let mocked = testRequestSession as? JSONFileSessionMock {
            mocked.httpResponse = HTTPURLResponse(
                url: URL(string: "https://subdomain-6.domain")!,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: [
                    "Set-Cookie":"x-ibm-dx-tenant-id=tenant_id; Path=/api; Secure; HttpOnly, x-ibm-dx-user-auth=auth_token; Expires=Sun, 15 Mar 2020 12:26:51 GMT; Path=/api; Secure; HttpOnly"
                ]
                )!
        }
        sdk.mockedRequestSession = testRequestSession
        sdk.login(
            username: username,
            password: password) { _, _ in
                XCTAssert(self.sdk.isAuthorized)
                expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testIsAuthorizedWithLoggedInConfig() {
        XCTAssert(sdk.isAuthorized == false)
    }
    
    func testNoTokenInResponseInLogin() {
        let expectation = XCTestExpectation()
        let urlSession = MockedUrlSession()
        let data = try! JSONResponseFile.login_success.get()
        let response = HTTPURLResponse(
            url: URL(string: "https://subdomain-6.domain")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: [:]
        )!
        urlSession.nextResult = (data, response, nil)
        sdk.mockedRequestSession = URLRequestLoader(urlSession: urlSession)
        sdk.login(
            username: username,
            password: password) { success, loginError in
                XCTAssert(success == false)
                guard let error = loginError,
                    case LoginError.unknown = error else {
                        XCTFail()
                        return
                }
                expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
    
    func testLoginReuqeustFailed() {
        let expectation = XCTestExpectation()

        let config = AcousticContentSDK.Config(apiURL: AcousticTestContext.apiURL)
        let sdk = AcousticContentSDKConfigurable(withConfig: config)
        let session = MockedUrlSession()
        sdk.mockedRequestSession = URLRequestLoader(urlSession: session)
        session.nextResult = (nil, HTTPURLResponse(), NSError(domain: "", code: 0, userInfo: [:]))
        
        sdk.login(
            username: username,
            password: password) { success, loginError in
                XCTAssert(success == false)
                guard let error = loginError,
                    case LoginError.unknown = error else {
                        XCTFail()
                        return
                }
                expectation.fulfill()
        }
        wait(for: [expectation], timeout: AcousticTestContext.timeout)
    }
}
