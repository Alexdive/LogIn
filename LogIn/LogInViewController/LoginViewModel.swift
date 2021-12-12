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
    var outputPublisher: Published<LoginViewModelOutput>.Publisher { get }
    func transform(input: LoginViewModelInput)
}

final class LoginViewModel: LoginViewModelType {
    
    let presentationObject = LoginViewPresentationObject()
    var outputPublisher: Published<LoginViewModelOutput>.Publisher { $output }
    
    @Published private var output = LoginViewModelOutput()
    private var subscriptions = Set<AnyCancellable>()
    
    func transform(input: LoginViewModelInput) {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        
        var isValid = false
        
        input.email
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .sink { [unowned self] text in
                isValid = self.isValidEmail(text)
                output.emailTint = isValid ? .systemGreen : .systemGray2
                output.emailFormatMessage = isValid ? "" : "Incorrect email format"
            }
            .store(in: &subscriptions)
        
        input.email.combineLatest(input.pass, input.passAgain) { [unowned self] (email, password, passwordAgain) -> Void in
            guard let email = email,
                  let password = password,
                  let passwordAgain = passwordAgain else { return }
            
            isValid = self.isValidEmail(email)
            output.passwTint = password.count > 6 ? .systemGreen : .systemGray2
            output.passwAgainTint = password.count > 6 && password == passwordAgain ? .systemGreen : .systemGray2
            
            output.isEnabled = isValid &&
            password.count > 6 &&
            password == passwordAgain
        }
        .sink(receiveValue: { _ in })
        .store(in: &subscriptions)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
