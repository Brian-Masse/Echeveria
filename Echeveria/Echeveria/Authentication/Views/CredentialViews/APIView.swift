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
    
    @State var remove: String = "LpOlH5uMKGInzmMFQ7EBqf3Nj4VOd6RY3ztoPqnjsLnY0S40NWRhoH6qJQS1TH6u"
    
    var body: some View {
        
        VStack(alignment: .leading) {
            UniversalText("API Token", size: Constants.UISubHeaderTextSize, lighter: true)
            VStack {
                TextField("Token", text: $APIToken)
                TextField("Copy", text: $remove)
            }
            .opaqueRectangularBackground()
            .padding(.bottom)
            
            AsyncRoundedButton(label: "Login with Token", icon: "lanyardcard") {
                loginModel.APISignIn(APIToken)
                let _ = await loginModel.authenticateUser()
            }   
        }
    }
}
