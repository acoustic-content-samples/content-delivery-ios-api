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

/// Class is responsible for providing respond results as data objects or error.
/// Can provide requests for the next and the previous page requests. See `nextPage` and `previousPage` methods.
public struct DevilerySearchResult<DocumentType: Document> {
    
    /// Initiates DevilerySearchResult. It is not intended to use directly. Created by SDK.
    init(response: AnyResponse<DocumentType>, documentsProvider: Documents<DocumentType>) {
        self.documentsProvider = documentsProvider
        self.response = response
        error = nil
    }
    
    /// Initiates DevilerySearchResult. It is not intended to use directly. Created by SDK.
    init(error: DeliverySearchError, documentsProvider: Documents<DocumentType>) {
        self.documentsProvider = documentsProvider
        self.error = error
        response = nil
    }
    
    let documentsProvider: Documents<DocumentType>
    let response: AnyResponse<DocumentType>?
    public let error: DeliverySearchError?
    
    /// Number of elements found by request
    public var numFound: Int {
        return response?.numFound ?? 0
    }
    
    /// Array of documents retrieved by requests
    public var documents: [DocumentType] {
        return response?.documents ?? []
    }
    
    /// Creates `Documents` provider configured to retireve _next_ page based on default or configured `rows` and `start` parameters
    public func nextPage() -> Documents<DocumentType> {
        return documentsProvider.nextPage()
    }
    
    /// Creates `Documents` provider configured to retireve _previous_ page based on default or configured `rows` and `start` parameters.
    /// - Returns: Configured provider of nil if `start` dropped below zero.
    public func previousPage() -> Documents<DocumentType>? {
        return documentsProvider.previousPage()
    }
}
