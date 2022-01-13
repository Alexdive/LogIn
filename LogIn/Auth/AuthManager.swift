//
//  AuthManager.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 11.01.2022.
//

import FirebaseAuth
import Combine

final class AuthManager {
    
    static let shared = AuthManager()
    private init() {}
    
    private(set) var isLoggedIn = CurrentValueSubject<Bool, Never>(false)
    
    var userEmail: String? {
        Auth.auth().currentUser?.email
    }
    
    func createUser(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
                return
            }
            print(authResult?.user ?? "")
            self.isLoggedIn.send(true)
            completion(.success(true))
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
                return
            }
            print(authResult?.user ?? "")
            self.isLoggedIn.send(true)
            completion(.success(true))
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            self.isLoggedIn.send(true)
            return
        }
        self.isLoggedIn.send(false)
    }
}
