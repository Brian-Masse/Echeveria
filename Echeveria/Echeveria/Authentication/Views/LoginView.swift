//
//  LoginView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/13/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct LoginView: View {

    @ObservedObject var loginModel: LoginModel
    
    @State var signinMethod: LoginModel.LoginMethod = .email
    
    var body: some View {
    
        ZStack {
            if loginModel.signingIn {
                ProgressView()
                    .task { await loginModel.authenticateUser() }
            }else {
                
                VStack {
                    Picker("Sign in Method", selection: $signinMethod) {
                        ForEach( LoginModel.LoginMethod.allCases ) { content in
                            Text( content.rawValue )
                        }
                    }.pickerStyle(.segmented)
                    Spacer()
                    switch signinMethod {
                    case .API:          APIView()
                    case .email:        EmailView()
                    case .Apple:        Text("Apple")
                    case .Anonymous:    NamedButton(text: "Login", icon: "checkmark.seal") { loginModel.AnonymousSignIn() }
                    }
                }
            }
        }
        .environmentObject(loginModel)
        .padding()
        .background(Colors.lightGrey)
    }
}


//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}
