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

/// Class representing Acoustic Content Hub access point. Responsible for accessing core features like DeliverySearch, Authentication, Rendering and othe APIs.
public class AcousticContentSDK {
    
    private (set) var config: AcousticContentSDK.Config
    
    public required init(withConfig config: AcousticContentSDK.Config) {
        self.config = config
    }
    
    /// Performs authentication with username and password..
    /// If the authentication succeeds this service tries to find the corresponding tenant for this authenticated user.
    /// If no tenant for the user is found, the authentication fails presenting an error.
    public func login(username: String, password: String, completion: @escaping (Bool, LoginError?) -> Void) {
        let loginService = LoginService(config: config, requestSession: requestSession())
        loginService.login(username: username, password: password) { [weak self] (response, error) in
            if let response = response {
                self?.config.loginInfo = response
                completion(true, nil)
            } else {
                self?.config.loginInfo = nil
                completion(false, error)
            }
        }
    }
    
    public var isAuthorized: Bool {
        return config.loginInfo != nil
    }
    
    /// Cleans the authentication and tenant cookies.
    public func logout(_ completion: @escaping () -> Void) {
        let loginService = LoginService(config: config, requestSession: requestSession())
        loginService.logout() {
            completion()
        }
        config.loginInfo = nil
    }
    
    internal func requestSession() -> RequestSession {
        return URLRequestLoader()
    }
}
