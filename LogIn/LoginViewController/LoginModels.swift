//
//  LoginModels.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 27.12.2021.
//

import UIKit
import Combine

struct TextFieldConfig {
    let placeholder: String
    let imageName: String
    let backgroundColor: UIColor
    let tintColor: UIColor
}

struct TextConfig {
    let text: String
    let textColor: UIColor
    let font: UIFont
}

struct LoginViewPresentationObject {
    let emailTF = TextFieldConfig(placeholder: "yourmail@gmail.com",
                                imageName: "envelope",
                                backgroundColor: .systemGray6,
                                tintColor: .systemGray2)
    
    let passwordTF = TextFieldConfig(placeholder: "Password",
                                   imageName: "key",
                                   backgroundColor: .systemGray6,
                                   tintColor: .systemGray2)
    
    let passwordAgainTF = TextFieldConfig(placeholder: "Repeat password",
                                        imageName: "key",
                                        backgroundColor: .systemGray6,
                                        tintColor: .systemGray2)
  
    let loginLabel = TextConfig(text: "App Login",
                                 textColor: .white,
                                 font: AppConstants.Fonts.avenirNext30)
    
    let needAccountText = TextConfig(text: "Need an account?",
                                       textColor: .systemGray2,
                                       font: AppConstants.Fonts.avenirNext18)
    
    let haveAccountText = TextConfig(text: "I have an account!",
                                     textColor: .systemGray2,
                                     font: AppConstants.Fonts.avenirNext18)
    
    let loginWhite = TextConfig(text: "Login",
                                 textColor: .white,
                                 font: AppConstants.Fonts.avenirNext18)
    
    let sendEmail = TextConfig(text: "Send recovery email",
                                 textColor: .white,
                                 font: AppConstants.Fonts.avenirNext18)
    
    let loginIndigo = TextConfig(text: "Login",
                                 textColor: .systemIndigo,
                                 font: AppConstants.Fonts.avenirNext18)
    
    let forgotPasswButton = TextConfig(text: "Forgot your password?",
                                 textColor: .white,
                                 font: AppConstants.Fonts.avenirNext13)
    
    let forgotPasswButtonTap = TextConfig(text: "Forgot your password?",
                                 textColor: .systemIndigo,
                                 font: AppConstants.Fonts.avenirNext13)
    
    let signUpWhite = TextConfig(text: "Sign Up",
                                 textColor: .white,
                                 font: AppConstants.Fonts.avenirNext18)
    
    let signUpIndigo = TextConfig(text: "Sign Up",
                                 textColor: .systemIndigo,
                                 font: AppConstants.Fonts.avenirNext18)
    
    let empty = TextConfig(text: "",
                                 textColor: .white,
                                 font: AppConstants.Fonts.avenirNext18)
    
    let errorTitle = "Oooops!"
    let successTitle = "Hooray!"
    let passwRecoveryMessage = "Password restoration email has been sent successfully!"
    
    let backgroundColor: UIColor = .white
    let cornerRadius: CGFloat = 22
}


struct LoginViewModelInput {
    let email: AnyPublisher<String?, Never>
    let pass: AnyPublisher<String?, Never>
    let passAgain: AnyPublisher<String?, Never>
    let switchStateTap: AnyPublisher<Void, Never>
    let loginTap: AnyPublisher<Void, Never>
    let forgotPasswordTap: AnyPublisher<Void, Never>
}

struct LoginViewModelOutput {
    var emailTint: UIColor
    var passwTint: UIColor
    var passwAgainTint: UIColor
    var loginEnabled: Bool
}
