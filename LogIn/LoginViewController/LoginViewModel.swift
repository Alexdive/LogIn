//
//  LoginViewModel.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 27.12.2021.
//

import Foundation
import Combine

protocol LoginViewModelType {
    var presentationObject: LoginViewPresentationObject { get }
    func transform(input: LoginViewModelInput) -> AnyPublisher<LoginViewModelOutput, Never>
    func onLoginTap()
}

struct LoginViewModel: LoginViewModelType {
    
    let presentationObject = LoginViewPresentationObject()
    
    func onLoginTap() {
        print("Log in")
    }
    
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
        
        let loginState = input.loginState
            .map { $0 }
        
        let isValidEmail = email
            .map { self.isValidEmail($0) }
        
        let isValidPassword = password
            .map { $0.count > 6 }
        
        let isSamePassword = password.combineLatest(passwordAgain)
            .map { $0 == $1 }
        
        return isValidEmail
            .combineLatest(isValidPassword, isSamePassword, loginState)
            .map { isValidEmail, isValidPassword, isSamePassword, loginState in
                var loginEnabled = false
                var signUpEnabled = false
                if case loginState = LoginState.signup {
                    signUpEnabled = isValidEmail && isValidPassword && isSamePassword
                    loginEnabled = true
                } else {
                    loginEnabled = isValidEmail && isValidPassword
                    signUpEnabled = true
                }
                return LoginViewModelOutput(emailTint: isValidEmail ? .systemGreen : .systemRed,
                                            passwTint: isValidPassword ? .systemGreen : .systemGray2,
                                            passwAgainTint: isValidPassword && isSamePassword ? .systemGreen : .systemGray2,
                                            loginEnabled: loginEnabled,
                                            signUpEnabled: signUpEnabled)
            }
            .eraseToAnyPublisher()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
