//
//  SceneDelegate.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 07.12.2021.
//

import UIKit
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var cancellable = Set<AnyCancellable>()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let loginService: LoginViewModel.LoginService = { state, email, password in
            let auth = AuthManager.shared
            switch state {
            case .login:
                return auth.signIn(email: email, password: password).eraseToAnyPublisher()
            case .signup:
                return auth.createUser(email: email, password: password).eraseToAnyPublisher()
            }
        }
        
        let viewModel = LoginViewModel(loginService: loginService)
        viewModel.onLogin
            .sink { _ in
                let vc = UINavigationController(rootViewController: UserViewController())
                self.window?.rootViewController = vc
            }
            .store(in: &cancellable)
        
        AuthManager.shared.isLoggedIn
            .sink {[weak self] isSignedIn in
                if !isSignedIn {
                    let loginVC = LoginViewController(viewModel: viewModel)
                    self?.window?.rootViewController = loginVC
                }
            }
            .store(in: &cancellable)
        
        window?.makeKeyAndVisible()
    }
}

