//
//  UserViewController.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 11.01.2022.
//

import UIKit

final class UserViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        let logoutBtn = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(onLogoutTap))
        navigationItem.rightBarButtonItem = logoutBtn
        
        view.backgroundColor = .systemTeal
        let userEmail = AuthManager.shared.userEmail ?? ""
        title = userEmail + " Welcome!"
    }
    
    @objc private func onLogoutTap() {
        AuthManager.shared.signOut()
        navigationController?.popViewController(animated: true)
    }
}
