//
//  TodoTableViewModel.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 09.02.2022.
//

import Foundation


final class TasksViewModel: ObservableObject {
    let db: Persistence
    
    @Published private(set) var todos: [Todo]
    
    init() {
        db = Persister()
        // need to think how to handle these errors in terms of UX
        todos = (try? db.getObject(for: db.todoKey)) ?? Todo.samples
    }
    
    func reload() {
        todos = (try? db.getObject(for: db.todoKey)) ?? []
    }
    
    func saveTodos() {
        try? db.saveObject(todos, for: db.todoKey)
        reload()
    }
    
    func toggleDone(todo: Todo) {
        if let index = todos.firstIndex(where: { $0.id == todo.id }) {
            todos[index].isDone.toggle()
            saveTodos()
        }
    }
    
    func addTodo(title: String, description: String) {
        todos.insert(Todo(title: title, description: description), at: 0)
        saveTodos()
    }
    
    func remove(atOffsets: IndexSet) {
        todos.remove(atOffsets: atOffsets)
        saveTodos()
    }
    
    func move(fromOffsets: IndexSet, toOffset: Int) {
        todos.move(fromOffsets: fromOffsets, toOffset: toOffset)
        saveTodos()
    }
}
