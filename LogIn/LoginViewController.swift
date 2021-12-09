//
//  LoginViewController.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 07.12.2021.
//

import UIKit
import Combine

final class LoginViewController: UIViewController {
    
    var model: LoginViewModelType

    private var subscriptions = Set<AnyCancellable>()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .systemRed
        return label
    }()
    
    private lazy var emailTextField: UITextField = {
        let tf = UITextField()
        applyLoginTextStyle(tf)
        tf.setIcon(UIImage(systemName: "envelope"))
        tf.placeholder = "Enter email"
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    private lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        applyLoginTextStyle(tf)
        tf.setIcon(UIImage(systemName: "key"))
        tf.placeholder = "Enter password"
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private lazy var passwordAgainTextField: UITextField = {
        let tf = UITextField()
        applyLoginTextStyle(tf)
        tf.setIcon(UIImage(systemName: "key"))
        tf.placeholder = "Repeat password"
        tf.isSecureTextEntry = true
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
    
    private func bind(to viewModel: LoginViewModelType) {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        let input = LoginViewModelInput(email: emailTextField.textPublisher.eraseToAnyPublisher(),
                                        pass: passwordTextField.textPublisher.eraseToAnyPublisher(),
                                        passAgain: passwordAgainTextField.textPublisher.eraseToAnyPublisher())
        
        viewModel.transform(input: input)
        
        viewModel.outputPublisher.sink(receiveValue: {[unowned self] output in
            self.emailTextField.tintColor = output.emailTint
            self.passwordTextField.tintColor = output.passwTint
            self.passwordAgainTextField.tintColor = output.passwAgainTint
            self.label.text = output.emailFormatMessage
            self.signInButton.isEnabled = output.isEnabled
        }).store(in: &subscriptions)
    }
    
    private func applyLoginTextStyle(_ tf: UITextField) {
        tf.backgroundColor = .systemGray6
        tf.tintColor = .systemGray2
        tf.layer.cornerRadius = 16
        tf.clipsToBounds = true
        tf.autocapitalizationType = .none
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
        
        let height = view.frame.height
        let width = view.frame.width
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: height * 0.1),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalToConstant: width * 0.8),
            stackView.heightAnchor.constraint(equalToConstant: height * 0.4)
        ])
    }
}
