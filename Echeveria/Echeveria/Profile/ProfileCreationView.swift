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
    
    @State var username: String = ""
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var icon: String = "globe.europe.africa"
    
    @State var loading: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                
                Form {
                    Section("Basic Information") {
                        TextField("First Name", text: $firstName)
                        TextField("Last Name", text: $lastName)
                        TextField("UserName", text: $username)
                        TextField("Icon", text: $icon)
                    }.universalFormSection()
                }.universalForm()
                
                RoundedButton(label: "Done", icon: "checkmark.seal") { loading = true }
            }
            
            if loading {
                ProgressView()
                    .task {
                        //TODO: need to checks that all fields are filled in and that they are a minimum length
                        let profile = EcheveriaProfile(ownerID: "", firstName: firstName, lastName: lastName, userName: username, icon: icon, color: .blue)
                        await EcheveriaModel.shared.realmManager.addProfile(profile: profile)
                    }
            }
        }
        .universalBackground()
        
    }
    
    
    
}
