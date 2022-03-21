//
//  AlertWithTF.swift
//  LogIn
//
//  Created by Aleksei Permiakov on 07.02.2022.
//

import SwiftUI

// check system alert
struct AlertWithTF: View {
    @State private var title: String = ""
    @State private var description: String = ""
    var addAction: (String, String) -> Void
    var cancelAction: () -> Void
    
    let width: CGFloat = 300
    
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
            HStack {
                Button(action: {
                    if !title.isEmpty || !description.isEmpty {
                        addAction(title, description)
                    }
                }) {
                    Text("Done")
                }
                .frame(maxWidth: .infinity)
               Divider()
                Button(action: {
                    cancelAction()
                }) {
                    Text("Cancel")
                }
                .frame(maxWidth: .infinity)
            }
            .frame(height: 45)
            Spacer()
        }
        .background(Color(white: 0.95))
        .frame(width: width, height: 220, alignment: .center)
        .cornerRadius(20).shadow(radius: 20)
        .padding(.bottom, 100)
    }
}

struct AlertWithTF_Previews: PreviewProvider {
    static var previews: some View {
        AlertWithTF { _, _ in
        } cancelAction: {}
    }
}
