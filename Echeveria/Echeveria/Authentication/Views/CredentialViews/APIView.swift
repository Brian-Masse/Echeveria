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
        
        VStack(alignment: .leading) {
            UniversalText("API Token", size: Constants.UISubHeaderTextSize, lighter: true)
            VStack {
                TextField("Token", text: $APIToken)
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
