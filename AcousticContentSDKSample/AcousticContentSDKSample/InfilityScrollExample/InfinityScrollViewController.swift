//
// Copyright 2020 Acoustic, L.P.
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//

import UIKit
import AcousticContentSDK
import SafariServices

class InfinityScrollViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var totalCountLabel: UILabel!
    
    /// Acoustic Content SDK instance.
    private var acousticContentSDK: AcousticContentSDK!
    /// Local documents set for displaying in table view.
    private var items: [Asset] = []
    /// Documents provider for the next page.
    private var nextPage: Documents<Asset>?
    private var loading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// SDK Setup:
        /// Prepare API URL
        let apiURL = URL(string: AcousticContent.baseUrl + "/api/" + AcousticContent.tenantId)!
        /// Make a configuration object using api url.
        let config = AcousticContentSDK.Config(apiURL: apiURL)
        /// Make a SDK instance with prepared configuration object.
        acousticContentSDK = AcousticContentSDK(withConfig: config)
        
        self.title = "Assets"
        tableView.tableFooterView = UIView()
        let refreshView = UIRefreshControl()
        refreshView.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        tableView.refreshControl = refreshView
        
        /// Get an instace of Delivery Search object.
        let deliverySearch = acousticContentSDK.deliverySearch()
        /// Get a document provider from delivery search object.
        let assets = deliverySearch.assets()
        loadMore(with: assets)
    }
    
    @objc func refresh(_ sender: UIRefreshControl, _ value: Any) {
        /// Pull to refresh resets search configuration, clears table view and starts a new documents get call.
        items = []
        tableView.reloadData()
        /// Get a new instace of Delivery Search object.
        let deliverySearch = acousticContentSDK.deliverySearch()
        /// Get a new document provider from delivery search object.
        let assets = deliverySearch.assets()
        loadMore(with: assets)
        sender.endRefreshing()
    }
    
    func loadMore(with provider: Documents<Asset>) {
        /// This check is unrelated to the sdk functionality. Sample is using boolean flag for marking loading
        /// and that flag is set on main queue. That is why this function has to be called on main queue.
        /// You can call sdk methods from any othe queue.
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        if loading { return }
        loading = true
        /// Call `get` to get a set of documents for search parameters set to that provider.
        provider.get() { result in
            DispatchQueue.main.async {
                /// Handle call results by checking `result.error` first. In case everything went OK `result.error` supposed to be `nil`.
                if let error = result.error {
                    self.handleError(error)
                    return
                }
                /// Get documents from `get` call result.
                let resultItems = result.documents
                /// Add newly downloaded documents to the table view.
                self.items.append(contentsOf: resultItems)
                self.tableView.reloadData()
                /// Save next page documents provider for future use.
                self.nextPage = result.nextPage()
                self.loading = false
                /// Get a total number of documents across all pages for the current search configuration.
                let totalNumberOfDocumentsInSearch = result.numFound
                self.totalCountLabel.text = "Items: \(self.items.count) of \(totalNumberOfDocumentsInSearch)"
            }
        }
    }
    
    func handleError(_ error: DeliverySearchError) {
        let alertVC = UIAlertController(title: "Error occurred", message: "Assets load failed:\n\(error)", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Close", style: .default) { _ in
            alertVC.dismiss(animated: true, completion: nil)
        })
        self.present(alertVC, animated: true, completion: nil)
    }
}

extension InfinityScrollViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssetCell", for: indexPath) as? AssetCell else {
            fatalError("Can not deque cell with AssetCell identifier")
        }
        cell.nameLabel.text = items[indexPath.row].name
        cell.typeLabel.text = items[indexPath.row].mediaType
        cell.createdLabel.text = items[indexPath.row].mediaType
        cell.assetSizeLabel.text = "\(items[indexPath.row].fileSize / 1024) Kb"
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row == items.count - 1) {
            if let nextPage = nextPage {
                /// Use next page documents provider for loading documents for the next page.
                loadMore(with: nextPage)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// By tapping on a document cell user will be redirected to safari web page for that document.
        /// Construct document url by adding `Asset.url` to the api base url.
        let urlString = AcousticContent.baseUrl + items[indexPath.row].url
        guard let url = URL(string: urlString) else {
            fatalError("Can not create url from \(urlString)")
        }
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
}

class AssetCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var createdLabel: UILabel!
    @IBOutlet var assetSizeLabel: UILabel!
}
