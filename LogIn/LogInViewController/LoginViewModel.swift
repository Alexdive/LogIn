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
            .eraseToAnyPublisher()
        
        let password = input.pass
            .removeDuplicates()
            .compactMap { $0 }
            .eraseToAnyPublisher()
        
        let passwordAgain = input.passAgain
            .removeDuplicates()
            .compactMap { $0 }
            .eraseToAnyPublisher()
        
        return email
            .combineLatest(password, passwordAgain)
            .map {
                (isValidEmail($0),
                 $1.count > 6,
                 $1 == $2)
            }
            .map {
                LoginViewModelOutput(emailTint: $0 ? .systemGreen : .systemGray2,
                                     passwTint: $1 ? .systemGreen : .systemGray2,
                                     passwAgainTint: $1 && $2 ? .systemGreen : .systemGray2,
                                     emailErrorText: $0 ? "" : "Incorrect email format",
                                     isEnabled: $0 && $1 && $2)
            }
            .eraseToAnyPublisher()
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "^[\\w\\.-]+@([\\w\\-]+\\.)+[A-Z]{1,4}$"
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
