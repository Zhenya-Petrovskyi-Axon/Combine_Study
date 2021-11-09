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
        var configuration: UIButton.Configuration = .gray() // 1
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
    
    // MARK: - Subjects
    /// We will have subjects that allready have a value, instead of pass through to waur untill some event will happen
    private var emailSubject = CurrentValueSubject<String, Never>("")
    private var passwordSubject = CurrentValueSubject<String, Never>("")
    private var confirmSubject = CurrentValueSubject<String, Never>("")
    private var agreementSubject = CurrentValueSubject<Bool, Never>(false)
    
    private var cancellables: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpView()
        setUpPublisherCompletions()
    }
    
    private func setUpPublisherCompletions() {
        formIsValid
            .assign(to: \.isEnabled, on: self.signupButton)
            .store(in: &cancellables)
        
        setValidBorder(emailField, publisher: isEmailValid)
        setValidBorder(passwordField, publisher: isPasswordValid)
        setValidBorder(confirmPasswordField, publisher: isPasswordConfirmed)
        
        formattedEmailAdress
            .map { $0 as String? } // <-- we need to cast it as textfield takes only optional Strings
            .assign(to: \.text, on: emailField)
            .store(in: &cancellables)
    }
    
    func setValidBorder<P: Publisher>(_ textField: UITextField, publisher: P) where P.Output == Bool, P.Failure == Never {
        publisher
            .map { $0 ? UIColor.label : UIColor.systemRed }
            .assign(to: \.textColor, on: textField)
            .store(in: &cancellables)
    }
    
    private func emailIsValid(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }
    
    // MARK: - Publishers
    private var formIsValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(isEmailValid, passIsValidAndConfirmed, agreementSubject)
            .map { emailValid, passConfirmed, termsAgreed in
                emailValid && passConfirmed && termsAgreed
            }
            .eraseToAnyPublisher()
    }
    
    private var isEmailValid: AnyPublisher<Bool, Never> {
        formattedEmailAdress
            .map { [weak self] in self?.emailIsValid($0) }
            .replaceNil(with: false)
            .eraseToAnyPublisher()
    }
    
    private var formattedEmailAdress: AnyPublisher<String, Never> {
        emailSubject
            .map { $0.lowercased() }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordValid: AnyPublisher<Bool, Never> {
        passwordSubject
            .map { $0 != "password" && $0.count >= 8 }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordConfirmed: AnyPublisher<Bool, Never> {
        passwordSubject.combineLatest(confirmSubject)
            .map { pass, confirmPass in
                pass == confirmPass
            }
            .eraseToAnyPublisher()
    }
    
    private var passIsValidAndConfirmed: AnyPublisher<Bool, Never> {
        isPasswordValid.combineLatest(isPasswordConfirmed)
            .map { valid, confirmed in
                valid && confirmed
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Text field actions
    private func emailDidChanged() {
        guard let text = emailField.text else { return }
        emailSubject.send(text)
    }
    
    private func passwordDidChanged() {
        guard let pass = passwordField.text else { return }
        passwordSubject.send(pass)
    }
    
    private func confirmPasswordDidChanged() {
        guard let confirmPass = confirmPasswordField.text else { return }
        confirmSubject.send(confirmPass)
    }
    
    private func setUpView() {
        view.addSubview(fieldsStackView)
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
}

extension ViewController {
    @objc func didTapSignInButton(_ sender: UIButton) {
        print("Tap")
    }
    
    @objc func didChangeSwitch(_ sender: UISwitch) {
        agreementSubject.send(sender.isOn)
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

