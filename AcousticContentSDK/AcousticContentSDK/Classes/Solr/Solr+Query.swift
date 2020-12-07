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

/// `Solr` class is representing namespace for Solr query builder implementation
extension Solr {
    
    /// `Query` class is responsible for constructing searching query request 
    class Query {
        
        var queryItems = [QueryItem]()
        
        var baseUrl: String = ""
        
        func set(baseUrl url: String) {
            baseUrl = url
        }
        
        func add(queryItem item: QueryItem) {
            queryItems.append(item)
        }
        
        func add(queryItems items: [QueryItem]) {
            queryItems.append(contentsOf: items)
        }
        
        func queryParameters() -> String {
            return build()
        }
        
        func query() -> String {
            return baseUrl + "?" + queryParameters()
        }
    }
}
