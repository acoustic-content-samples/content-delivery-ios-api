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

extension ContentItems: CustomConfigurable {
    
    /// Configures provider to retrieve artifacts by `name`.
    /// - Parameter name: String representing name. Supports wildcharacters.
    @discardableResult
    public func filterByName(_ name: String) -> Self {
        requestConfig.filterQueries.append("name:\(name)")
        return self
    }
    
    /// Configures provider to retrieve artifacts by `tags`.
    /// - Parameter tags: Array of tags.  Does not support wildcharacters.
    @discardableResult
    public func filterByTags(_ tags: [String]) -> Self {
        requestConfig.filterQueries.append("tags:(\(tags.map({"\"\($0)\""}).joined(separator: " OR ")))")
        return self
    }
    
    /// Configures provider to retrieve artifacts by `id`.
    /// - Parameter id: Artifact identifier. Does not support wildcharacters.
    @discardableResult
    public func filterById(_ id: String) -> Self {
        requestConfig.filterQueries.append("id:\(id)")
        return self
    }
    
    /// Configures provider to retrieve artifacts by `category`.
    /// - Parameter category: Category string. Does not support wildcharacters.
    @discardableResult
    public func filterByCategory(_ category: String) -> Self {
        requestConfig.filterQueries.append("categories:(+\"\(category)\")")
        return self
    }
}
