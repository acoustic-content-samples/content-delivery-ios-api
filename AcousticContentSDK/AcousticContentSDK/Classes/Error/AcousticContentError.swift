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

public struct ApiError: Parsable {
    let requestId: String
    let service: String?
    let errors: [AcousticContentError]
    
    public static func fromData(_ data: Data) throws -> ApiError {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw AnyResponseError.decodingError
        }
        guard let requestId = json["requestId"] as? String,
            let errors = json["errors"] as? [[String: Any]] else {
                throw AnyResponseError.decodingError
        }
        return ApiError(
            requestId: requestId,
            service: json["service"] as? String,
            errors: errors.map { return AcousticContentError.fromJson($0) }
        )
    }
}

public struct AcousticContentError: Parsable {
    public let code: Int?
    public let message: String?
    public let description: String?
    public let moreInfo: String?
    public let level: String?
    public let parameters: [String: Any]?
    public let cause: [String: Any]?
    public let locale: String?
    
    public static func fromData(_ data: Data) throws -> AcousticContentError {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw AnyResponseError.decodingError
        }
        return fromJson(json)
    }
    
    static func fromJson(_ json: [String: Any]) -> AcousticContentError {
        return AcousticContentError(
            code: json["code"] as? Int,
            message: json["message"] as? String,
            description: json["description"] as? String,
            moreInfo: json["more_info"] as? String,
            level: json["level"] as? String,
            parameters: json["parameters"] as? [String: Any],
            cause: json["cause"] as? [String: Any],
            locale: json["locale"] as? String
        )
    }
}
