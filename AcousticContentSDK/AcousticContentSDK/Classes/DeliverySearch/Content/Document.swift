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

/// An umberella type for all the Documents like 'Asset', 'ContentItem', 'ContentType', 'Category' and others
public protocol Document: Classifiable & Parsable {}


/// Declares common parsable functions.
public protocol Parsable {
    
    /// Declares generic conversion function from `Data` to specified  `Parsable` class.
    static func fromData(_ data: Data) throws -> Self
}

extension Parsable where Self: Decodable {
    
    /// Implements default conversion from `Data` to `Decodable` object.
    /// - Parameter data: Data which contains JSON string.
    public static func fromData(_ data: Data) throws -> Self {
        return try JSONDecoder().decode(Self.self, from: data)
    }
}
