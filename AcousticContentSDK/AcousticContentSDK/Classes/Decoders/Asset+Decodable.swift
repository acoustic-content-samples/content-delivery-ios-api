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

extension Asset: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case classification
        case lastModified
        case lastModifierId
        case created
        case creatorId
        case mediaType
        case path
        case fileSize
        case assetType
        case resource
        case url
        case document
        case media
        case status
        case isManaged
        case location
        case locationPaths
        case categories
        case categoryLeaves
        case thumbnail
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        classification = try values.decode(String.self, forKey: .classification)
        lastModified = try values.decode(String.self, forKey: .lastModified)
        lastModifierId = try values.decode(String.self, forKey: .lastModifierId)
        created = try values.decode(String.self, forKey: .created)
        creatorId = try values.decode(String.self, forKey: .creatorId)
        mediaType = try values.decode(String.self, forKey: .mediaType)
        path = try values.decode(String.self, forKey: .path)
        fileSize = try values.decode(Int.self, forKey: .fileSize)
        assetType = try values.decode(String.self, forKey: .assetType)
        resource = try values.decode(String.self, forKey: .resource)
        url = try values.decode(String.self, forKey: .url)
        media = try values.decode(String.self, forKey: .media)
        status = try values.decode(String.self, forKey: .status)
        isManaged = try values.decode(Bool.self, forKey: .isManaged)
        location = try values.decodeIfPresent(String.self, forKey: .location)
        locationPaths = try values.decodeIfPresent(String.self, forKey: .locationPaths)
        categories = try values.decodeIfPresent([String].self, forKey: .categories)
        categoryLeaves = try values.decodeIfPresent([String].self, forKey: .categoryLeaves)
        thumbnail = try values.decodeIfPresent(String.self, forKey: .thumbnail)
        
        if let documentString = try values.decodeIfPresent(String.self, forKey: .document),
            let documentData = documentString.data(using: .utf8) {
            document = try JSONSerialization.jsonObject(with: documentData, options: []) as? [String: Any]
        } else {
            document = nil
        }
    }
}
