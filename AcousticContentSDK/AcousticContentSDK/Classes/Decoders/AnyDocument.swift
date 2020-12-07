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

/// A container for a Document. Could contain any `Document` type.
/// Might be retirived from a mixed search request.
enum AnyDocument: Document {
    
    case asset(Asset)
    case content(ContentItem)
    case contentType(ContentType)
    case category(Category)
    case raw(RawDocument)
    
    enum CodingKeys: CodingKey {
        case classification
    }
}

extension AnyDocument: Classifiable {
    public static let classification: DocumentClassification? = nil
}

extension AnyDocument: Decodable {

    enum AnyDocumentError: Error {
        case unknownClassification(String)
    }
    
    static func fromData(_ data: Data) throws -> AnyDocument {
        guard let container = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let rawClassification = container["classification"] as? String,
            let _ = DocumentClassification(rawValue: rawClassification) else {
                return .raw(try RawDocument.fromData(data))
        }
        return try JSONDecoder().decode(Self.self, from: data)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rawClassification = try container.decode(String.self, forKey: .classification)
        guard let classification = DocumentClassification(rawValue: rawClassification) else {
            throw AnyDocumentError.unknownClassification("Unknown document classification type: \(rawClassification)")
        }
        switch classification {
        case .asset:
            self = .asset(try decoder.singleValueContainer().decode(Asset.self))
        case .content:
            self = .content(try decoder.singleValueContainer().decode(ContentItem.self))
        case .contentType:
            self = .contentType(try decoder.singleValueContainer().decode(ContentType.self))
        case .category:
            self = .category(try decoder.singleValueContainer().decode(Category.self))
        }
    }
}
