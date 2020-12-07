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

/// Declares common configurable functions.
public protocol Configurable {
    
    /// Configures request start position
    /// - Parameter from: Start from index
    func start(_ from: Int) -> Self
    
    /// Configures request page size
    /// - Parameter size: Number of pages to request
    func rows(_ rows: Int) -> Self
    
    /// Configures sorting rules for specified field and ordering.
    /// - Parameters:
    ///   - field: Name of field to sort
    ///   - ascending: Ascending ordering if `true`, descending otherwise
    func sortBy(_ field: String, ascending: Bool) -> Self
    
    /// Configures filtering parameters. Adds every key/value pair to resulting filter query.
    /// - Parameter filters: Filter map representing field name as a key and filtering valu
    func filterBy(_ filter: [String: String]) -> Self
    
    /// Configures filtering parameters
    /// - Parameter filter: String representing filter query
    func filterQuery(_ fq: String) -> Self
    
    /// Configures mandatory query field
    /// - Parameter text: Text or query to search for
    func searchText(_ text: String) -> Self
    
    
    /// Configures request to fetch all fields including `document` field.
    /// - Parameter include: `true` to request all fields. `false` othewise.
    func includeDocument(_ include: Bool) -> Self
}

/// Declares protected configurable functions.
public protocol ProtectedConfigurable: Configurable {
    
    /// Configures provider to retrieve protected content. _Require authentication_.
    /// - Parameter protected: `true` if protected content needs to be requested. `false` othewise.
    func protectedContent(_ protected: Bool) -> Self
}

/// Declares protected previewable configurable functions.
public protocol PreviewConfigurable: Configurable {
    
    /// Configures provider to retrieve draft content. _Require authentication_.
    /// - Parameter include: `true` if draft content needs to be requested. `false` othewise.
    func includeDraft(_ include: Bool) -> Self
    
    /// Configures provider to retrieve retired content. _Require authentication_.
    /// - Parameter include: `true` if retired content needs to be requested. `false` othewise.
    func includeRetired(_ include: Bool) -> Self
}

/// Declares custom configurable functions.
public protocol CustomConfigurable: Configurable {
    
    /// Configures provider to retrieve artifacts by `name`.
    /// - Parameter name: String representing name. Supports wildcharacters.
    func filterByName(_ name: String) -> Self
    
    /// Configures provider to retrieve artifacts by `tags`.
    /// - Parameter tags: Array of tags.  Does not support wildcharacters.
    func filterByTags(_ tags: [String]) -> Self
    
    /// Configures provider to retrieve artifacts by `id`.
    /// - Parameter id: Artifact identifier. Does not support wildcharacters.
    func filterById(_ id: String) -> Self
    
    /// Configures provider to retrieve artifacts by `category`.
    /// - Parameter category: Category string. Does not support wildcharacters.
    func filterByCategory(_ category: String) -> Self
}
