//
//  LoginViewModel.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 08.12.2021.
//

import UIKit
import Combine

struct LoginViewModelInput {
    let email: AnyPublisher<String, Never>
    let pass: AnyPublisher<String, Never>
    let passAgain: AnyPublisher<String, Never>
}

struct LoginViewModelOutput {
    let emailTint: UIColor
    let passwTint: UIColor
    let passwAgainTint: UIColor
    let emailFormatMessage: String
    let isEnabled: Bool
}

protocol LoginViewModelType {
    var outputPublisher: Published<LoginViewModelOutput>.Publisher { get }
    func transform(input: LoginViewModelInput)
}

class LoginViewModel: LoginViewModelType {
    
    @Published private(set) var output: LoginViewModelOutput = .init(emailTint: .systemGray2,
                                                                     passwTint: .systemGray2,
                                                                     passwAgainTint: .systemGray2,
                                                                     emailFormatMessage: "",
                                                                     isEnabled: false)
    
    var outputPublisher: Published<LoginViewModelOutput>.Publisher { $output }
    
    private var subscriptions = Set<AnyCancellable>()
    
    func transform(input: LoginViewModelInput) {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        
        var emailTint: UIColor = .systemGray2
        var passwTint: UIColor = .systemGray2
        var passwAgainTint: UIColor = .systemGray2
        var emailFormatMessage: String = ""
        var isEnabled: Bool = false
        
        var isValid = false
        
        input.email
            .debounce(for: 1, scheduler: RunLoop.main)
            .sink { [unowned self] text in
                isValid = self.isValidEmail(text)
                emailTint = isValid ? .systemGreen : .systemGray2
                emailFormatMessage = isValid ? "" : "Incorrect email format"
                self.output = LoginViewModelOutput(emailTint: emailTint,
                                                   passwTint: passwTint,
                                                   passwAgainTint: passwAgainTint,
                                                   emailFormatMessage: emailFormatMessage,
                                                   isEnabled: isEnabled)
                
            }
            .store(in: &subscriptions)
        
        input.email.combineLatest(input.pass, input.passAgain) { [unowned self] email, password, passwordAgain in
            
            isValid = self.isValidEmail(email)
            passwTint = password.count > 6 ? .systemGreen : .systemGray2
            passwAgainTint = password.count > 6 && password == passwordAgain ? .systemGreen : .systemGray2
            
            let isEnabled = isValid &&
            password.count > 6 &&
            password == passwordAgain
            
            self.output = LoginViewModelOutput(emailTint: emailTint,
                                               passwTint: passwTint,
                                               passwAgainTint: passwAgainTint,
                                               emailFormatMessage: emailFormatMessage,
                                               isEnabled: isEnabled)
            return isEnabled
        }
        .sink(receiveValue: { bool in
            isEnabled = bool
        })
        .store(in: &subscriptions)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
