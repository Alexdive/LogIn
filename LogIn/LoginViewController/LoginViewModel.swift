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

class LoginViewModel: LoginViewModelType {
    
    var loginState: LoginState = .login {
        didSet {
            if loginState == .login {
                
            } else {
                
            }
        }
    }
    var canc = Set<AnyCancellable>()
    let presentationObject = LoginViewPresentationObject()
   
    func onLoginTap() {
        print("Log in")
    }
    
    func onSignUpTap() {
        print("sign up")
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
        
        let signupTap = input.signUpTap
            .sink { self.onSignUpTap() }
            .store(in: &canc)
        
        
        let loginTap = input.loginTap
            .sink { self.onLoginTap() }
            .store(in: &canc)
        
        let isValidEmail = email
            .map { self.isValidEmail($0) }
        
        let isValidPassword = password
            .map { $0.count > 6 }
        
        let isSamePassword = password.combineLatest(passwordAgain)
            .map { $0 == $1 }
        
        let output: AnyPublisher<LoginViewModelOutput, Never> = isValidEmail
            .combineLatest(isValidPassword, isSamePassword)
            .map { isValidEmail, isValidPassword, isSamePassword in
                var loginEnabled = false
                var signUpEnabled = false
                if case self.loginState = LoginState.signup {
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
        
        return output
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
