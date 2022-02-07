//
//  TaskRowView.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 06.02.2022.
//

import SwiftUI

struct TaskRowView: View {
    @Binding var task: Task
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: task.isDone ? "checkmark.circle.fill" : "checkmark.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(task.isDone ? .green : .red)
                .frame(height: 40)
                .gesture(TapGesture()
                            .onEnded({ _ in
                    task.isDone.toggle()
                }))
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                Text(task.description)
                    .font(.subheadline)
            }
            .padding()
        }
    }
}
