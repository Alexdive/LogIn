//
//  TaskModel.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 06.02.2022.
//

import Foundation

struct Task: Identifiable, Hashable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var isDone: Bool = false
}

extension Task {
    static let samples = [
        Task(title: "Sample task", description: "Tap checkbox to check!")
    ]
    
    // I know we need to make some kind of persistance layer for that :)
    static func setTasks(_ tasks: [Task]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(tasks)
            UserDefaults.standard.set(data, forKey: "Tasks")
        } catch {
            print("Unable to Encode Tasks (\(error))")
        }
    }
    
    static func getTasks() -> [Task] {
        if let data = UserDefaults.standard.data(forKey: "Tasks") {
            do {
                let decoder = JSONDecoder()
                return try decoder.decode([Task].self, from: data)
            } catch {
                print("Unable to Decode Tasks (\(error))")
            }
        }
        return Task.samples
    }
}
