//
//  TaskModel.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 06.02.2022.
//

import Foundation

struct Todo: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var isDone: Bool = false
}

extension Todo {
    static let samples = [
        Todo(title: "Sample task", description: "Tap checkbox to check!"),
        Todo(title: "Sample task", description: "Tap checkbox to uncheck!", isDone: true)
    ]
}
