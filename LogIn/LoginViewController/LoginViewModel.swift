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

typealias VoidTrigger = PassthroughSubject<Void, Never>

protocol LoginViewModelType {
    var presentationObject: LoginViewPresentationObject { get }
    var transitionToLogin: VoidTrigger { get }
    var transitionToSignUp: VoidTrigger { get }
    var onLogin: VoidTrigger { get }
    var showError: PassthroughSubject<String, Never> { get }
    func transform(input: LoginViewModelInput) -> AnyPublisher<LoginViewModelOutput, Never>
}

final class LoginViewModel: LoginViewModelType {
    let presentationObject = LoginViewPresentationObject()
    var transitionToLogin = VoidTrigger()
    var transitionToSignUp = VoidTrigger()
    var onLogin = VoidTrigger()
    var showError = PassthroughSubject<String, Never>()
    
    private var cancellable = Set<AnyCancellable>()
    
    private var loginState: LoginState = .login {
        didSet {
            if loginState == .login {
                transitionToLogin.send()
            } else {
                transitionToSignUp.send()
            }
        }
    }
    
    private lazy var onErrorCompletion: ((Subscribers.Completion<Error>) -> Void) = { [unowned self] completion in
        switch completion {
        case .finished:
            print("🏁 finished")
        case .failure(let error):
            self.showError.send(error.localizedDescription)
            print("❗️ failure: \(error.localizedDescription)")
        }
    }
    
    private lazy var onValueCompletion: () -> Void = { [unowned self] in
        self.onLogin.send()
        self.loginState = .login
    }
    
    typealias LoginService = (_ state: LoginState, _ email: String, _ password: String) -> AnyPublisher<Void, Error>
    let loginService: LoginService
    
    init(loginService: @escaping LoginService) {
        self.loginService = loginService
    }
    
    private func onSwitchStateTap() {
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
        
        input.switchStateTap
            .sink { self.onSwitchStateTap() }
            .store(in: &cancellable)
        
        input.loginTap
            .combineLatest(email, password)
            .flatMap { [unowned self] _, email, password in
                self.loginService(self.loginState, email, password)
            }
            .sink(receiveCompletion: onErrorCompletion, receiveValue: onValueCompletion)
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
