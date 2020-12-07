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
@testable import AcousticContentSDK

enum JSONResponseFile: String {
    case assets
    case assets_with_document_string
    case category
    case contentType = "content_type"
    case content
    case contentProtected = "content_protected"
    case contentProtectedDenied = "content_protected_denied"
    case contentFilteredByName = "content_filtered_by_name"
    case contentFilteredById = "content_filtered_by_id"
    case contentFilteredByTags = "content_filtered_by_tags"
    case contentFilteredByCategory = "content_filtered_by_category"
    case contentRawDocument = "content_item_raw_document"
    case nameSearch = "name_Design"
    case nameSearchMixedDocuments = "search_mixed_documents"
    case error = "error"
    case login_success = "login"
    case login_error_credentials
    case login_error_tenant
    case unsupported_docuements
}

enum JSONFileError: Error {
    case noSuchFile
}

extension JSONResponseFile {
    func get() throws -> Data {
        guard let fileURL = Bundle(for: JSONFileSessionMock.self).url(forResource: rawValue, withExtension: "json"),
            let data = try? Data(contentsOf: fileURL) else {
                throw JSONFileError.noSuchFile
        }
        return data
    }
}

class JSONFileSessionMock: RequestSession {
    
    var file: JSONResponseFile
    var httpResponse: HTTPURLResponse = HTTPURLResponse()
    required init(withFile file: JSONResponseFile) {
        self.file = file
    }
    
    func load(request: Requestable, completion: @escaping RequestCompletion) {
        do {
            completion(.success(try file.get(), httpResponse))
        } catch {
            completion(.failure(error, nil))
        }
    }
}
