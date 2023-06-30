//
//  EmailView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import SwiftUI

struct EmailView: View {
    
    @EnvironmentObject var loginModel: LoginModel
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var userName: String = ""
    
    @State var email: String = ""
    @State var password: String = ""
    
    @Binding var signingIn: Bool
    
    @State var error: Error?
    @State var failedToRegisterUser: Bool = false
    
    var body: some View {
        
        VStack(alignment: .leading) {
            UniversalText("email", size: Constants.UISubHeaderTextSize, lighter: true, true)
            VStack(spacing: 10) {
                TextField("email", text: $email)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                SecureField("password", text: $password)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            .opaqueRectangularBackground()
            
            AsyncRoundedButton(label: "Login with email", icon: "envelope") {
                let fixexEmail = RealmManager.stripEmail(email)
                error =  await EcheveriaModel.shared.realmManager.registerUser(fixexEmail, password)
                if error == nil {
                    loginModel.passwordSignIn(fixexEmail, password)
                    
                    error = await loginModel.authenticateUser()
                    if self.error != nil { failedToRegisterUser = true }
                    
                    
                } else { failedToRegisterUser = true }
                
            }
            .alert(isPresented: $failedToRegisterUser) {
                Alert(
                    title: Text("Issue Registering User"),
                    message: Text(error!.localizedDescription),
                    dismissButton: .cancel())
            }
            .padding(.bottom)
        }
    }
    
    
}
