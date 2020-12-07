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

/// Delivery search error.
public enum DeliverySearchError: Error {
    /// Unable to complete your request due to missing parameters. Provide all required parameters and try again.
    case badRequest(ApiError)
    /// Access forbidden (e.g. no access to tenant or enterprise federation)
    case accessForbidden
    /// The delivery collection was not found.
    case notFound(ApiError)
    /// The request URL that addresses the search service is larger than the supported size of 4,096 bytes. Reduce the length of the query.
    case responseIsTooLarge(ApiError)
    /// Too Many Requests, the server has reached a limit, the request must be sent again at a later time.
    case tooManyRequests(ApiError)
    /// Internal server error - Unable to complete your request due to an exception. Try again later.
    case internalError(ApiError)
    /// Received document is corrupt or cannot be parsed.
    case documentError(DocumentsError)
    /// HTTP request failed.
    case requestFailed(Error)
    /// API returned an error unrelated to the search itself.
    case unknown(ApiError)
    
    static func fromResponse(httpRespose: HTTPURLResponse, responseData: Data) throws -> DeliverySearchError? {
        
        let apiError: () throws -> ApiError = {
            return try ApiError.fromData(responseData)
        }
        
        do {
            switch httpRespose.statusCode {
            case 400:
                return .badRequest(try apiError())
            case 403:
                return .accessForbidden
            case 404:
                return .notFound(try apiError())
            case 414:
                return .responseIsTooLarge(try apiError())
            case 429:
                return .tooManyRequests(try apiError())
            case 500:
                return .internalError(try apiError())
            default:
                if let error = try? apiError() {
                    return .unknown(error)
                }
                return nil
            }
        } catch {
            return nil
        }
    }
}
