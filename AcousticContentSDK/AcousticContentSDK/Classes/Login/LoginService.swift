//
// Copyright 2020 Acoustic, L.P.
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//

import Foundation

class LoginService {

    struct Keys {
        static let xIbmDxUserAuth = "x-ibm-dx-user-auth"
        static let xIbmClientId = "x-ibm-client-id"
        static let xIbmClientSecret = "x-ibm-client-secret"
    }
    
    let config: AcousticContentSDK.Config
    let requestSession: RequestSession

    init(config: AcousticContentSDK.Config, requestSession: RequestSession) {
        self.config = config
        self.requestSession = requestSession
    }
    
    func login(username: String, password: String, completion: @escaping (LoginResponse?, LoginError?) -> Void) {
        let loginRequest = LoginRequest(username: username, password: password, config: config)
        requestSession.load(request: loginRequest) { result in
            switch result {
            case .success(let data, let response):
                switch LoginService.loginResponse(fromData: data, response: response) {
                case .success(let loginResponse):
                    completion(loginResponse ,nil)
                case .failure(let error):
                    completion(nil, error)
                }
            case .failure:
                completion(nil, LoginError.unknown)
            }
        }
    }
    
    func logout(completion: @escaping () -> Void) {
        requestSession.load(request: LogoutRequest(config: config)) { res in
            completion()
        }
        if let authorizationCookie = authorizationCookie {
            HTTPCookieStorage.shared.deleteCookie(authorizationCookie)
        }
    }
}


struct LogoutRequest: Requestable {
    struct URI {
        static let removecookies = "/login/v1/removecookies"
    }
    
    init(config: AcousticContentSDK.Config) {
        let wchLogoutURL = config.apiURL.appendingPathComponent(URI.removecookies)
        var request = URLRequest(url: wchLogoutURL)
        request.httpMethod = "GET"
        self.urlRequest = request
    }
    
    let urlRequest: URLRequest?
}


struct LoginRequest: Requestable {
    struct URI {
        static let basicauth = "/login/v1/basicauth"
    }
    
    init(username: String,
         password: String,
         config: AcousticContentSDK.Config) {
        let wchLoginURL = config.apiURL.appendingPathComponent(URI.basicauth)
        var request = URLRequest(url: wchLoginURL)
        request.httpMethod = "GET"
        let creds = username + ":" + password
        let auth = "Basic " + creds.toBase64()
        request.allHTTPHeaderFields?["Authorization"] = auth
        self.urlRequest = request
    }
    
    let urlRequest: URLRequest?
}

fileprivate extension String {
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

private extension LoginService {
    static func loginResponse(fromData data: Data, response: HTTPURLResponse) -> Result<LoginResponse, LoginError> {
        guard response.statusCode == 200 else {
            return .failure(LoginError(httpResponse: response, responseData: data))
        }
        guard
            let xIbmToken = authToken(fromResponse: response),
            let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]],
            let jsonResponse = jsonArray.first,
            let baseUrl = jsonResponse["baseUrl"] as? String,
            let tenantId = jsonResponse["tenantId"] as? String
            else {
                debugPrint("Login call responded with unexpected response data")
                return .failure(LoginError.unknown)
        }
        let loginResponse = LoginResponse(baseUrl: baseUrl,
                                          tenantId: tenantId,
                                          token: xIbmToken)
        return .success(loginResponse)
    }
    
    static func authToken(fromResponse response: HTTPURLResponse) -> String? {
        if let responseUrl = response.url,
            let headerFields = response.allHeaderFields as? [String : String] {
            
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: responseUrl)
            if let cookie = cookies.first(where: { $0.name == Keys.xIbmDxUserAuth }) {
                return cookie.value
            }
        }
        return nil
    }
    
    var authorizationCookie: HTTPCookie? {
        guard let cookies = HTTPCookieStorage.shared.cookies,
            let cookie = cookies.first(where: { $0.name == Keys.xIbmDxUserAuth }) else {
                return nil
        }
        return cookie
    }
}
