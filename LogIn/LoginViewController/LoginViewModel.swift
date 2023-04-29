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
typealias LoginStateTrigger = PassthroughSubject<LoginState, Never>

protocol LoginViewModelType {
    var presentationObject: LoginViewPresentationObject { get }
    var loginStateTransition: LoginStateTrigger { get }
    var messagePublisher: PassthroughSubject<String, Never> { get }
    var onLogin: VoidTrigger { get }
    var loadingPublisher: AnyPublisher<Bool, Never> { get }
    var errorPublisher: AnyPublisher<Error, Never> { get }
    func transform(input: LoginViewModelInput) -> AnyPublisher<LoginViewModelOutput, Never>
}

final class LoginViewModel: LoginViewModelType {
    let presentationObject = LoginViewPresentationObject()
    var loginStateTransition = LoginStateTrigger()
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
    
    @Published
    private var loginState: LoginState = .login {
        didSet {
            loginStateTransition.send(loginState)
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
    
    deinit {
        print("deinit \(self)")
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
        loginService(loginState, email, password)
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
            .sink {[unowned self] in
                self.onSwitchStateTap() }
            .store(in: &cancellable)
        
        let credentials = email
            .combineLatest(password)
            .eraseToAnyPublisher()
        
        input.loginTap
            .withLatestFrom(credentials)
            .map { $1 }
            .sink {[unowned self] in
                self.auth(email: $0.0, password: $0.1) }
            .store(in: &cancellable)
        
        input.forgotPasswordTap
            .sink {[unowned self] in
                self.loginState = .restorePassword
            }
            .store(in: &cancellable)
        
        let isValidEmail = $loginState.combineLatest(email)
            .map {[unowned self] in
                self.isValidEmail($1) }
        
        let isValidPassword = $loginState.combineLatest(password)
            .map { $1.count > 6 }
        
        let isSamePassword = $loginState.combineLatest(password, passwordAgain)
            .map { $1 == $2 }
        
        let output: AnyPublisher<LoginViewModelOutput, Never> = $loginState
            .combineLatest(isValidEmail, isValidPassword, isSamePassword)
            .map { state, isValidEmail, isValidPassword, isSamePassword in
                var loginEnabled = false
                switch state {
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
