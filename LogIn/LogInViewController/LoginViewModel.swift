//
//  LoginViewModel.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 08.12.2021.
//

import UIKit
import Combine

protocol LoginViewModelType {
    var presentationObject: LoginViewPresentationObject { get }
    func transform(input: LoginViewModelInput) -> AnyPublisher<LoginViewModelOutput, Never>
}

struct LoginViewModel: LoginViewModelType {
    let presentationObject = LoginViewPresentationObject()
    
    func transform(input: LoginViewModelInput) -> AnyPublisher<LoginViewModelOutput, Never> {
        let email = input.email
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .removeDuplicates()
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        
        let password = input.pass
            .removeDuplicates()
            .compactMap { $0 }
        
        let passwordAgain = input.passAgain
            .removeDuplicates()
            .compactMap { $0 }
        
        let isValidEmail = email
            .map { self.isValidEmail($0) }
        
        let isValidPassword = password
            .map { $0.count > 6 }
        
        let isSamePassword = password.combineLatest(passwordAgain)
            .map { $0 == $1 }
        
        return isValidEmail
            .combineLatest(isValidPassword, isSamePassword)
            .map { isValidEmail, isValidPassword, isSamePassword in
                LoginViewModelOutput(emailTint: isValidEmail ? .systemGreen : .systemGray2,
                                     passwTint: isValidPassword ? .systemGreen : .systemGray2,
                                     passwAgainTint: isValidPassword && isSamePassword ? .systemGreen : .systemGray2,
                                     emailErrorText: isValidEmail ? "" : "Incorrect email format",
                                     isEnabled: isValidEmail && isValidPassword && isSamePassword)
            }
            .eraseToAnyPublisher()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
