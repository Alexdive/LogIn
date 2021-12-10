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
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = model.presentationObject.labelTextColor
        return label
    }()
    
    private lazy var emailTextField: UITextField = {
        let tf = UITextField()
        configure(textfield: tf, with: model.presentationObject.emailTF)
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    private lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        configure(textfield: tf, with: model.presentationObject.passwordTF)
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private lazy var passwordAgainTextField: UITextField = {
        let tf = UITextField()
        configure(textfield: tf, with: model.presentationObject.passwordAgainTF)
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
        let input = LoginViewModelInput(email: emailTextField.textPublisher,
                                        pass: passwordTextField.textPublisher,
                                        passAgain: passwordAgainTextField.textPublisher)
        
        viewModel.transform(input: input)
        
        viewModel.outputPublisher.sink(receiveValue: {[unowned self] output in
            self.emailTextField.tintColor = output.emailTint
            self.passwordTextField.tintColor = output.passwTint
            self.passwordAgainTextField.tintColor = output.passwAgainTint
            self.label.text = output.emailFormatMessage
            self.signInButton.isEnabled = output.isEnabled
        }).store(in: &subscriptions)
    }
    
    private func configure(textfield: UITextField, with textFieldConfig: TextFieldConfig) {
        textfield.placeholder = textFieldConfig.placeholder
        textfield.setIcon(UIImage(systemName: textFieldConfig.imageName))
        textfield.backgroundColor = textFieldConfig.backgroundColor
        textfield.tintColor = textFieldConfig.tintColor
        applyLoginTextStyle(textfield)
    }
    
    private func applyLoginTextStyle(_ textfield: UITextField) {
        textfield.layer.cornerRadius = 16
        textfield.clipsToBounds = true
        textfield.autocapitalizationType = .none
    }
}

extension LoginViewController {
    private func setupViews() {
        view.backgroundColor = model.presentationObject.backgroundColor
        
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
