//
//  LoginViewController.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 27.12.2021.
//

import UIKit
import Combine

enum LoginState {
    case login
    case signup
}

final class LoginViewController: UIViewController {
    
    private var model: LoginViewModelType
    
    @Published var loginState: LoginState = .login {
        didSet {
            if loginState == .login {
                switchToLoginWithAnimation()
            } else {
                switchToSignUpWithAnimation()
            }
        }
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var backGradientView: UIView = {
        let view = UIView()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = self.view.frame.size
        gradientLayer.colors = [UIColor.systemIndigo.cgColor,
                                UIColor.systemPurple.withAlphaComponent(0.5).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.addSublayer(gradientLayer)
        view.layer.mask = makeBackWaveMask()
        return view
    }()
    
    private lazy var backView: UIView = {
        let view = UIView()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame.size = self.view.frame.size
        gradientLayer.colors = [UIColor.systemIndigo.cgColor,
                                UIColor.systemPurple.cgColor,
                                UIColor.white.cgColor]
        view.layer.addSublayer(gradientLayer)
        view.layer.mask = makeWaveMask()
        return view
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        configure(label: label, with: model.presentationObject.loginLabel)
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
        tf.isHidden = true
        tf.alpha = 0
        return tf
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = model.presentationObject.cornerRadius
        addShadowTo(button)
        let attributedTitle = makeAttributedString(with: model.presentationObject.loginButton)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setBackgroundColor(.systemIndigo, forState: .normal)
        button.setBackgroundColor(.lightGray, forState: .disabled)
        button.addTarget(self, action: #selector(onLoginTap), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton()
        let attributedTitle = makeAttributedString(with: model.presentationObject.forgotPasswButton)
        let attributedTitleTapped = makeAttributedString(with: model.presentationObject.forgotPasswButtonTap)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setAttributedTitle(attributedTitleTapped, for: .highlighted)
        return button
    }()
    
    private lazy var needAccountButton: UIButton = {
        let button = UIButton()
        let attributedTitle = makeAttributedString(with: model.presentationObject.needAccountText)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(onHaveAccountTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = model.presentationObject.cornerRadius
        addShadowTo(button)
        let attributedTitle = makeAttributedString(with: model.presentationObject.signUpButton)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setBackgroundColor(.systemIndigo, forState: .normal)
        button.setBackgroundColor(.lightGray, forState: .disabled)
        button.addTarget(self, action: #selector(onSignUpTap), for: .touchUpInside)
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
        view.backgroundColor = .systemIndigo
        view.layer.cornerRadius = 22
        addShadowTo(view)
        return view
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
                                        passAgain: passwordAgainTextField.textPublisher,
                                        loginState: $loginState.eraseToAnyPublisher())
        
        viewModel.transform(input: input)
            .sink(receiveValue: {[unowned self] output in
                self.emailTextField.leftView?.tintColor = output.emailTint
                self.passwordTextField.leftView?.tintColor = output.passwTint
                self.passwordAgainTextField.leftView?.tintColor = output.passwAgainTint
                self.signUpButton.isEnabled = output.signUpEnabled
                self.loginButton.isEnabled = output.loginEnabled
            })
            .store(in: &subscriptions)
    }
    
    // MARK: - buttons actions
    @objc private func onSignUpTap() {
        if loginState == .login {
            loginState = .signup
        } else {
            print("sign up")
        }
    }
    
    @objc private func onLoginTap() {
        model.onLoginTap()
    }
    
    @objc private func onHaveAccountTap() {
        if loginState == .signup {
            loginState = .login
        }
    }
}

// MARK: - UI
extension LoginViewController {
    
    private func makeAttributedString(with config: TextConfig) -> NSAttributedString{
        return NSAttributedString(string: config.text,
                                  attributes: [.foregroundColor : config.textColor,
                                               .font: config.font])
    }
    
    private func configure(label: UILabel, with labelConfig: TextConfig) {
        label.text = labelConfig.text
        label.font = labelConfig.font
        label.textColor = labelConfig.textColor
    }
    
    private func configure(textfield: UITextField, with textFieldConfig: TextFieldConfig) {
        textfield.placeholder = textFieldConfig.placeholder
        textfield.setIcon(UIImage(systemName: textFieldConfig.imageName))
        textfield.backgroundColor = textFieldConfig.backgroundColor
        textfield.tintColor = textFieldConfig.tintColor
        textfield.layer.cornerRadius = model.presentationObject.cornerRadius
        textfield.autocapitalizationType = .none
        addShadowTo(textfield)
    }
    
    private func addShadowTo(_ view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
    }
    
    private func switchToLoginWithAnimation() {
        UIView.animate(withDuration: 0.6, delay: 0, options: [.curveEaseInOut]) {
            self.signUpButton.transform = .identity
            self.signUpShadowView.transform = .identity
            
            self.needAccountButton.alpha = 0
            self.passwordAgainTextField.alpha = 0
        } completion: { _ in
            self.passwordAgainTextField.isHidden = true
            let attributedTitle = self.makeAttributedString(with: self.model.presentationObject.needAccountText)
            self.needAccountButton.setAttributedTitle(attributedTitle, for: .normal)
            self.signUpButton.isEnabled = true
        }
        
        forgotPasswordButton.isHidden = false
        loginButton.isHidden = false
        loginShadowView.isHidden = false
        self.needAccountButton.isEnabled = false
        
        UIView.animate(withDuration: 0.6, delay: 0.5) {
            self.loginButton.transform = .identity
            self.loginShadowView.transform = .identity
            
            self.forgotPasswordButton.alpha = 1
            self.loginButton.alpha = 1
            self.loginShadowView.alpha = 1
            self.needAccountButton.alpha = 1
        }
    }
    
    private func switchToSignUpWithAnimation() {
        passwordAgainTextField.isHidden = false
        self.signUpButton.isEnabled = false
        
        let passwBottom = passwordTextField.frame.maxY
        let loginTop = loginButton.frame.minY
        let loginShift = loginTop - passwBottom - 16
        
        UIView.animate(withDuration: 0.6, delay: 0, options: [.curveEaseInOut]) {
            let attributedTitle = self.makeAttributedString(with: self.model.presentationObject.haveAccountText)
            self.needAccountButton.setAttributedTitle(attributedTitle, for: .normal)
            
            self.loginButton.transform = CGAffineTransform(translationX: 0, y: -loginShift)
            self.loginShadowView.transform = CGAffineTransform(translationX: 0, y: -loginShift)
            
            self.forgotPasswordButton.alpha = 0
            self.loginButton.alpha = 0
            self.loginShadowView.alpha = 0
            self.needAccountButton.alpha = 0
        } completion: { _ in
            self.forgotPasswordButton.isHidden = true
            self.loginButton.isHidden = true
            self.loginShadowView.isHidden = true
            self.needAccountButton.isEnabled = true
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.5) {
            self.passwordAgainTextField.alpha = 1
        }
        
        let passwAgainBottom = passwordAgainTextField.frame.maxY
        let signupTop = signUpButton.frame.minY
        let signUpshift = signupTop - passwAgainBottom - 44
        
        UIView.animate(withDuration: 0.5, delay: 0.2, options: [.curveEaseInOut]) {
            self.signUpButton.transform = CGAffineTransform(translationX: 0, y: -signUpshift)
            self.signUpShadowView.transform = CGAffineTransform(translationX: 0, y: -signUpshift)
            self.needAccountButton.alpha = 1
        }
    }
    
    private func setupViews() {
        
        view.backgroundColor = model.presentationObject.backgroundColor
        
        let subviews = [
            backGradientView,
            backView,
            headerLabel,
            emailTextField,
            passwordTextField,
            passwordAgainTextField,
            loginShadowView,
            loginButton,
            forgotPasswordButton,
            needAccountButton,
            signUpShadowView,
            signUpButton
        ]
        subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            backGradientView.topAnchor.constraint(equalTo: view.topAnchor),
            backGradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backGradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backGradientView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.85),
            
            backView.topAnchor.constraint(equalTo: view.topAnchor),
            backView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.8),
            
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailTextField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 48),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordAgainTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            passwordAgainTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            passwordAgainTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            passwordAgainTextField.heightAnchor.constraint(equalToConstant: 44),
            
            loginShadowView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 44),
            loginShadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            loginShadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            loginShadowView.heightAnchor.constraint(equalToConstant: 44),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 44),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            needAccountButton.bottomAnchor.constraint(equalTo: signUpButton.topAnchor, constant: -20),
            needAccountButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            signUpShadowView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44),
            signUpShadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            signUpShadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            signUpShadowView.heightAnchor.constraint(equalToConstant: 44),
            
            signUpButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            signUpButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    /// masks for background views
    private func makeWaveMask() -> CAShapeLayer {
        let path = UIBezierPath()
        let width = view.frame.width
        let height = view.frame.height
        path.move(to: CGPoint(x: 0.0, y: height * 0.7))
        path.addCurve(to: CGPoint(x: width, y: height * 0.65),
                      controlPoint1: CGPoint(x: width * 0.4, y: height * 0.8),
                      controlPoint2: CGPoint(x: width * 0.66, y: height * 0.6))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        return shapeLayer
    }
    
    private func makeBackWaveMask() -> CAShapeLayer {
        let path = UIBezierPath()
        let width = view.frame.width
        let height = view.frame.height
        path.move(to: CGPoint(x: 0.0, y: height * 0.68))
        path.addCurve(to: CGPoint(x: width, y: height * 0.7),
                      controlPoint1: CGPoint(x: width * 0.45, y: height * 0.83),
                      controlPoint2: CGPoint(x: width * 0.7, y: height * 0.62))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        return shapeLayer
    }
}
