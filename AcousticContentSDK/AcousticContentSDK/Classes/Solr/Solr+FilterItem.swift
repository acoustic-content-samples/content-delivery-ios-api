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
    
    /// `FilterItem` is representing filter parameter for `q` query item
    struct FilterItem {
        
        enum Operation: String {
            case AND
            case OR
        }
        
        let field: String
        let value: EscapableString?
        let operation: Operation
        
        init(field: String, value: EscapableString?, operation: Operation = .AND) {
            self.field = field
            self.value = value
            self.operation = operation
        }
    }
}
