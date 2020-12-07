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

extension Solr {
    
    /// Common Query Parameters for Solr Standard Query Parser
    /// ref: https://lucene.apache.org/solr/guide/8_0/common-query-parameters.html
    enum QueryItem {
        case q_filter([FilterItem])
        case q_string(EscapableString)
        case sort([SortItem])
        case start(Int)
        case rows(Int)
        case fq(EscapableString)
        case fl(String)
    }
}

extension Solr.QueryItem {
    /// Returns key string for use withing query string
    var key: String {
        switch self {
        case .q_filter: return "q"
        case .q_string: return "q"
        case .sort: return "sort"
        case .start: return "start"
        case .rows: return "rows"
        case .fq: return "fq"
        case .fl: return "fl"
        }
    }
    
    var value: String {
        switch self {
        case .q_filter(let items): return items.build()
        case .q_string(let value): return value
        case .sort(let items): return items.build()
        case .start(let value): return "\(value)"
        case .rows(let value): return "\(value)"
        case .fq(let value): return value
        case .fl(let value): return value
        }
    }
}
