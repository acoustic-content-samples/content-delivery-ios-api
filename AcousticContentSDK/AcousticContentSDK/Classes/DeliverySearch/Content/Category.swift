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

/**
 * Represents category that can be retrieved using delivery search API.
 */
public struct Category: Document {
    /**
     * The identifier of the item. For items of the same "classification", this identifier is unique.
     * The combination of the "classification" and the "id" is unique across all items of the Watson Content Hub tenant.
     */
    public let id: String
    
    /**
     * The name of the item.
     */
    public let name: String
    
    /**
     * This field describes the kind of item. The value that is returned can be "asset", "category", "content" or "taxonomy".
     */
    public let classification: String
    
    /**
     * The last modification date of the item.
     *
     * #### Examples:
     * ```
     * 2020-01-07T17:52:31.610Z
     * 2020-01-07T17:52:31.477Z
     * 2020-01-07T17:52:31.828Z
     * ```
     */
    public let lastModified: String
        
    /**
     * The creation date of the item.
     *
     * #### Examples:
     * ```
     * 2020-01-07T17:52:31.610Z
     * 2020-01-07T17:52:31.477Z
     * 2020-01-07T17:52:31.828Z
     * ```
     */
    public let created: String
    
    /**
     * Field contains the full JSON document for the item.
     */
    public let document: [String: Any]?

    /**
     * For assets, this field contains the folder path including file name.
     */
    public let path: String
}

extension Category: Classifiable {
    public static let classification: DocumentClassification? = .category
}
