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

protocol SolrQueryBuilder {
    func build() -> String
}

extension Solr.Query: SolrQueryBuilder {
    func build() -> String {
        return queryItems.compactMap({ $0.build() }).joined(separator: "&")
    }
}

extension Solr.QueryItem: SolrQueryBuilder {
    func build() -> String {
        return key + "=" + value
    }
}

extension Array where Element == Solr.FilterItem {
    func build() -> String {
        var result = first?.build() ?? ""
        for idx in 1..<count {
            result.append(" \(self[idx].operation.rawValue) \(self[idx].build())")
        }
        return result
    }
}

extension Solr.FilterItem: SolrQueryBuilder {
    public func build() -> String {
        guard let value = value else { return field }
        return field + ":" + value.escaped
    }
}

extension Array where Element == Solr.SortItem {
    func build() -> String {
        return compactMap({ $0.build() }).joined(separator: ",")
    }
}

extension Solr.SortItem: SolrQueryBuilder {
    func build() -> String {
        return field + " " + direction.rawValue
    }
}
