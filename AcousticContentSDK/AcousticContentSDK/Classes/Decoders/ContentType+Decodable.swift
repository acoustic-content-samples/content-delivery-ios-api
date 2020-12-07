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

extension ContentType: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case classification
        case created
        case lastModifierId
        case lastModified
        case description
        case tags
        case document
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        classification = try values.decode(String.self, forKey: .classification)
        created = try values.decode(String.self, forKey: .created)
        lastModifierId = try values.decode(String.self, forKey: .lastModifierId)
        lastModified = try values.decode(String.self, forKey: .lastModified)
        
        description = try values.decodeIfPresent(String.self, forKey: .description)
        tags = try values.decodeIfPresent([String].self, forKey: .tags)
        
        if let documentString = try values.decodeIfPresent(String.self, forKey: .document),
            let documentData = documentString.data(using: .utf8) {
            document = try JSONSerialization.jsonObject(with: documentData, options: []) as? [String: Any]
        } else {
            document = nil
        }
    }
}
