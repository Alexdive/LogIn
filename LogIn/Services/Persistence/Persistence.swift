//
//  Persistence.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 09.02.2022.
//

import Foundation

enum PersistenceKey {
    static let todo = "Todo"
}

enum PersistenceError: Error {
    case codableError(Error)
    case noDataForKey
}

protocol Persistence {
    func saveObject<T: Codable>(_ object: T, for key: String) throws
    func getObject<T: Codable>(for key: String) throws -> T
}

struct Persister: Persistence {
    let userDefaults: UserDefaults
    
    func saveObject<T: Codable>(_ object: T, for key: String) throws {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(object)
            userDefaults.set(data, forKey: key)
        } catch {
            throw PersistenceError.codableError(error)
        }
    }
    
    func getObject<T: Codable>(for key: String) throws -> T {
        if let data = userDefaults.data(forKey: key) {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                throw PersistenceError.codableError(error)
            }
        }
        throw PersistenceError.noDataForKey
    }
}
