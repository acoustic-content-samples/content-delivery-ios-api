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

enum AnyResponseError: Error {
    case decodingError
}

public struct AnyResponse<Element: Document> {
    let numFound: Int
    let documents: [Element]
    
    static func fromData(_ data: Data) throws -> AnyResponse<Element> {
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let numFound = json[CodingKeys.numFound] as? Int else {
            throw AnyResponseError.decodingError
        }
        guard let documentsArray = json[CodingKeys.documents] as? [[String: Any]] else {
            return AnyResponse(numFound: numFound, documents: [])
        }
        let documents: [Element] = try documentsArray.map {
            let data = try JSONSerialization.data(withJSONObject: $0, options: [])
            return try Element.fromData(data)
        }
        return AnyResponse(numFound: numFound, documents: documents)
    }
}

private struct CodingKeys {
    static let numFound = "numFound"
    static let documents = "documents"
}
