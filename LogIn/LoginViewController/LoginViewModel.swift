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
    case restorePassword
}

typealias VoidTrigger = PassthroughSubject<Void, Never>

protocol LoginViewModelType {
    var presentationObject: LoginViewPresentationObject { get }
    var transitionToLogin: VoidTrigger { get }
    var transitionToSignUp: VoidTrigger { get }
    var transitionToRestorePassword: VoidTrigger { get }
    var messagePublisher: PassthroughSubject<String, Never> { get }
    var onLogin: VoidTrigger { get }
    var loadingPublisher: AnyPublisher<Bool, Never> { get }
    var errorPublisher: AnyPublisher<Error, Never> { get }
    func transform(input: LoginViewModelInput) -> AnyPublisher<LoginViewModelOutput, Never>
}

final class LoginViewModel: LoginViewModelType {
    let presentationObject = LoginViewPresentationObject()
    var transitionToLogin = VoidTrigger()
    var transitionToSignUp = VoidTrigger()
    var transitionToRestorePassword = VoidTrigger()
    var messagePublisher = PassthroughSubject<String, Never>()
    var onLogin = VoidTrigger()
    
    private var cancellable = Set<AnyCancellable>()
    
    let activityIndicator = ActivityIndicator()
    var loadingPublisher: AnyPublisher<Bool, Never> {
        activityIndicator.loading.eraseToAnyPublisher()
    }
    
    let errorIndicator = ErrorIndicator()
    var errorPublisher: AnyPublisher<Error, Never> {
        errorIndicator.errors.eraseToAnyPublisher()
    }
    
    private var loginState: LoginState = .login {
        didSet {
            switch loginState {
            case .login:
                transitionToLogin.send()
            case .signup:
                transitionToSignUp.send()
            case .restorePassword:
                transitionToRestorePassword.send()
            }
        }
    }
    
    private lazy var receiveValueCompletion: () -> Void = {[unowned self] in
        if case self.loginState = LoginState.restorePassword {
            self.loginState = .login
            self.messagePublisher.send(presentationObject.passwRecoveryMessage)
        } else {
            self.onLogin.send()
            self.loginState = .login
        }
    }
    
    typealias LoginService = (_ state: LoginState, _ email: String, _ password: String) -> AnyPublisher<Void, Error>
    let loginService: LoginService
    
    init(loginService: @escaping LoginService) {
        self.loginService = loginService
    }
    
    private func onSwitchStateTap() {
        switch loginState {
        case .login:
            loginState = .signup
        default:
            loginState = .login
        }
    }
    
    private func auth(email: String, password:String) {
        self.loginService(self.loginState, email, password)
            .trackActivity(activityIndicator)
            .trackError(errorIndicator)
            .sink(receiveValue: receiveValueCompletion)
            .store(in: &cancellable)
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
        
        var emailString = ""
        var passString = ""
        
        password.sink { passString = $0  }
        .store(in: &cancellable)
        
        email.sink { emailString = $0 }
        .store(in: &cancellable)
        
        input.loginTap
            .sink { 
                self.auth(email: emailString, password: passString)
            }
            .store(in: &cancellable)
        
        input.forgotPasswordTap
            .sink {
                self.loginState = .restorePassword
            }
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
                switch self.loginState {
                case .login:
                    loginEnabled = isValidEmail && isValidPassword
                case .signup:
                    loginEnabled = isValidEmail && isValidPassword && isSamePassword
                case .restorePassword:
                    loginEnabled = isValidEmail
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
