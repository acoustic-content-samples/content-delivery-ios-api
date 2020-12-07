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
 * Represents asset that can be retrieved using delivery search API.
 */
public struct Asset: Document {
    
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
     * #### Example:
     * ```
     * 2020-01-07T17:52:31.610Z
     * 2020-01-07T17:52:31.477Z
     * 2020-01-07T17:52:31.828Z
     * ```
     *
     */
    public let lastModified: String
    
    /**
     * The UUID of the user that last modified the item.
     */
    public let lastModifierId: String
    
    /**
    *  The creation date of the item.
    *
    *  #### Examples:
    * ```
    * 2020-01-07T17:52:31.610Z
    * 2020-01-07T17:52:31.477Z
    * 2020-01-07T17:52:31.828Z
    * ```
    */
    public let created: String
    
    /**
     * The UUID of the user that created the item.
     */
    public let creatorId: String
    
    /**
     * Field contains the media type.
     */
    public let mediaType: String
    
    /**
     * Field contains the URL to the binary of the asset.
     * It is relative to the API URL for your tenant.
     */
    public let media: String
    
    /**
     * Field contains the folder path including file name.
     */
    public let path: String
    
    /**
     * Field contains the state the item is in.
     * The value of this field can be "ready" or "retired".
     */
    public let status: String
    
    /**
     * Field contains the file size in bytes.
     */
    public let fileSize: Int
    
    /**
     * Field contains the asset type. The value that is returned can be "document", "file", "image", or "video".
     */
    public let assetType: String
    
    /**
     * Field specifies whether the content is managed or not managed and whether the asset is a managed asset or a so-called non-managed web asset.
     */
    public let isManaged: Bool
    
    /**
     * Field contains the folder path without the file name.
     * This allows for efficient queries for sibling assets.
     */
    public let location: String?
    
    /**
     * Field contains all of the path segments.
     * This allows for efficient queries that return assets in subfolders of the queried value.
     * For example, the query locationPaths:"/dxdam" will return assets that are stored in the /dxdam folder or any subfolder.
     */
    public let locationPaths: String?
    
    /**
     * The list of all category selections for the asset.
     */
    public let categories: [String]?
    
    /**
     * The list of all leaf category selection elements for the asset or content.
     */
    public let categoryLeaves: [String]?
    
    /**
     * Field contains the ID of the related resource.
     * You can use this resource ID with the authoring and delivery resource service REST APIs.
     */
    public let resource: String
    
    /**
     * Field contains the URL to the thumbnail of the asset.
     * It is relative to the API URL for your tenant.
     */
    public let thumbnail: String?
    
    
    /**
     * Field contains the server relative URL to the binary document of the asset.
     */
    public let url: String
    
    /**
     * Field contains the full JSON document for the item.
     */
    public let document: [String: Any]?
}

extension Asset: Classifiable {
    public static let classification: DocumentClassification? = .asset
}
