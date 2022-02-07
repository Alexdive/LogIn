//
//  AlertWithTF.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 07.02.2022.
//

import SwiftUI

struct Alert: View {
    @State private var title: String = ""
    @State private var description: String = ""
    var addAction: (String, String) -> Void
    var cancelAction: () -> Void
    
    var body: some View {
        VStack {
            Text("Enter Task").font(.headline)
                .padding()
            TextField("Type title here", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.leading, .trailing])
                .adaptsToKeyboard()
            TextField("Type description here", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.leading, .trailing])
            Divider()
            HStack(alignment: .center) {
                Spacer()
                Button(action: {
                    if !title.isEmpty || !description.isEmpty {
                        addAction(title, description)
                    }
                }) { Text(" Done ") }
                Spacer()
                Divider()
                Spacer()
                Button(action: {
                    cancelAction()
                }) { Text("Cancel") }
                Spacer()
            }
            Spacer()
        }
        .background(Color(white: 0.95))
        .frame(width: 300, height: 220, alignment: .center)
        .cornerRadius(20).shadow(radius: 20)
        .padding(.bottom, 100)
    }
}
