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
    @State var APIToken: String = ""
    
    var body: some View {
        
        Form {
            Section("API Token") {
                TextField("Token", text: $APIToken)
            }
        }
        
        NamedButton(text: "Submit", icon: "checkmark.seal") {
            loginModel.APISignIn(APIToken)
        }
        
    }
}
