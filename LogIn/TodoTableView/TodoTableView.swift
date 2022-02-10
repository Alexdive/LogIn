//
//  TodoTableView.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 11.01.2022.
//

import SwiftUI

struct TodoTableView: View {
    
    @State private var showAlert = false
    @State var editMode: EditMode = .inactive
    // cant make it work with this approach
    //    @Environment(\.editMode) private var editMode
    @StateObject private var viewModel = TasksViewModel()
    
    let userEmail = AuthManager.shared.userEmail ?? ""
    
    var body: some View {
        NavigationView {
            ZStack {
                todoList
                if showAlert {
                    AlertWithTF {
                        viewModel.addTodo(title: $0, description: $1)
                        showAlert.toggle()
                    } cancelAction: {
                        showAlert.toggle()
                    }
                }
                
            }
            .navigationBarTitle(Text("Tasks"))
            .navigationBarItems(leading: EditButton(), trailing: trailingNavBarButtons)
            .environment(\.editMode, $editMode)
        }
    }
    
    @ViewBuilder
    private var trailingNavBarButtons: some View {
        if case editMode = EditMode.inactive {
            HStack {
                Button("LogOut") {
                    AuthManager.shared.signOut()
                }
                Button(action: onAdd) { Image(systemName: "plus") }
            }
        } else {
            EmptyView()
        }
    }
    
    private var todoList: some View {
        List {
            ForEach(viewModel.todos, id: \.self) { task in
                TodoRowView(todo: task, action: {
                    viewModel.toggleDone(todo: task)
                })
            }
            .onDelete(perform: delete)
            .onMove(perform: onMove)
        }
    }
    
    private func onAdd() {
        showAlert.toggle()
    }
    
    private func delete(at offsets: IndexSet) {
        viewModel.remove(atOffsets: offsets)
    }
    
    private func onMove(source: IndexSet, destination: Int) {
        viewModel.move(fromOffsets: source, toOffset: destination)
    }
}

struct TodoTableView_Preview: PreviewProvider {
    static var previews: some View {
        TodoTableView()
    }
}
