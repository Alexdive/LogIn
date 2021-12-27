//
//  LoginViewModel.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 27.12.2021.
//

import Foundation

protocol LoginViewModelType {
    var presentationObject: LoginViewPresentationObject { get }
//    func transform(input: SignUpViewModelInput) -> AnyPublisher<SignUpViewModelOutput, Never>
}

struct LoginViewModel: LoginViewModelType {
    let presentationObject = LoginViewPresentationObject()
}
