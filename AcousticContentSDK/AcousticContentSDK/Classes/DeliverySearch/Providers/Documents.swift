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

/// Provides Document related error types
public enum DocumentsError: Error {
    case missedRequest
    case missedData
    case decodingError(Error)
    case parsingDocumentError
}

/// Generic Documents provider.
/// Not intented to be created directly. Take a concrete instance from a DeliverySearch instance.
///
/// DocumentType could be `Asset`, `ContentItem`, `ContentType`, `Category` or `AnyDocument` .
public class Documents<DocumentType: Document> {
    
    internal init(config: AcousticContentSDK.Config, session: RequestSession) {
        self.sdkConfig = config
        self.session = session
        requestConfig.classification = DocumentType.classification
    }
    
    internal init(config: AcousticContentSDK.Config, session: RequestSession, requestConfig: DeliverySearchRequest.RequestConfig) {
        self.sdkConfig = config
        self.session = session
        self.requestConfig = requestConfig
    }
    
    let sdkConfig: AcousticContentSDK.Config
    var requestConfig = DeliverySearchRequest.RequestConfig()
    
    let session: RequestSession
    
    let defaultStart = 0
    let defaultPageSize = 10
    
    /// Retrieves a collection of Documents or an Error.
    public func get(completion: @escaping (DevilerySearchResult<DocumentType>) -> Void) {
        let request = DeliverySearchRequest(config: sdkConfig, requestConfig: requestConfig)
        let documentProvider = copy()
        session.load(request: request) { (result) in
            switch result {
            case .success(let data, let response):
                do {
                    let searchResult = try AnyResponse<DocumentType>.fromData(data)
                    completion(DevilerySearchResult(response: searchResult, documentsProvider: documentProvider))
                } catch {
                    let deliverySearchError: DeliverySearchError
                    if let decodedError = try? DeliverySearchError.fromResponse(httpRespose: response, responseData: data) {
                        deliverySearchError = decodedError
                    } else {
                        let documentsError = DocumentsError.decodingError(error)
                        deliverySearchError = DeliverySearchError.documentError(documentsError)
                    }
                    completion(DevilerySearchResult(error: deliverySearchError, documentsProvider: documentProvider))
                }
            case .failure(let error, _):
                let deliverySearchError = DeliverySearchError.requestFailed(error)
                completion(DevilerySearchResult(error: deliverySearchError, documentsProvider: documentProvider))
            }
        }
    }
    
    /// Provides next page requests. Will return nil if current request is the last one.
    func nextPage() -> Documents<DocumentType> {
        return copy().start((requestConfig.start ?? defaultStart) + (requestConfig.rows ?? defaultPageSize))
    }
    
    /// Provides next previous requests. Will return nil if current request is the first one.
    func previousPage() -> Documents<DocumentType>? {
        let newStart = (requestConfig.start ?? defaultStart) - (requestConfig.rows ?? defaultPageSize)
        guard newStart >= 0 else {
            return nil
        }
        return copy().start(newStart)
    }
    
    private func copy() -> Documents<DocumentType> {
        return Documents(
            config: sdkConfig,
            session: session,
            requestConfig: requestConfig
        )
    }
}
