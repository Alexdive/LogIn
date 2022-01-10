//
//  LoginViewModel.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 27.12.2021.
//

import Foundation
import Combine

enum LoginState {
    case login
    case signup
}

protocol LoginViewModelType {
    var presentationObject: LoginViewPresentationObject { get }
    func transform(input: LoginViewModelInput) -> AnyPublisher<LoginViewModelOutput, Never>
    var transitionToLogin: (() -> Void)? { get set }
    var transitionToSignUp: (() -> Void)? { get set }
}

final class LoginViewModel: LoginViewModelType {
    
    var transitionToLogin: (() -> Void)?
    var transitionToSignUp: (() -> Void)?
    let presentationObject = LoginViewPresentationObject()
    
    private var cancellable = Set<AnyCancellable>()
    private var loginState: LoginState = .login {
        didSet {
            if loginState == .login {
                transitionToLogin?()
            } else {
                transitionToSignUp?()
            }
        }
    }
    
    private func onLoginTap(email: String, passw: String) {
        if loginState == .login {
            print("Log in", email, passw)
        } else {
            print("Sign up", email, passw)
        }
    }
    
    private func onSignUpTap() {
        if loginState == .login {
            loginState = .signup
        } else {
            loginState = .login
        }
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
        
        var emailString = ""
        var passwString = ""
        
        email
            .sink { emailString = $0 }
            .store(in: &cancellable)
        
        password
            .sink { passwString = $0 }
            .store(in: &cancellable)
        
        input.signUpTap
            .sink { self.onSignUpTap() }
            .store(in: &cancellable)
        
        input.loginTap
            .sink { self.onLoginTap(email: emailString, passw: passwString) }
            .store(in: &cancellable)
        
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
                if case self.loginState = LoginState.signup {
                    loginEnabled = isValidEmail && isValidPassword && isSamePassword
                } else {
                    loginEnabled = isValidEmail && isValidPassword
                }
                return LoginViewModelOutput(emailTint: isValidEmail ? .systemGreen : .systemRed,
                                            passwTint: isValidPassword ? .systemGreen : .systemGray2,
                                            passwAgainTint: isValidPassword && isSamePassword ? .systemGreen : .systemGray2,
                                            loginEnabled: loginEnabled)
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
