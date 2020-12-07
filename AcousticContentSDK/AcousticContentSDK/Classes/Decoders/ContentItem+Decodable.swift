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


extension ContentItem: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case classification
        case type
        case creatorId
        case created
        case lastModifierId
        case lastModified
        case categories
        case kind
        case tags
        case description
        case document
        case boolean1
        case boolean2
        case categoryLeaves
        case date1
        case date2
        case generatedFiles
        case isManaged
        case location1
        case locations
        case number1
        case number2
        case status
        case string1
        case string2
        case string3
        case string4
        case sortableDate1
        case sortableDate2
        case sortableNumber1
        case sortableNumber2
        case sortableString1
        case sortableString2
        case sortableString3
        case sortableString4
        case text
        case typeId
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        classification = try values.decodeIfPresent(String.self, forKey: .classification) ?? ""
        type = try values.decodeIfPresent(String.self, forKey: .type) ?? ""
        creatorId = try values.decodeIfPresent(String.self, forKey: .creatorId) ?? ""
        created = try values.decodeIfPresent(String.self, forKey: .created) ?? ""
        lastModifierId = try values.decodeIfPresent(String.self, forKey: .lastModifierId) ?? ""
        lastModified = try values.decodeIfPresent(String.self, forKey: .lastModified) ?? ""
        text = try values.decodeIfPresent([String].self, forKey: .text) ?? []
        typeId = try values.decodeIfPresent(String.self, forKey: .typeId) ?? ""
        isManaged = try values.decodeIfPresent(Bool.self, forKey: .isManaged) ?? false
        status = try values.decodeIfPresent(String.self, forKey: .status) ?? ""
        
        categories = try values.decodeIfPresent([String].self, forKey: .categories)
        kind = try values.decodeIfPresent([String].self, forKey: .kind)
        tags = try values.decodeIfPresent([String].self, forKey: .tags)
        boolean1 = try values.decodeIfPresent([Bool].self, forKey: .boolean1)
        boolean2 = try values.decodeIfPresent([Bool].self, forKey: .boolean2)
        categoryLeaves = try values.decodeIfPresent([String].self, forKey: .categoryLeaves)
        date1 = try values.decodeIfPresent([String].self, forKey: .date1)
        date2 = try values.decodeIfPresent([String].self, forKey: .date2)
        generatedFiles = try values.decodeIfPresent([String].self, forKey: .generatedFiles)
        location1 = try values.decodeIfPresent([String].self, forKey: .location1)
        locations = try values.decodeIfPresent([String].self, forKey: .locations)
        number1 = try values.decodeIfPresent([Double].self, forKey: .number1)
        number2 = try values.decodeIfPresent([Double].self, forKey: .number2)
        string1 = try values.decodeIfPresent([String].self, forKey: .string1)
        string2 = try values.decodeIfPresent([String].self, forKey: .string2)
        string3 = try values.decodeIfPresent([String].self, forKey: .string3)
        string4 = try values.decodeIfPresent([String].self, forKey: .string4)
        sortableDate1 = try values.decodeIfPresent(String.self, forKey: .sortableDate1)
        sortableDate2 = try values.decodeIfPresent(String.self, forKey: .sortableDate2)
        sortableNumber1 = try values.decodeIfPresent(String.self, forKey: .sortableNumber1)
        sortableNumber2 = try values.decodeIfPresent(String.self, forKey: .sortableNumber2)
        sortableString1 = try values.decodeIfPresent(String.self, forKey: .sortableString1)
        sortableString2 = try values.decodeIfPresent(String.self, forKey: .sortableString2)
        sortableString3 = try values.decodeIfPresent(String.self, forKey: .sortableString3)
        sortableString4 = try values.decodeIfPresent(String.self, forKey: .sortableString4)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        
        
        do {
            if let documentString = try values.decodeIfPresent(String.self, forKey: .document),
                let documentData = documentString.data(using: .utf8) {
                document = try JSONSerialization.jsonObject(with: documentData, options: []) as? [String: Any]
            } else {
                document = nil
            }
        } catch {
            if (error as NSError).code == 4864 /* Expected to decode String but found a dictionary instead. */ {
                throw DocumentsError.parsingDocumentError
            }
            document = nil
        }
    }
}

/// Processes a usecase when loading Delivery Render API. Content item contains only `id` and  `document` fields in this case
extension ContentItem {
    public static func fromData(_ data: Data) throws -> Self {
        do {
            return try JSONDecoder().decode(Self.self, from: data)
        } catch DocumentsError.parsingDocumentError {
            guard
                let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let id = dictionary["id"] as? String,
                let document = dictionary["document"] as? [String: Any]
                else { throw DocumentsError.parsingDocumentError }
            
            return ContentItem(id: id, name: "", classification: DocumentClassification.content.rawValue,
                               lastModified: "", lastModifierId: "", created: "", creatorId: "", boolean1: nil,
                               boolean2: nil, categories: nil, categoryLeaves: nil, date1: nil, date2: nil,
                               document: document, kind: nil, description: nil, tags: nil, generatedFiles: nil,
                               isManaged: false, location1: nil, locations: nil, number1: nil, number2: nil,
                               status: "", string1: nil, string2: nil, string3: nil, string4: nil, sortableDate1: nil,
                               sortableDate2: nil, sortableNumber1: nil, sortableNumber2: nil, sortableString1: nil,
                               sortableString2: nil, sortableString3: nil, sortableString4: nil, text: [String](),
                               type: "", typeId: "")
        }
    }
}
