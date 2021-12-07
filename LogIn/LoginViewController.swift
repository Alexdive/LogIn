//
//  LoginViewController.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 07.12.2021.
//

import UIKit
import Combine

class LoginViewController: UIViewController {
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.loginTextStyle()
        tf.placeholder = "Enter email"
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.loginTextStyle()
        tf.placeholder = "Enter password"
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let passwordRepeatTextField: UITextField = {
        let tf = UITextField()
        tf.loginTextStyle()
        tf.placeholder = "Repeat password"
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.setTitleColor(.darkGray, for: .normal)
        button.setTitle("Log in", for: .normal)
        button.setBackgroundColor(.systemTeal, forState: .normal)
        button.setBackgroundColor(.lightGray, forState: .disabled)
        button.setBackgroundColor(.systemGray4, forState: .highlighted)
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
}

extension LoginViewController {
    private func setupViews() {
        
        view.backgroundColor = .white
        
        [emailTextField,
         passwordTextField,
         passwordRepeatTextField,
         signInButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.widthAnchor.constraint(equalToConstant: 300),
            emailTextField.heightAnchor.constraint(equalToConstant: 60),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.widthAnchor.constraint(equalToConstant: 300),
            passwordTextField.heightAnchor.constraint(equalToConstant: 60),
            
            passwordRepeatTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            passwordRepeatTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordRepeatTextField.widthAnchor.constraint(equalToConstant: 300),
            passwordRepeatTextField.heightAnchor.constraint(equalToConstant: 60),
            
            signInButton.topAnchor.constraint(equalTo: passwordRepeatTextField.bottomAnchor, constant: 20),
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.widthAnchor.constraint(equalToConstant: 300),
            signInButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
