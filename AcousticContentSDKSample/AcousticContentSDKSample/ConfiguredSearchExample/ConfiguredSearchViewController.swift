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

class ConfiguredSearchViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var totalCountLabel: UILabel!
    
    /// Acoustic Content SDK instance.
    private var acousticContentSDK: AcousticContentSDK!
    /// Local documents set for displaying in table view.
    private var items: [ContentItem] = []
    /// Documents provider for the next page.
    private var nextPage: Documents<ContentItem>?
    private var loading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Content Items Search"
        tableView.tableFooterView = UIView()
        
        /// SDK Setup:
        /// Prepare API URL
        let apiURL = URL(string: AcousticContent.baseUrl + "/api/" + AcousticContent.tenantId)!
        /// Make a configuration object using api url.
        let config = AcousticContentSDK.Config(apiURL: apiURL)
        /// Make a SDK instance with prepared configuration object.
        acousticContentSDK = AcousticContentSDK(withConfig: config)
        /// Get an instace of Delivery Search object.
        let deliverySearch = acousticContentSDK.deliverySearch()
        /// Get a document provider from delivery search object.
        let contentItems = deliverySearch.contentItems()
        loadMore(with: contentItems)
    }
    
    func loadMore(with provider: Documents<ContentItem>) {
        /// This check is unrelated to the sdk functionality. Sample is using boolean flag for marking loading
        /// and that flag is set on main queue. That is why this function has to be called on main queue.
        /// You can call sdk methods from any othe queue.
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        if loading { return }
        loading = true
        /// Call `get` to get a set of documents for search parameters set to that provider.
        provider.get() { result in
            /// Handle call results by checking `result.error` first. In case everything went OK `result.error` supposed to be `nil`.
            DispatchQueue.main.async {
                self.loading = false
                if let error = result.error {
                    self.handleError(error)
                    return
                }
                /// Get documents from `get` call result.
                let resultItems = result.documents
                if (result.documents.isEmpty == false) {
                    /// Save next page documents provider for future use.
                    self.nextPage = result.nextPage()
                    /// Add newly downloaded documents to the table view.
                    self.items.append(contentsOf: resultItems)
                    self.tableView.reloadData()
                }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "configureSearchSegue",
            let searchConfigureVC = segue.destination as? SearchConfigViewController {
            self.totalCountLabel.text = "Items: "
            searchConfigureVC.configureWithOptions(previousSearchOptions)
            searchConfigureVC.onApplyOptions = { [weak self] options in
                guard let self = self else { return }
                self.previousSearchOptions = options
                
                self.items = []
                self.tableView.reloadData()
                self.nextPage = nil
                
                /// Get an instace of Delivery Search object.
                let deliverySearch = self.acousticContentSDK.deliverySearch()
                /// Get a document provider from delivery search object.
                let contentItems = deliverySearch.contentItems()
                if let start = options.start {
                    /// Configure initial element offset.
                    contentItems.start(start)
                }
                if let rows = options.rows {
                    /// Configure initial element per page count..
                    contentItems.rows(rows)
                }
                if let searchText = options.searchText {
                    /// Configure search text.
                    contentItems.searchText(searchText)
                }
                if let filterQuery = options.filterQuery {
                    /// Configure filter query for search.
                    contentItems.filterQuery(filterQuery)
                }
                if let sortBy = options.sortBy {
                    let ascending = options.sortByAscending ?? false
                    /// Configure search sorting.
                    contentItems.sortBy(sortBy, ascending: ascending)
                }
                if let includeDocument = options.includeDocument {
                    /// Configure adding document filed to search results.
                    contentItems.includeDocument(includeDocument)
                }
                if let filterBy = options.filterBy {
                    /// Configures filtering parameters.
                    contentItems.filterBy(filterBy)
                }
                /// Use newly configured content items provider to load documents.
                self.loadMore(with: contentItems)
            }
        }
    }
    
    private var previousSearchOptions: SearchOptions?
}

extension ConfiguredSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value2, reuseIdentifier: "contentItemCellIdenetifier")
        cell.textLabel!.text = items[indexPath.row].type
        cell.detailTextLabel!.text = items[indexPath.row].name
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        label.text = items[indexPath.row].tags?.joined(separator: ", ") ?? ""
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        cell.accessoryView = label
        cell.selectionStyle = .none
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
}
