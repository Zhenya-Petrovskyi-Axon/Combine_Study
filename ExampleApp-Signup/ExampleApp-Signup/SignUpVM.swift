//
//  SignUpVM.swift
//  ExampleApp-Signup
//
//  Created by Ievgen Petrovskiy on 14.11.2021.
//

import Combine
import UIKit

// SIGN UP FORM RULES
// - email address must be valid (contain @ and .)
// - password must be at least 8 characters
// - password cannot be "password"
// - password confirmation must match
// - must agree to terms
// - BONUS: color email field red when invalid, password confirmation field red when it doesn't match the password
// - BONUS: email address must remove spaces, lowercased

class SignUpVM {
    // Subjects
    @Published
    var email = "" // Same as emailSubject
//    var emailSubject = CurrentValueSubject<String, Never>("")
    @Published
    var password = ""
    
    @Published
    var passwordConfirmation = ""
    
    @Published
    var agreeTerms: Bool = false
    
    // UIState
    @Published
    var emailFieldColor: UIColor?
    @Published
    var passwordFieldTextColor: UIColor?
    @Published
    var passwordConfirmationFieldTextColor: UIColor?
    
    // Actions
    @Published
    var signUpButtonEnabled: Bool = false
    
    init() {
        setUpPipeLine()
    }
    
    private func setUpPipeLine() {
        configureEmailAddressBehaviour()
        configurePasswordBehaviour()
        configureSignUpButtonBehaviour()
    }
    
    private func configureEmailAddressBehaviour() {
        formattedEmailAddress
            .removeDuplicates()
            .assign(to: &$email)
        
        validEmailAddress
            .mapToInputColor()
            .assign(to: &$emailFieldColor)
    }
    
    private func configurePasswordBehaviour() {
        validPassword
            .mapToInputColor()
            .assign(to: &$passwordFieldTextColor)
        
        passwordMatchesConfirmation
            .mapToInputColor()
            .assign(to: &$passwordConfirmationFieldTextColor)
    }
    
    private func configureSignUpButtonBehaviour() {
        formIsValid
            .assign(to: &$signUpButtonEnabled)
    }
    
    var formattedEmailAddress: AnyPublisher<String, Never> {
        $email
            .map {
                $0.lowercased()
                    .replacingOccurrences(of: " ", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .eraseToAnyPublisher()
    }
    
    var formIsValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(
            validEmailAddress, validAndConfirmedPassword, $agreeTerms
        ).map { email, pw, terms in
            email && pw && terms
        }
        .eraseToAnyPublisher()
    }
    
    var passwordMatchesConfirmation: AnyPublisher<Bool, Never> {
        $password.combineLatest($passwordConfirmation)
            .map { pass, confirm in
                pass == confirm
            }
            .eraseToAnyPublisher()
    }
    
    var validPassword: AnyPublisher<Bool, Never> {
        $password
            .map {
                $0 != "password" && $0.count >= 8
            }
            .eraseToAnyPublisher()
    }
    
    var validAndConfirmedPassword: AnyPublisher<Bool, Never> {
        validPassword.combineLatest(passwordMatchesConfirmation)
            .map { $0.0 && $0.1}
            .eraseToAnyPublisher()
    }
    
    var validEmailAddress: AnyPublisher<Bool, Never> {
        $email
            .map { [unowned self] in
                isValidEmailAddress($0)
            }
            .eraseToAnyPublisher()
    }
    
    private func isValidEmailAddress(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }
    
}

extension Publisher where Output == Bool, Failure == Never {
    func mapToInputColor() -> AnyPublisher<UIColor?, Never> {
        map { isValid -> UIColor in
            isValid ? .label : .systemRed
        }
        .eraseToAnyPublisher()
    }
}












