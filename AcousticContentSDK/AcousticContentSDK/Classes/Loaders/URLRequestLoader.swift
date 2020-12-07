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

/// Set of loader errors
enum URLRequestLoaderError: Error {
    case noResponse
    case noResponseData
    case unknown
}

/// Concrete http requests loader.
class URLRequestLoader: RequestSession {
    
    internal init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    private let urlSession: URLSession
    
    func load(request: Requestable, completion: @escaping RequestCompletion) {
        guard let urlRequest = request.urlRequest else {
            completion(.failure(URLRequestLoaderError.unknown, nil))
            return
        }
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            guard let urlResponse = response as? HTTPURLResponse else {
                completion(.failure(URLRequestLoaderError.noResponse, nil))
                return
            }
            if let error = error {
                completion(.failure(error, urlResponse))
                return
            }
            guard let data = data else {
                completion(.failure(URLRequestLoaderError.noResponseData, urlResponse))
                return
            }
            completion(.success(data, urlResponse))
            
        }
        task.resume()
    }
}
