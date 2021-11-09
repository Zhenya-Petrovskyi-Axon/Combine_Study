//
//  SignInViewModel.swift
//  SignUpValidationCombine
//
//  Created by Ievgen Petrovskiy on 09.11.2021.
//

import Foundation
import Combine

protocol SignInViewModeling {
    func signInButtonTapped()
}

class SignInViewModel {
    // MARK: - Subjects
    /// We will have subjects that allready have a value, instead of pass through to waur untill some event will happen
    var emailSubject = CurrentValueSubject<String, Never>("")
    var passwordSubject = CurrentValueSubject<String, Never>("")
    var confirmSubject = CurrentValueSubject<String, Never>("")
    var agreementSubject = CurrentValueSubject<Bool, Never>(false)
    
    private var cancellables: Set<AnyCancellable> = []
    
    private func emailIsValid(_ email: String) -> Bool {
        email.contains("@") && email.contains(".")
    }
    
    // MARK: - Publishers
    var formIsValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(isEmailValid, passIsValidAndConfirmed, agreementSubject)
            .map { emailValid, passConfirmed, termsAgreed in
                emailValid && passConfirmed && termsAgreed
            }
            .eraseToAnyPublisher()
    }
    
    var isEmailValid: AnyPublisher<Bool, Never> {
        formattedEmailAdress
            .map { [weak self] in self?.emailIsValid($0) }
            .replaceNil(with: false)
            .eraseToAnyPublisher()
    }
    
    var formattedEmailAdress: AnyPublisher<String, Never> {
        emailSubject
            .map { $0.lowercased() }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .eraseToAnyPublisher()
    }
    
    var isPasswordValid: AnyPublisher<Bool, Never> {
        passwordSubject
            .map { $0 != "password" && $0.count >= 8 }
            .eraseToAnyPublisher()
    }
    
    var isPasswordConfirmed: AnyPublisher<Bool, Never> {
        passwordSubject.combineLatest(confirmSubject)
            .map { pass, confirmPass in
                pass == confirmPass
            }
            .eraseToAnyPublisher()
    }
    
    var passIsValidAndConfirmed: AnyPublisher<Bool, Never> {
        isPasswordValid.combineLatest(isPasswordConfirmed)
            .map { valid, confirmed in
                valid && confirmed
            }
            .eraseToAnyPublisher()
    }
}
