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

struct SearchOptions {
    let start: Int?
    let rows: Int?
    let sortBy: String?
    let sortByAscending: Bool?
    let filterBy: [String: String]?
    let filterQuery: String?
    let searchText: String?
    let includeDocument: Bool?
}

class SearchConfigViewController: UIViewController {
    
    var onApplyOptions: ((SearchOptions) -> Void)!
    
    @IBOutlet private var searchTextField: UITextField!
    @IBOutlet private var filterQueryTextField: UITextField!
    @IBOutlet private var startTextField: UITextField!
    @IBOutlet private var pageSizeTextField: UITextField!
    @IBOutlet private var sortByTextField: UITextField!
    @IBOutlet private var sortByOrderSwitch: UISwitch!
    @IBOutlet private var filterByTableView: UITableView!
    @IBOutlet private var includeDocument: UISwitch!
    
    private var filterByItems: [FilterByEnty] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filterByTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setOptions(originalOptions)
    }
    
    private var originalOptions: SearchOptions?
    
    func configureWithOptions(_ options: SearchOptions?) {
        originalOptions = options
    }
        
    private func setOptions(_ options: SearchOptions?) {
        guard let options = options else { return }
        searchTextField.text = "\(options.searchText ?? "")"
        filterQueryTextField.text = "\(options.filterQuery ?? "")"
        if let start = options.start {
            startTextField.text = "\(start)"
        }
        if let rows = options.rows {
            pageSizeTextField.text = "\(rows)"
        }
        sortByTextField.text = "\(options.sortBy ?? "")"
        if let ascendning = options.sortByAscending {
          sortByOrderSwitch.setOn(ascendning, animated: false)
        }
        if let include = options.includeDocument {
            includeDocument.setOn(include, animated: false)
        }
        if let filerBy = options.filterBy {
            filterByItems = filerBy.map { return FilterByEnty(key: $0, value: $1) }
        } else {
            filterByItems = []
        }
        filterByTableView.reloadData()
    }
    
    @IBAction private func onApplyPressed(_ sender: UIButton) {
        onApplyOptions(searchOptions)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onResetPressed(_ sender: UIButton) {
        searchTextField.text = ""
        filterQueryTextField.text = ""
        startTextField.text = ""
        pageSizeTextField.text = ""
        sortByTextField.text = ""
        sortByOrderSwitch.setOn(false, animated: true)
        filterByItems = []
        filterByTableView.reloadData()
        includeDocument.setOn(true, animated: true)
    }
    
    @IBAction private func onSortByOrderChange(_ sender: UISwitch) {}
    
    @IBAction private func onIncludeDocumentChange(_ sender: UISwitch) {}
    
    var searchOptions: SearchOptions {
        return SearchOptions(
            start: Int(startTextField.text!),
            rows: Int(pageSizeTextField.text!),
            sortBy: sortByTextField.text == "" ? nil : sortByTextField.text,
            sortByAscending: sortByOrderSwitch.isOn,
            filterBy: filterByItems.reduce(into: [:]) { $0[$1.key] = $1.value },
            filterQuery: filterQueryTextField.text == "" ? nil : filterQueryTextField.text,
            searchText: searchTextField.text == "" ? nil : searchTextField.text,
            includeDocument: includeDocument.isOn
        )
    }
}

extension SearchConfigViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterByItems.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row < filterByItems.count) {
            let enrty = filterByItems[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterByEntryCell", for: indexPath) as? FilterByEntryCell else {
                fatalError("Cannot deque cell with FilterByEntryCell identifier")
            }
            cell.keyLabel.text = enrty.key
            cell.valueLabel.text = enrty.value
            cell.selectionStyle = .none
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterByAddCell", for: indexPath) as? FilterByAddCell else {
            fatalError("Cannot deque cell with FilterByEntryCell identifier")
        }
        cell.onAdd = addNewEntry
        cell.selectionStyle = .none
        return cell
    }
    
    func addNewEntry(_ newKey: String, _ newValue: String) {
        filterByItems.append(FilterByEnty(key: newKey, value: newValue))
        filterByTableView.reloadData()
    }
}

struct FilterByEnty {
    let key: String
    let value: String
}

class FilterByEntryCell: UITableViewCell {
    @IBOutlet var keyLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
}

class FilterByAddCell: UITableViewCell {
    @IBOutlet var keyTextField: UITextField!
    @IBOutlet var valueTextField: UITextField!
    var onAdd: (String, String) -> Void = { _, _ in }
    
    @IBAction func add(_ sender: UIButton) {
        guard keyTextField.text!.isEmpty == false,
            valueTextField.text!.isEmpty == false else {
                return
        }
        onAdd(keyTextField.text!, valueTextField.text!)
        keyTextField.text = ""
        valueTextField.text = ""
        endEditing(true)
    }
}
