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

public class Assets: Documents<Asset>, PreviewConfigurable {
    
    /// Configures provider to retrieve draft content. _Require authentication_.
    /// - Parameter include: `true` if draft content needs to be requested. `false` othewise.
    @discardableResult
    public func includeDraft(_ include: Bool = true) -> Self {
        requestConfig.includeDraft = include
        return self
    }
    
    /// Configures provider to retrieve retired content. _Require authentication_.
    /// - Parameter include: `true` if retired content needs to be requested. `false` othewise.
    @discardableResult
    public func includeRetired(_ include: Bool = true) -> Self {
        requestConfig.includeRetired = include
        return self
    }
}
