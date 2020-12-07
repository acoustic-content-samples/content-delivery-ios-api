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

public enum LoginError: Error {
    /// 401 - Authentication failed with credentials (incorrect or missing)
    case authenticationFailedWithCredentials
    /// 403 - Access forbidden (e.g. no access to tenant or enterprise federation)
    case accessForbidden
    /// 404 - Tenant not found
    case tenantNotFound
    /// 412 - Precondition Failed for credentials (incorrect format or missing)
    case preconditionFailedForCredentials
    /// 423 - The tenant is locked
    case tenantIsLocked
    /// 429 - Too Many Requests, the server has reached a limit, the request must be sent again at a later time.
    case tooManyRequests(AcousticContentError?)
    /// 503 - Downstream service not available
    case downstreamServiceNotAvailable
    
    case unknown
    
    
    init(httpResponse: HTTPURLResponse, responseData: Data) {
        switch httpResponse.statusCode {
        case 401:
            self = .authenticationFailedWithCredentials
        case 403:
            self = .accessForbidden
        case 404:
            self = .tenantNotFound
        case 412:
            self = .preconditionFailedForCredentials
        case 423:
            self = .tenantIsLocked
        case 429:
            self = .tooManyRequests(try? AcousticContentError.fromData(responseData))
        case 503:
            self = .downstreamServiceNotAvailable
        default:
            self = .unknown
        }
    }
}
