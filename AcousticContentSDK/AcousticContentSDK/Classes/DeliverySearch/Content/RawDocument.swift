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

/// `RawDocument` is a `Document` of which supports any type of JSON data. Parses data into `content` structure.
public struct RawDocument: Document {
    
    /// Contains parsed JSON data as objects
    public let content: Any?
    
    /// Creates instance of `RawDocument`
    /// - Parameter data: Data which contains JSON string.
    public init(with data: Data) throws {
        content = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
    
    /// Implements `Parsable` protocol function. Converts `data` to `RawDocument` instance.
    /// - Parameter data: Data which contains JSON string.
    public static func fromData(_ data: Data) throws -> RawDocument {
        return try RawDocument(with: data)
    }
}

extension RawDocument: Classifiable {
    
    /// Implements `Classifiable` protocol function.
    public static let classification: DocumentClassification? = nil
}
