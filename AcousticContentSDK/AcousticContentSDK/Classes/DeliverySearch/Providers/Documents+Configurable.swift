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

extension Documents: Configurable {
 
    /// Configures request start position
    /// - Parameter from: Start from index
    @discardableResult
    public func start(_ from: Int = 0) -> Self {
        requestConfig.start = from
        return self
    }
    
    /// Configures request page size
    /// - Parameter size: Number of pages to request
    @discardableResult
    public func rows(_ rows: Int) -> Self {
        requestConfig.rows = rows
        return self
    }
    
    /// Configures sorting rules for specified field and ordering. Every next call of this function appends sorting rule if field
    /// name is unique and moves rule to the end with new value if the field is already containing sorting rule
    /// - Parameters:
    ///   - field: Name of field to sort
    ///   - ascending: Ascending ordering if `true`, descending otherwise
    @discardableResult
    public func sortBy(_ field: String, ascending: Bool = true) -> Self {
        if let duplicateIndex = requestConfig.sortMap.firstIndex(where: { $0.0 == field }) {
            requestConfig.sortMap.remove(at: duplicateIndex)
        }
        requestConfig.sortMap.append((field, ascending))
        return self
    }
    
    /// Configures filtering parameters. Adds every key/value pair to resulting filter query.
    /// - Parameter filters: Filter map representing field name as a key and filtering value
    @discardableResult
    public func filterBy(_ filters: [String: String]) -> Self {
        requestConfig.filterQueries.append(contentsOf: filters.map({ $0.key + ":" + $0.value }))
        return self
    }
    
    /// Configures filtering parameters
    /// - Parameter filter: String representing filter query
    @discardableResult
    public func filterQuery(_ filter: String) -> Self {
        requestConfig.filterQueries.append(filter)
        return self
    }
    
    /// Configures mandatory query field
    /// - Parameter text: Text or query to search for
    @discardableResult
    public func searchText(_ text: String) -> Self {
        requestConfig.searchText = text
        return self
    }
    
    /// Configures request to fetch all fields including `document` field.
    /// - Parameter include: `true` to request all fields. `false` othewise.
    @discardableResult
    public func includeDocument(_ include: Bool) -> Self {
        requestConfig.includeDocument = include
        return self
    }
}
