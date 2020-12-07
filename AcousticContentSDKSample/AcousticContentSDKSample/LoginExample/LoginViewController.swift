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

class LoginViewController: UIViewController {
    
    @IBOutlet var loginTextField: UITextField!
    @IBOutlet var passTextField: UITextField!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    private var acousticContentSDK: AcousticContentSDK!
    
    func configure(sdk: AcousticContentSDK) {
        acousticContentSDK = sdk
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.loginTextField.text = ""
        self.passTextField.text = ""
    }
    
    @IBAction func onLoginButtonPress(_ sender: UIButton) {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        
        guard let username = loginTextField.text, let password = passTextField.text else {
            return
        }
        
        /// Perform login with username and password.
        acousticContentSDK.login(username: username, password: password) { [weak self] loginSucceeded, error in
            guard let self = self else { return }
            let message: String
            if let error = error {
                message = error.description
            } else {
                message = "Login successful"
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                let alertVC = UIAlertController.init(title: "", message: message, preferredStyle: .alert)
                alertVC.addAction(UIAlertAction.init(title: "Continue", style: .default) { _ in
                    alertVC.dismiss(animated: true) { [weak self] in
                        guard let self = self else { return }
                        self.navigationController?.popViewController(animated: true)
                    }
                })
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onLogout(_ sender: UIButton) {
        /// Perform logout.
        acousticContentSDK.logout { [weak self] in
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
}

extension LoginError {
    var description: String {
        switch self {
        case .authenticationFailedWithCredentials:
            return "Authentication failed with credentials (incorrect or missing)"
        case .accessForbidden:
            return "Access forbidden (e.g. no access to tenant or enterprise federation)"
        case .tenantNotFound:
            return "Tenant not found"
        case .preconditionFailedForCredentials:
            return "Precondition Failed for credentials (incorrect format or missing)"
        case .tenantIsLocked:
            return "The tenant is locked"
        case .tooManyRequests(let acousticError):
            return """
            Too Many Requests, the server has reached a limit,
            the request must be sent again at a later time.
            Error desciprion: \(acousticError?.description ?? "none")
            """
        case .downstreamServiceNotAvailable:
            return "Downstream service not available (e.g. IBMid)"
        case .unknown:
            return "Unknown"
        @unknown default:
            return "Unknown"
        }
    }
}
