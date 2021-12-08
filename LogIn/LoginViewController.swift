//
//  LoginViewController.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 07.12.2021.
//

import UIKit
import Combine

class LoginViewController: UIViewController {
    
    var model: LoginViewModelType
    
    private let email = PassthroughSubject<String, Never>()
    private let pass = PassthroughSubject<String, Never>()
    private let passAgain = PassthroughSubject<String, Never>()
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .systemRed
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.loginTextStyle()
        tf.setIcon(UIImage(systemName: "envelope"))
        tf.placeholder = "Enter email"
        tf.keyboardType = .emailAddress
        tf.addTarget(self, action: #selector(emailTextEntered), for: .editingChanged)
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.loginTextStyle()
        tf.setIcon(UIImage(systemName: "key"))
        tf.placeholder = "Enter password"
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(passwordTextEntered), for: .editingChanged)
        return tf
    }()
    
    private let passwordAgainTextField: UITextField = {
        let tf = UITextField()
        tf.loginTextStyle()
        tf.setIcon(UIImage(systemName: "key"))
        tf.placeholder = "Repeat password"
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(passwordAgainTextEntered), for: .editingChanged)
        return tf
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.setTitleColor(.darkGray, for: .normal)
        button.setTitle("Log in", for: .normal)
        button.setBackgroundColor(.systemTeal, forState: .normal)
        button.setBackgroundColor(.lightGray, forState: .disabled)
        button.setBackgroundColor(.systemGray4, forState: .highlighted)
        button.isEnabled = false
        return button
    }()
    
    init(model: LoginViewModelType) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        bind(to: model)
    }
    
    @objc
    private func emailTextEntered() {
        if let text = emailTextField.text {
            email.send(text)
        }
    }
    
    @objc
    private func passwordTextEntered() {
        if let text = passwordTextField.text {
            pass.send(text)
        }
    }
    
    @objc
    private func passwordAgainTextEntered() {
        if let text = passwordAgainTextField.text {
            passAgain.send(text)
        }
    }
    
    private func bind(to viewModel: LoginViewModelType) {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        let input = LoginViewModelInput(email: email.eraseToAnyPublisher(),
                                        pass: pass.eraseToAnyPublisher(),
                                        passAgain: passAgain.eraseToAnyPublisher())
        
        viewModel.transform(input: input)
        
        viewModel.outputPublisher.sink(receiveValue: {[unowned self] output in
            self.emailTextField.tintColor = output.emailTint
            self.passwordTextField.tintColor = output.passwTint
            self.passwordAgainTextField.tintColor = output.passwAgainTint
            self.label.text = output.emailFormatMessage
            self.signInButton.isEnabled = output.isEnabled
        }).store(in: &subscriptions)
    }
}

extension LoginViewController {
    private func setupViews() {
        view.backgroundColor = .white
        
        let subviews = [label,
                        emailTextField,
                        passwordTextField,
                        passwordAgainTextField,
                        signInButton]
        
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 300),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -300)
        ])
    }
}
