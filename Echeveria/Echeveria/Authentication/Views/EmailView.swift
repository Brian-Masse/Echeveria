//
//  EmailView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import SwiftUI

struct EmailView: View {
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var userName: String = ""
    
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        
        VStack {
            Form {
                Section("Basic Info") {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("userName", text: $userName)
                }
                
                Section("Account") {
                    TextField("email", text: $email)
                    TextField("password", text: $password)
                }
            }
            .scrollContentBackground(.hidden)
            
            Text("submit!")
            
            NamedButton(text: "Submit", icon: "checkmark.seal") { print("hello!") }
            
            
        }
        
    }
    
    
}