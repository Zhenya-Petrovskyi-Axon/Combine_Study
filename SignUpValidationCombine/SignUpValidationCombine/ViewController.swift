//
//  ViewController.swift
//  SignUpValidationCombine
//
//  Created by Ievgen Petrovskiy on 09.11.2021.
//

/*
 Sign Up form Rules
 - email adress must be valid (contain @ and .)
 - password must be at least 8 characters
 - password can not be "password"
 BONUS
 - color email field red when invalid, password confirmation field red when it doesen't match the original password
 - email adress must remove spaces, lowercased
 */

enum TextFieldTags: Int {
    case email
    case password
    case confirmPassword
}

import UIKit
import Combine

class ViewController: UIViewController {
    
    private lazy var emailField: UITextField = {
        let view = UITextField()
        view.textAlignment = .left
        view.borderStyle = .line
        view.tag = 0
        return view
    }()
    
    private lazy var passwordField: UITextField = {
        let view = UITextField()
        view.textAlignment = .left
        view.borderStyle = .line
        view.tag = 1
        return view
    }()
    
    private lazy var confirmPasswordField: UITextField = {
        let view = UITextField()
        view.textAlignment = .left
        view.borderStyle = .line
        view.tag = 2
        return view
    }()
    
    private lazy var termsAgreementSwitcher: UISwitch = {
        let view = UISwitch()
        view.addTarget(self, action: #selector(didChangeSwitch), for: .valueChanged)
        view.isOn = false
        return view
    }()
    
    private lazy var signupButton: UIButton = {
        var configuration: UIButton.Configuration = .filled()
        configuration.cornerStyle = .capsule
        configuration.cornerStyle = .capsule // 2
        configuration.baseForegroundColor = UIColor.systemPink
        configuration.buttonSize = .large
        configuration.title = "Sign Up"
        
        let view = UIButton(configuration: configuration, primaryAction: nil)
        view.addTarget(self, action: #selector(didTapSignInButton), for: .touchUpInside)
        return view
    }()
    
    private lazy var fieldsStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .equalSpacing
        view.alignment = .fill
        view.axis = .vertical
        view.spacing = 12
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 73, leading: 16, bottom: 0, trailing: 16)
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    private lazy var agreementLabel: UILabel = {
        let view = UILabel()
        view.text = "I agree the Terms"
        return view
    }()
    
    private lazy var agreementStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = .fill
        view.axis = .horizontal
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.center = self.view.center
        view.hidesWhenStopped = true
        view.stopAnimating()
        return view
    }()
    
    let viewModel = SignInViewModel()
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpView()
        setUpPublisherCompletions()
    }
    
    private func setUpPublisherCompletions() {
        viewModel.formIsValid
            .assign(to: \.isEnabled, on: self.signupButton)
            .store(in: &cancellables)
        
        viewModel.formattedEmailAdress
            .map { $0 as String? } // <-- we need to cast it as textfield takes only optional Strings
            .assign(to: \.text, on: emailField)
            .store(in: &cancellables)
        
        setValidBorder(emailField, publisher: viewModel.isEmailValid)
        setValidBorder(passwordField, publisher: viewModel.isPasswordValid)
        setValidBorder(confirmPasswordField, publisher: viewModel.isPasswordConfirmed)
    }
    
    // MARK: - Text field actions
    private func emailDidChanged() {
        guard let text = emailField.text else { return }
        viewModel.emailSubject.send(text)
    }
    
    private func passwordDidChanged() {
        guard let pass = passwordField.text else { return }
        viewModel.passwordSubject.send(pass)
    }
    
    private func confirmPasswordDidChanged() {
        guard let confirmPass = confirmPasswordField.text else { return }
        viewModel.confirmSubject.send(confirmPass)
    }
    
    private func setUpView() {
        [fieldsStackView, activityIndicator].forEach {
            view.addSubview($0)
        }
        view.addSubview(fieldsStackView)
        view.addSubview(activityIndicator)
        [agreementLabel, termsAgreementSwitcher].forEach {
            agreementStackView.addArrangedSubview($0)
        }
        [emailField, passwordField, confirmPasswordField].forEach {
            $0.delegate = self
            $0.borderStyle = .roundedRect
        }
        [emailField, passwordField, confirmPasswordField, agreementStackView, signupButton].forEach {
            fieldsStackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            fieldsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            fieldsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fieldsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        view.layoutIfNeeded()
    }
    
    func setValidBorder<P: Publisher>(_ textField: UITextField, publisher: P) where P.Output == Bool, P.Failure == Never {
        publisher
            .map { $0 ? UIColor.label : UIColor.systemRed }
            .assign(to: \.textColor, on: textField)
            .store(in: &cancellables)
    }
}

extension ViewController {
    @objc func didTapSignInButton(_ sender: UIButton) {
        activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
    
    @objc func didChangeSwitch(_ sender: UISwitch) {
        viewModel.agreementSubject.send(sender.isOn)
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let textfieldTag = TextFieldTags(rawValue: textField.tag) else { return }
        
        switch textfieldTag {
        case .email:
            emailDidChanged()
        case .password:
            passwordDidChanged()
        case .confirmPassword:
            confirmPasswordDidChanged()
        }
    }
}

