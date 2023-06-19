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

    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var loginModel: LoginModel
    
    @State var signinMethod: LoginModel.LoginMethod = .email
    @State var signingIn: Bool = false
    
    var body: some View {
    
        ZStack {
            if signingIn {
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
                    case .API:          APIView(signingIn: $signingIn)
                    case .email:        EmailView()
                    case .Apple:        Text("Apple")
                    case .Anonymous:    RoundedButton(label: "Login", icon: "checkmark.seal") { self.signingIn = true; loginModel.AnonymousSignIn() }
                    }
                }
            }
        }
        .environmentObject(loginModel)
        .padding()
        .background(colorScheme == .light ? Colors.lightGrey : .black)
    }
}


//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}
