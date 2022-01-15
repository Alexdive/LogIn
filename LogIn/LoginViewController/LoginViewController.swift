//
//  LoginViewController.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 27.12.2021.
//

import UIKit
import Combine

final class LoginViewController: UIViewController {
    
    private var viewModel: LoginViewModelType
    
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var loginBackView = LoginBackView()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        configure(label: label, with: viewModel.presentationObject.loginLabel)
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.style = .large
        ai.color = .white
        return ai
    }()
    
    private lazy var emailTextField: UITextField = {
        let tf = UITextField()
        configure(textfield: tf, with: viewModel.presentationObject.emailTF)
        tf.keyboardType = .emailAddress
        tf.textContentType = .emailAddress
        return tf
    }()
    
    private lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        configure(textfield: tf, with: viewModel.presentationObject.passwordTF)
        tf.isSecureTextEntry = true
        tf.textContentType = .oneTimeCode
        return tf
    }()
    
    private lazy var passwordAgainTextField: UITextField = {
        let tf = UITextField()
        configure(textfield: tf, with: viewModel.presentationObject.passwordAgainTF)
        tf.isSecureTextEntry = true
        tf.textContentType = .oneTimeCode
        tf.isHidden = true
        tf.alpha = 0
        return tf
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = viewModel.presentationObject.cornerRadius
        addShadowTo(button)
        let attributedTitle = makeAttributedString(with: viewModel.presentationObject.loginButton)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setBackgroundColor(.systemIndigo, forState: .normal)
        button.setBackgroundColor(.lightGray, forState: .disabled)
        button.isEnabled = false
        return button
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton()
        let attributedTitle = makeAttributedString(with: viewModel.presentationObject.forgotPasswButton)
        let attributedTitleTapped = makeAttributedString(with: viewModel.presentationObject.forgotPasswButtonTap)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setAttributedTitle(attributedTitleTapped, for: .highlighted)
        return button
    }()
    
    private lazy var needAccountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        configure(label: label, with: viewModel.presentationObject.needAccountText)
        return label
    }()
    
    private lazy var switchStateButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = viewModel.presentationObject.cornerRadius
        addShadowTo(button)
        let attributedTitle = makeAttributedString(with: viewModel.presentationObject.switchStateButtonIndigo)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setBackgroundColor(.systemGray6, forState: .normal)
        button.setBackgroundColor(.lightGray, forState: .disabled)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemIndigo.cgColor
        return button
    }()
    
    private lazy var loginShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemIndigo
        view.layer.cornerRadius = 22
        addShadowTo(view)
        return view
    }()
    
    private lazy var signUpShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 22
        addShadowTo(view)
        return view
    }()
    
    init(viewModel: LoginViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindToViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loginBackView.animate()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func bindToViewModel() {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
        
        let input = LoginViewModelInput(email: emailTextField.textPublisher,
                                        pass: passwordTextField.textPublisher,
                                        passAgain: passwordAgainTextField.textPublisher,
                                        switchStateTap: switchStateButton.publisher(for: .touchUpInside).eraseToAnyPublisher(),
                                        loginTap: loginButton.publisher(for: .touchUpInside).eraseToAnyPublisher())
        
        viewModel.transform(input: input)
            .sink(receiveValue: {[unowned self] output in
                self.emailTextField.leftView?.tintColor = output.emailTint
                self.passwordTextField.leftView?.tintColor = output.passwTint
                self.passwordAgainTextField.leftView?.tintColor = output.passwAgainTint
                self.loginButton.isEnabled = output.loginEnabled
            })
            .store(in: &subscriptions)
        
        viewModel.transitionToLogin
            .sink {[unowned self] _ in
                self.transitionToLoginWithAnimation()
            }
            .store(in: &subscriptions)
        
        viewModel.transitionToSignUp
            .sink {[unowned self] _ in
                self.transitionToSignUpWithAnimation()
            }
            .store(in: &subscriptions)
        
        viewModel.errorPublisher
            .sink {[unowned self] error in
                self.showErrorAlert(message: error.localizedDescription)
                self.loginButton.isEnabled = false
            }
            .store(in: &subscriptions)
        
        viewModel.loadingPublisher
            .sink {[unowned self] isLoading in
                isLoading ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
            }
            .store(in: &subscriptions)
    }
    
    private func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        alertController.view.layer.cornerRadius = 22
        alertController.view.clipsToBounds = true
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UI
extension LoginViewController {
    
    private func makeAttributedString(with config: TextConfig) -> NSAttributedString{
        return NSAttributedString(string: config.text,
                                  attributes: [.foregroundColor : config.textColor,
                                               .font: config.font])
    }
    
    private func configure(label: UILabel, with config: TextConfig) {
        label.text = config.text
        label.font = config.font
        label.textColor = config.textColor
    }
    
    private func configure(textfield: UITextField, with config: TextFieldConfig) {
        textfield.placeholder = config.placeholder
        textfield.setIcon(UIImage(systemName: config.imageName))
        textfield.backgroundColor = config.backgroundColor
        textfield.tintColor = config.tintColor
        textfield.layer.cornerRadius = viewModel.presentationObject.cornerRadius
        textfield.autocapitalizationType = .none
        textfield.autocorrectionType = .no
        addShadowTo(textfield)
    }
    
    private func addShadowTo(_ view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
    }
    
    private func transitionToLoginWithAnimation() {
        let attributedEmptyTitle = makeAttributedString(with: viewModel.presentationObject.empty)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut]) {[self] in
            switchStateButton.transform = .identity
            signUpShadowView.transform = .identity
            
            passwordAgainTextField.alpha = 0
        } completion: {[self] _ in
            passwordAgainTextField.isHidden = true
            forgotPasswordButton.isHidden = false
            loginButton.isHidden = false
            loginShadowView.isHidden = false
            
            UIView.transition(with: loginButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
                loginButton.setAttributedTitle(attributedEmptyTitle, for: .normal)
            }, completion: nil)
            UIView.transition(with: switchStateButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
                switchStateButton.setAttributedTitle(attributedEmptyTitle, for: .normal)
            }, completion: nil)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.3) {[self] in
            loginButton.transform = .identity
            loginShadowView.transform = .identity
            passwordAgainTextField.transform = .identity
            
            forgotPasswordButton.alpha = 1
            needAccountLabel.alpha = 0
        } completion: {[self] _ in
            UIView.transition(with: loginButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
                let attributedTitleLogin = makeAttributedString(with: viewModel.presentationObject.loginButton)
                loginButton.setAttributedTitle(attributedTitleLogin, for: .normal)
            }, completion: nil)
            UIView.transition(with: switchStateButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
                let attributedTitleSignUp = makeAttributedString(with: viewModel.presentationObject.switchStateButtonIndigo)
                switchStateButton.setAttributedTitle(attributedTitleSignUp, for: .normal)
            }, completion: nil)
            configure(label: needAccountLabel, with: viewModel.presentationObject.needAccountText)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.8) {
            self.needAccountLabel.alpha = 1
        }
    }
    
    private func transitionToSignUpWithAnimation() {
        passwordAgainTextField.isHidden = false
        
        let loginYShift: CGFloat = 44 + 16
        let attributedEmptyTitle = makeAttributedString(with: viewModel.presentationObject.empty)
        
        UIView.animate(withDuration: 0.5) {[self] in
            forgotPasswordButton.alpha = 0
        } completion: {[self] _ in
            forgotPasswordButton.isHidden = true
            UIView.transition(with: loginButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
                loginButton.setAttributedTitle(attributedEmptyTitle, for: .normal)
            }, completion: nil)
            UIView.transition(with: switchStateButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
                switchStateButton.setAttributedTitle(attributedEmptyTitle, for: .normal)
            }, completion: nil)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [.curveEaseInOut]) {[self] in
            needAccountLabel.alpha = 0
            loginButton.transform = CGAffineTransform(translationX: 0, y: loginYShift)
            loginShadowView.transform = CGAffineTransform(translationX: 0, y: loginYShift)
            passwordAgainTextField.transform = CGAffineTransform(translationX: 0, y: loginYShift)
        } completion: {[self] _ in
            UIView.transition(with: loginButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
                let attributedTitleSignUp = makeAttributedString(with: viewModel.presentationObject.switchStateButton)
                loginButton.setAttributedTitle(attributedTitleSignUp, for: .normal)
            }, completion: nil)
            UIView.transition(with: switchStateButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
                let attributedTitleLogin = makeAttributedString(with: viewModel.presentationObject.loginButtonIndigo)
                switchStateButton.setAttributedTitle(attributedTitleLogin, for: .normal)
            }, completion: nil)
            configure(label: needAccountLabel, with: viewModel.presentationObject.haveAccountText)
            loginButton.isEnabled = false
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.5) {
            self.passwordAgainTextField.alpha = 1
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.8) {
            self.needAccountLabel.alpha = 1
        }
    }
    
    private func setupViews() {
        view.backgroundColor = viewModel.presentationObject.backgroundColor
        let lrInset: CGFloat = 60
        
        [loginBackView,
         headerLabel,
         activityIndicator,
         emailTextField,
         passwordTextField,
         passwordAgainTextField,
         loginShadowView,
         loginButton,
         forgotPasswordButton,
         needAccountLabel,
         signUpShadowView,
         switchStateButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            loginBackView.topAnchor.constraint(equalTo: view.topAnchor),
            loginBackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loginBackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loginBackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 2),
            
            emailTextField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 48),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: lrInset),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -lrInset),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: lrInset),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -lrInset),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordAgainTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordAgainTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: lrInset),
            passwordAgainTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -lrInset),
            passwordAgainTextField.heightAnchor.constraint(equalToConstant: 44),
            
            loginShadowView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 44),
            loginShadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: lrInset),
            loginShadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -lrInset),
            loginShadowView.heightAnchor.constraint(equalToConstant: 44),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 44),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: lrInset),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -lrInset),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            needAccountLabel.bottomAnchor.constraint(equalTo: switchStateButton.topAnchor, constant: -20),
            needAccountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            signUpShadowView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44),
            signUpShadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: lrInset),
            signUpShadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -lrInset),
            signUpShadowView.heightAnchor.constraint(equalToConstant: 44),
            
            switchStateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44),
            switchStateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: lrInset),
            switchStateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -lrInset),
            switchStateButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
