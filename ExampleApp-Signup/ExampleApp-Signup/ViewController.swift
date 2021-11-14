//
//  ViewController.swift
//  ExampleApp-Signup
//
//  Created by Ben Scheirman on 8/19/20.
//

import UIKit
import Combine

// SIGN UP FORM RULES
// - email address must be valid (contain @ and .)
// - password must be at least 8 characters
// - password cannot be "password"
// - password confirmation must match
// - must agree to terms
// - BONUS: color email field red when invalid, password confirmation field red when it doesn't match the password
// - BONUS: email address must remove spaces, lowercased

class ViewController: UITableViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var emailAddressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var passwordConfirmationField: UITextField!
    @IBOutlet weak var agreeTermsSwitch: UISwitch!
    @IBOutlet weak var signUpButton: BigButton!
    
    private var viewModel = SignUpVM()
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - View Lifecycle
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.$email
            .map { $0 as String? }
            .assign(to: \.text, on: emailAddressField)
            .store(in: &cancellables)
        
        viewModel.$emailFieldColor
            .assign(to: \.textColor, on: emailAddressField)
            .store(in: &cancellables)
        
        viewModel.$passwordFieldTextColor
            .assign(to: \.textColor, on: passwordField)
            .store(in: &cancellables)
        
        viewModel.$passwordConfirmationFieldTextColor
            .assign(to: \.textColor, on: passwordConfirmationField)
            .store(in: &cancellables)
        
        viewModel.$signUpButtonEnabled
            .assign(to: \.isEnabled, on: signUpButton)
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @IBAction func emailDidChange(_ sender: Any) {
        viewModel.email = emailAddressField.text ?? ""
    }
    
    @IBAction func passwordDidChange(_ sender: Any) {
        viewModel.password = passwordField.text ?? ""
    }
    
    @IBAction func passwordConfirmationDidChange(_ sender: Any) {
        viewModel.passwordConfirmation = passwordConfirmationField.text ?? ""
    }
    
    @IBAction func agreeSwitchDidChange(_ sender: Any) {
        viewModel.agreeTerms = agreeTermsSwitch.isOn
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Welcome!", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
