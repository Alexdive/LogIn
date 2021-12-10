//
//  Models.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 10.12.2021.
//

import UIKit
import Combine

struct TextFieldConfig {
    let placeholder: String
    let imageName: String
    let backgroundColor: UIColor
    let tintColor: UIColor
}

struct LoginViewPresentationObject {
    let emailTF = TextFieldConfig(placeholder: "Enter email",
                                imageName: "envelope",
                                backgroundColor: .systemGray6,
                                tintColor: .systemGray2)
    let passwordTF = TextFieldConfig(placeholder: "Enter password",
                                   imageName: "key",
                                   backgroundColor: .systemGray6,
                                   tintColor: .systemGray2)
    let passwordAgainTF = TextFieldConfig(placeholder: "Repeat password",
                                        imageName: "key",
                                        backgroundColor: .systemGray6,
                                        tintColor: .systemGray2)
    let labelTextColor: UIColor = .systemRed
    let backgroundColor: UIColor = .white
}

struct LoginViewModelInput {
    let email: AnyPublisher<String?, Never>
    let pass: AnyPublisher<String?, Never>
    let passAgain: AnyPublisher<String?, Never>
}

struct LoginViewModelOutput {
    var emailTint: UIColor
    var passwTint: UIColor
    var passwAgainTint: UIColor
    var emailFormatMessage: String
    var isEnabled: Bool
    
    init(emailTint: UIColor = .systemGray2,
         passwTint: UIColor = .systemGray2,
         passwAgainTint: UIColor = .systemGray2,
         emailFormatMessage: String = "",
         isEnabled: Bool = false) {
        self.emailTint = emailTint
        self.passwTint = passwTint
        self.passwAgainTint = passwAgainTint
        self.emailFormatMessage = emailFormatMessage
        self.isEnabled = isEnabled
    }
}