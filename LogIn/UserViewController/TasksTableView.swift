//
//  TasksTableView.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 11.01.2022.
//

import UIKit
import SwiftUI

final class TasksViewModel: ObservableObject {
    @Published var tasks: [Task] = Task.getTasks() {
        didSet {
            Task.setTasks(tasks)
        }
    }
}

struct TasksTableView: View {
    
    @State var showAlert = false
    @State private var editMode = EditMode.inactive
    @StateObject private var viewModel = TasksViewModel()
    
    let userEmail = AuthManager.shared.userEmail ?? ""
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach($viewModel.tasks, id: \.self) { $task in
                        TaskRowView(task: $task)
                    }
                    .onDelete(perform: delete)
                    .onMove(perform: onMove)
                }
                if $showAlert.wrappedValue {
                    Alert {
                        viewModel.tasks.append(Task(title: $0, description: $1))
                        showAlert.toggle()
                    } cancelAction: {
                        showAlert.toggle()
                    }
                }
            }
            .navigationBarTitle(Text("Tasks"))
            .navigationBarItems(leading: EditButton(), trailing: addButton)
            .environment(\.editMode, $editMode)
            .toolbar {
                Button("LogOut") {
                    AuthManager.shared.signOut()
                }
            }
        }
    }
    
    private var addButton: some View {
        switch editMode {
        case .inactive:
            return AnyView(Button(action: onAdd) { Image(systemName: "plus") })
        default:
            return AnyView(EmptyView())
        }
    }
    
    private func onAdd() {
        showAlert.toggle()
    }
    
    private func delete(at offsets: IndexSet) {
        viewModel.tasks.remove(atOffsets: offsets)
    }
    
    private func onMove(source: IndexSet, destination: Int) {
        viewModel.tasks.move(fromOffsets: source, toOffset: destination)
    }
}
