//
//  SceneDelegate.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 07.12.2021.
//

import UIKit
import Combine
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var cancellable = Set<AnyCancellable>()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        AuthManager.shared.isLoggedIn
            .sink {[unowned self] isLoggedIn in
                if !isLoggedIn {
                    self.window?.rootViewController = self.setupLoginVC()
                }
            }
            .store(in: &cancellable)
        
        window?.makeKeyAndVisible()
    }
    
    private func setupLoginVC() -> UIViewController {
        let auth = AuthManager.shared
        
        let loginService: LoginViewModel.LoginService = { [unowned auth] state, email, password in
            switch state {
            case .login:
                return auth.signIn(email: email, password: password).eraseToAnyPublisher()
            case .signup:
                return auth.createUser(email: email, password: password).eraseToAnyPublisher()
            case .restorePassword:
                return auth.passwordReset(with: email).eraseToAnyPublisher()
            }
        }
        
        let viewModel = LoginViewModel(loginService: loginService)
        viewModel.onLogin
            .sink {[unowned self] _ in
                let tableView = UIHostingController(rootView: TodoTableView())
                self.window?.rootViewController = tableView
            }
            .store(in: &cancellable)
        
        return LoginViewController(viewModel: viewModel)
    }
}

