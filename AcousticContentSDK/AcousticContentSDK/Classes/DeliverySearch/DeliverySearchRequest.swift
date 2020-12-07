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

/// Class is responsible for holding request parameters and generating request url.
public class DeliverySearchRequest {
        
    struct RequestConfig {
        var classification: DocumentClassification? = nil
        var start: Int?
        var rows: Int?
        var sortMap = [(String, Bool)]()
        var filterQueries = [String]()
        var searchText: String? = nil
        var includeDocument: Bool = true
        var protectedContent: Bool = false
        var includeDraft: Bool = false
        var includeRetired: Bool = false
        var renderingContent: Bool = false
    }
    
    /// Set of sdk parameters
    let sdkConfig: AcousticContentSDK.Config
    
    /// Set of request parameters
    let requestConfig: RequestConfig
    
    /// Returns part of delivery search specific URL.
    struct URI {
        static let deliveryPath = "/delivery/v1/search"
        static let deliveryProtected = "/mydelivery/v1/search"
        static let deliveryRenderingPath = "/delivery/v1/rendering/search"
        static let deliveryRenderingProtected = "/mydelivery/v1/rendering/search"
        static let previewPath = "-preview"
    }
    
    required init(config: AcousticContentSDK.Config, requestConfig: RequestConfig) {
        self.sdkConfig = config
        self.requestConfig = requestConfig
    }
}

extension DeliverySearchRequest: Requestable {
    var urlRequest: URLRequest? {
        
        let query = Solr.Query()
        
        /// Sets default delivery search URL path
        var apiURLString = sdkConfig.apiURL.appendingPathComponent(URI.deliveryPath).absoluteString
        
        /// Configures delivery URL path according to specified parameters `renderingContent` and `protectedContent`
        switch (requestConfig.renderingContent, requestConfig.protectedContent) {
        case (false, false):
            apiURLString = sdkConfig.apiURL.appendingPathComponent(URI.deliveryPath).absoluteString
        case (false, true):
            apiURLString = sdkConfig.apiURL.appendingPathComponent(URI.deliveryProtected).absoluteString
        case (true, false):
            apiURLString = sdkConfig.apiURL.appendingPathComponent(URI.deliveryRenderingPath).absoluteString
        case (true, true):
            apiURLString = sdkConfig.apiURL.appendingPathComponent(URI.deliveryRenderingProtected).absoluteString
        }
        
        /// Takes care of `q` parameter
        var q = Solr.QueryItem.q_string("*:*")
        if let searchText = requestConfig.searchText, searchText.count > 0 {
            q = Solr.QueryItem.q_string(searchText)
        }
        query.add(queryItem: q)
        
        /// Takes care of `start` parameter
        if let number = requestConfig.start {
            let start = Solr.QueryItem.start(number)
            query.add(queryItem: start)
        }
        
        /// Takes care of `rows` parameter
        if let number = requestConfig.rows {
            let rows = Solr.QueryItem.rows(number)
            query.add(queryItem: rows)
        }
        
        /// Takes care of `sort` parameter
        var sort = Solr.QueryItem.sort([Solr.SortItem(field: "lastModified", direction: .asc)])
        if requestConfig.sortMap.count > 0 {
            let sortItems = requestConfig.sortMap.map({ Solr.SortItem(field: $0.0, direction: $0.1 ? .asc : .desc) })
            sort = Solr.QueryItem.sort(sortItems)
        }
        query.add(queryItem: sort)
        
        /// Takes care of `fq-classification` parameter
        if let value = requestConfig.classification?.rawValue {
            let filter = Solr.FilterItem(field: "classification", value: value).build()
            let classification = Solr.QueryItem.fq(filter)
            query.add(queryItem: classification)
        }
        
        /// Takes care of `fq` parameter
        if requestConfig.filterQueries.count > 0 {
            let filters = requestConfig.filterQueries.map({ Solr.QueryItem.fq($0) })
            query.add(queryItems: filters)
        }
        
        /// Takes care of `fl` parameter
        if requestConfig.includeDocument {
            let fl = Solr.QueryItem.fl("*")
            query.add(queryItem: fl)
        }
        
        /// Takes care of `includeDraft` parameters
        if requestConfig.includeDraft && !requestConfig.includeRetired {
            let fq = Solr.QueryItem.fq("status:(ready OR draft) OR draftStatus:*")
            query.add(queryItem: fq)
            
            apiURLString = updateToPreview(apiUrl: apiURLString)
        }
        
        /// Takes care of `includeRetired` parameters
        if requestConfig.includeRetired && !requestConfig.includeDraft {
            let fq = Solr.QueryItem.fq("status:(ready OR retired)")
            query.add(queryItem: fq)
            
            apiURLString = updateToPreview(apiUrl: apiURLString)
        }
        
        /// Takes care of `includeDraft` and `includeRetired` parameters both included
        if requestConfig.includeDraft && requestConfig.includeRetired {
            let fq = Solr.QueryItem.fq("status:(ready OR draft OR retired) OR draftStatus:*")
            query.add(queryItem: fq)
            
            apiURLString = updateToPreview(apiUrl: apiURLString)
        }
        
        query.set(baseUrl: apiURLString)
        
        guard let percentEncoded = query.query().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: percentEncoded) else { return nil }
        
        var request = URLRequest(url: url)
        
        // Verify if auth token is available and add it to request
        if let loginInfo = sdkConfig.loginInfo {
            request.setValue(loginInfo.token, forHTTPHeaderField: LoginService.Keys.xIbmDxUserAuth)
        }
        
        return request
    }
}

private extension DeliverySearchRequest {
    /// Updates last level subdomain of API URL with `-preview`
    /// - Parameter url: Base api url which require to be updated with `-preview` subdomain
    func updateToPreview(apiUrl url: String) -> String {
        guard let components = URLComponents(string: url),
            let hostComponents = components.host?.split(separator: ".").compactMap({String($0)}),
            hostComponents.count > 0 else { return url }
        
        var subdomains = hostComponents
        let firstSubdomain = subdomains.removeFirst()
        let host = ([firstSubdomain + URI.previewPath] + subdomains).joined(separator: ".")
        
        var resultComponents = components
        resultComponents.host = host
        
        return resultComponents.string ?? url
    }
}
