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
    
    private var _isLoggedIn = CurrentValueSubject<Bool, Never>(false)
    var isLoggedIn: AnyPublisher<Bool, Never> { _isLoggedIn.eraseToAnyPublisher() }
    
    var userEmail: String? {
        Auth.auth().currentUser?.email
    }
    
    func createUser(email: String, password: String) -> Future<Void, Error> {
        return Future { promise in
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                guard let self = self else { return }
                if let error = error {
                    promise(.failure(error))
                    return
                }
                self._isLoggedIn.send(true)
                promise(.success(()))
            }
        }
    }
    
    func signIn(email: String, password: String) -> Future<Void, Error> {
        return Future { promise in
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let self = self else { return }
                if let error = error {
                    promise(.failure(error))
                    return
                }
                self._isLoggedIn.send(true)
                promise(.success(()))
            }
        }
    }
    
    func passwordReset(with email: String) -> Future<Void, Error> {
        return Future { promise in
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                if let error = error {
                    promise(.failure(error))
                    return
                } else {
                    promise(.success(()))
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            return
        }
        self._isLoggedIn.send(false)
    }
}
