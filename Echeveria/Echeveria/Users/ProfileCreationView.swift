//
//  UserCreationView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import SwiftUI


struct ProfileCreationView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var username: String = "Brian"
    @State var firstName: String = "Masse"
    @State var lastName: String = "bmasse23"
    
    @State var loading: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                
                Form {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("UserName", text: $username)
                }.scrollContentBackground(.hidden)
                
                RoundedButton(label: "Done", icon: "checkmark.seal") { loading = true }
            }
            
            if loading {
                ProgressView()
                    .task {
                        //TODO: need to checks that all fields are filled in and that they are a minimum length
                        let profile = EcheveriaProfile(ownerID: "", firstName: firstName, lastName: lastName, userName: username)
                        await EcheveriaModel.shared.realmManager.addProfile(profile: profile)
                    }
            }
        }
        .padding()
        .background(colorScheme == .light ? Colors.lightGrey : .black)
        
    }
    
    
    
}
