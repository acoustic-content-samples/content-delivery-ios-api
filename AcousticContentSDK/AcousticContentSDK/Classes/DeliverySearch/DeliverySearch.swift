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

/// Implements DeliverySearch API to access artifacts providers like Assets, ContentItems, etc.
public class DeliverySearch {
    
    let config: AcousticContentSDK.Config
    let requestSession: RequestSession
    
    /// Creates instance of DeliverySearch. Intended to use internally within SDK to make sure it is properly configured.
    /// Use AcousticContentSDK's deliverySearch() function to create an instance of Delivery search.
    /// - Parameters:
    ///   - config: Configuration structure
    ///   - requestSession: Any implementation of RequestSession
    internal required init(config: AcousticContentSDK.Config, requestSession: RequestSession) {
        self.config = config
        self.requestSession = requestSession
    }
    
    /// Creates and returns Assets provider
    public func assets() -> Assets {
        return Assets(config: config, session: requestSession)
    }
    
    /// Creates and returns ContentItems provider
    public func contentItems() -> ContentItems {
        return ContentItems(config: config, session: requestSession)
    }
    
    /// Creates and returns generic Documents provider configured to retrieve Content Types
    public func contentTypes() -> Documents<ContentType> {
        return Documents<ContentType>(config: config, session: requestSession)
    }
    
    /// Creates and returns generic Documents provider configured to retrieve Categories
    public func categories() -> Documents<Category> {
        return Documents<Category>(config: config, session: requestSession)
    }
    
    // Internal function presenting how to retrieve mixed documets within single Documents provider
    func anyDocuments() -> Documents<AnyDocument> {
        return Documents<AnyDocument>(config: config, session: requestSession)
    }
}
