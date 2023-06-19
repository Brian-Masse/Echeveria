//
//  APIView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import SwiftUI

struct APIView: View {
    
    @EnvironmentObject var loginModel: LoginModel
    @State var APIToken: String = "XlT89XaRYXqoWEuvO15uZLYkfx7ztwb1otSz1zr5CmiE9DG3Rnx12l0XBy1IKsIf"
    
    @Binding var signingIn: Bool
    
    var body: some View {
        
        Form {
            Section("API Token") {
                TextField("Token", text: $APIToken)
            }.universalFormSection()
        }.universalForm()
        
        RoundedButton(label: "Submit", icon: "checkmark.seal") {
            loginModel.APISignIn(APIToken)
            signingIn = true
        }
    }
}
