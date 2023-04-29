//
//  TodoRowView.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 06.02.2022.
//

import SwiftUI

private struct CheckMarkButton: ButtonStyle {
    @Binding var isDone: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        Image(systemName: isDone ? "checkmark.circle.fill" : "checkmark.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(isDone ? .green : .red)
            .frame(height: 36)
    }
}

struct TodoRowView: View {
    @State var todo: Todo
    var action: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            Button { action () }
                   label: {}
                .buttonStyle(CheckMarkButton(isDone: $todo.isDone))
            
            VStack(alignment: .leading) {
                Text(todo.title)
                    .font(.headline)
                Text(todo.description)
                    .font(.subheadline)
            }
            .padding()
        }
    }
}

struct TodoRowView_Previews: PreviewProvider {
    static var previews: some View {
        List(Todo.samples) { todo in
            TodoRowView(todo: todo){}
        }
    }
}
