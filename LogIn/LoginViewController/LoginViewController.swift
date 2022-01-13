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
        configure(label: label, with: viewModel.presentationObject.loginLabel)
        return label
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
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = viewModel.presentationObject.cornerRadius
        addShadowTo(button)
        let attributedTitle = makeAttributedString(with: viewModel.presentationObject.signUpButtonIndigo)
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
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.backGradientView.transform = CGAffineTransform(translationX: 0, y: 100)
        }
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
                                        signUpTap: signUpButton.publisher(for: .touchUpInside).eraseToAnyPublisher(),
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
            .sink { _ in
                self.transitionToLoginWithAnimation()
            }
            .store(in: &subscriptions)
        
        viewModel.transitionToSignUp
            .sink { _ in
                self.transitionToSignUpWithAnimation()
            }
            .store(in: &subscriptions)
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
            signUpButton.transform = .identity
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
            UIView.transition(with: signUpButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
                signUpButton.setAttributedTitle(attributedEmptyTitle, for: .normal)
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
            UIView.transition(with: signUpButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
                let attributedTitleSignUp = makeAttributedString(with: viewModel.presentationObject.signUpButtonIndigo)
                signUpButton.setAttributedTitle(attributedTitleSignUp, for: .normal)
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
            UIView.transition(with: signUpButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
                signUpButton.setAttributedTitle(attributedEmptyTitle, for: .normal)
            }, completion: nil)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.3, options: [.curveEaseInOut]) {[self] in
            needAccountLabel.alpha = 0
            loginButton.transform = CGAffineTransform(translationX: 0, y: loginYShift)
            loginShadowView.transform = CGAffineTransform(translationX: 0, y: loginYShift)
            passwordAgainTextField.transform = CGAffineTransform(translationX: 0, y: loginYShift)
        } completion: {[self] _ in
            UIView.transition(with: loginButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
                let attributedTitleSignUp = makeAttributedString(with: viewModel.presentationObject.signUpButton)
                loginButton.setAttributedTitle(attributedTitleSignUp, for: .normal)
            }, completion: nil)
            UIView.transition(with: signUpButton, duration: 0.5, options: .transitionCrossDissolve, animations: {
                let attributedTitleLogin = makeAttributedString(with: viewModel.presentationObject.loginButtonIndigo)
                signUpButton.setAttributedTitle(attributedTitleLogin, for: .normal)
            }, completion: nil)
            configure(label: needAccountLabel, with: viewModel.presentationObject.haveAccountText)
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
        
        [backGradientView,
         backView,
         headerLabel,
         emailTextField,
         passwordTextField,
         passwordAgainTextField,
         loginShadowView,
         loginButton,
         forgotPasswordButton,
         needAccountLabel,
         signUpShadowView,
         signUpButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            backGradientView.topAnchor.constraint(equalTo: view.topAnchor, constant: -100),
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
            
            passwordAgainTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
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
            
            needAccountLabel.bottomAnchor.constraint(equalTo: signUpButton.topAnchor, constant: -20),
            needAccountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
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
