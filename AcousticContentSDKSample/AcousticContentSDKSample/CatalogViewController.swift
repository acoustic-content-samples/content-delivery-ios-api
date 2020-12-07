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

/// Screen displaying a list of SDK features.
class CatalogViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    private var acousticContentSDK: AcousticContentSDK!
    
    private let items: [CatalogItem] = [
        .login,
        .assets,
        .contentItemSearch,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "SDK Catalog"
        tableView.tableFooterView = UIView()
        /// SDK Setup:
        /// Prepare API URL
        let apiURL = URL(string: AcousticContent.baseUrl + "/api/" + AcousticContent.tenantId)!
        /// Make a configuration object using api url.
        let config = AcousticContentSDK.Config(apiURL: apiURL)
        /// Make a SDK instance with prepared configuration object.
        acousticContentSDK = AcousticContentSDK(withConfig: config)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "loginSegue") {
            guard let destination = segue.destination as? LoginViewController else {
                assertionFailure("Expected VC of type LoginViewController for the loginSegue")
                return
            }
            /// Pass an instance of sdk to the login screen.
            destination.configure(sdk: acousticContentSDK)
        }
    }
}

extension CatalogViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch items[indexPath.row] {
        case .login:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "loginCellIdenetifier")
            cell.textLabel!.text = "Login"
            /// Getting Authorization status.
            let authorized = acousticContentSDK.isAuthorized
            cell.detailTextLabel!.text = authorized ? "Authorized" : "Unauthorized"
            return cell
        case .assets:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "assetsCellIdenetifier")
            cell.textLabel!.text = "Infinity scroll"
            return cell
        case .contentItemSearch:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: "contentItemsCellIdenetifier")
            cell.textLabel!.text = "Configured Search"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch items[indexPath.row] {
        case .login:
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        case .assets:
            self.performSegue(withIdentifier: "assetsSegue", sender: nil)
        case .contentItemSearch:
            self.performSegue(withIdentifier: "contentItemsSearchSegue", sender: nil)
        }
    }
}

enum CatalogItem {
    case login
    case assets
    case contentItemSearch
}
