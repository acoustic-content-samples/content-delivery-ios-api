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
@testable import AcousticContentSDK

struct AcousticTestContext {
    
    enum SessionType {
        case live
        case mocked
    }
    
    static var apiURL: URL {
        switch sessionType {
        case .live:
            guard let url = URL(string: apiUrlFromInfoDictionary) else {
                fatalError("Error: \(apiUrlFromInfoDictionary) is not a valid URL.")
            }
            return url
        case .mocked:
            return URL(string: "https://subdomain-6.domain")!
        }
    }
    
    static var username: String {
        return usernameFromInfoDictionary
    }
    
    static var password: String {
        return passwordFromInfoDictionary
    }
    
    static var sessionType: SessionType {
        if apiUrlFromInfoDictionary == "" {
            return .mocked
        } else {
            return .live
        }
    }
    
    static var timeout = 4.0
    
    /// Function returns either mocked either live request session depending on Live or Mock test session invoked.
    /// - Parameter file: Mocked data file name. Used only in Mock test sessions.
    /// - Returns: RequestSession instance. In Live test sessions returns real URLRequestLoader instance which loads data from web according to provided URLs.
    static func getSessionMock(_ file: JSONResponseFile) -> RequestSession {
        switch sessionType {
        case .live: return URLRequestLoader()
        case .mocked: return JSONFileSessionMock(withFile: file)
        }
    }
}

extension AcousticTestContext {
    
    private static let bundleId = "com.acoustic.AcousticContentSDKTests"
    
    private static var apiUrlFromInfoDictionary: String {
        let bundle = Bundle(identifier: bundleId)
        guard let apiUrl = bundle?.object(forInfoDictionaryKey: "ApiUrl") as? String else {
            fatalError("ApiUrl is missing from bundle info dictionary, cannot proceed")
        }
        return apiUrl
    }
    
    private static var usernameFromInfoDictionary: String {
        let bundle = Bundle(identifier: bundleId)
        guard let username = bundle?.object(forInfoDictionaryKey: "Username") as? String else {
            fatalError("Username is missing from bundle info dictionary, cannot proceed")
        }
        return username
    }
    
    private static var passwordFromInfoDictionary: String {
        let bundle = Bundle(identifier: bundleId)
        guard let password = bundle?.object(forInfoDictionaryKey: "Password") as? String else {
            fatalError("Password is missing from bundle info dictionary, cannot proceed")
        }
        return password
    }
}
