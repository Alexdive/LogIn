//
//  LoginViewController.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 27.12.2021.
//

import UIKit

enum LoginState {
    case login
    case signup
}

final class LoginViewController: UIViewController {
    
    private var model: LoginViewModelType
    private var loginState: LoginState = .login {
        didSet {
            if loginState == .login {
                // login
                switchToLogin()
            } else {
                // signup
                switchToSignUp()
            }
        }
    }

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
    
    private lazy var loginLabel: UILabel = {
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
    
    private lazy var logInButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = model.presentationObject.cornerRadius
        addShadowTo(button)
        let attributedTitle = makeAttributedString(with: model.presentationObject.loginButton)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setBackgroundColor(.systemIndigo, forState: .normal)
//        button.isEnabled = false
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
    
    private lazy var needAccountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        configure(label: label, with: model.presentationObject.needAccountLabel)
        return label
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = model.presentationObject.cornerRadius
        addShadowTo(button)
        let attributedTitle = makeAttributedString(with: model.presentationObject.signUpButton)
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setBackgroundColor(.systemIndigo, forState: .normal)
        button.addTarget(self, action: #selector(onSignUpTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemIndigo
        view.layer.cornerRadius = 22
        addShadowTo(view)
        return view
    }()
    
    private lazy var shadowView2: UIView = {
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
    }
    
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
    
    private func switchToLogin() {
        UIView.animate(withDuration: 0.6, delay: 0, options: [.curveEaseInOut]) {
            self.passwordAgainTextField.alpha = 0
            self.signUpButton.transform = .identity
            self.shadowView2.transform = .identity
        } completion: { _ in
            self.passwordAgainTextField.isHidden = true
        }
        
        forgotPasswordButton.isHidden = false
        needAccountLabel.isHidden = false
        logInButton.isHidden = false
        shadowView.isHidden = false
        
        UIView.animate(withDuration: 0.6, delay: 0.5) {
            self.forgotPasswordButton.alpha = 1
            self.needAccountLabel.alpha = 1
            self.logInButton.alpha = 1
            self.shadowView.alpha = 1
        }
    }
    
    private func switchToSignUp() {
        self.passwordAgainTextField.isHidden = false
        UIView.animate(withDuration: 0.6, delay: 0, options: [.curveEaseInOut]) {
            self.forgotPasswordButton.alpha = 0
            self.needAccountLabel.alpha = 0
            self.logInButton.alpha = 0
            self.shadowView.alpha = 0
        } completion: { _ in
            self.forgotPasswordButton.isHidden = true
            self.needAccountLabel.isHidden = true
            self.logInButton.isHidden = true
            self.shadowView.isHidden = true
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.5) {
            self.passwordAgainTextField.alpha = 1
        }
        
        let passwAgainBottom = passwordAgainTextField.frame.maxY
        let signupAgainTop = signUpButton.frame.minY
        let shift = signupAgainTop - passwAgainBottom - 44
        
        UIView.animate(withDuration: 0.5, delay: 0.2) {
            self.signUpButton.transform = CGAffineTransform(translationX: 0, y: -shift)
            self.shadowView2.transform = CGAffineTransform(translationX: 0, y: -shift)
        }
    }
    
    @objc private func onSignUpTap() {
        if loginState != .signup {
            loginState = .signup
        } else {
            print("sign up")
            loginState = .login
        }
    }
    
}

extension LoginViewController {
    
    private func setupViews() {
        
        view.backgroundColor = model.presentationObject.backgroundColor
        
        let subviews = [
            backGradientView,
            backView,
            loginLabel,
            emailTextField,
            passwordTextField,
            passwordAgainTextField,
            shadowView,
            logInButton,
            forgotPasswordButton,
            needAccountLabel,
            shadowView2,
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
            backGradientView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.8),
            
            backView.topAnchor.constraint(equalTo: view.topAnchor),
            backView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.75),
            
            loginLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            loginLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emailTextField.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 44),
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
            
            shadowView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 44),
            shadowView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            shadowView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            shadowView.heightAnchor.constraint(equalToConstant: 44),
            
            logInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 44),
            logInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            logInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            logInButton.heightAnchor.constraint(equalToConstant: 44),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: logInButton.bottomAnchor, constant: 20),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            needAccountLabel.bottomAnchor.constraint(equalTo: signUpButton.topAnchor, constant: -20),
            needAccountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            shadowView2.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44),
            shadowView2.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            shadowView2.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            shadowView2.heightAnchor.constraint(equalToConstant: 44),
            
            signUpButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -44),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            signUpButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
    }
    
    private func makeWaveMask() -> CAShapeLayer {
        let path = UIBezierPath()
        let width = view.frame.width
        let height = view.frame.height
        path.move(to: CGPoint(x: 0.0, y: height * 0.65))
        path.addCurve(to: CGPoint(x: width, y: height * 0.6),
                      controlPoint1: CGPoint(x: width * 0.4, y: height * 0.75),
                      controlPoint2: CGPoint(x: width * 0.66, y: height * 0.55))
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
        path.move(to: CGPoint(x: 0.0, y: height * 0.63))
        path.addCurve(to: CGPoint(x: width, y: height * 0.65),
                      controlPoint1: CGPoint(x: width * 0.45, y: height * 0.78),
                      controlPoint2: CGPoint(x: width * 0.7, y: height * 0.57))
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        return shapeLayer
    }
}
