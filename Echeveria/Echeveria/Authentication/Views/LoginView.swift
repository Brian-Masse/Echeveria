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
    
    @ObservedObject var loginModel: LoginModel = LoginModel.shared
    
    @State var signinMethod: LoginModel.LoginMethod = .email
    @State var devMode: Bool = false
    
    @ViewBuilder
    func form(geo: GeometryProxy) -> some View {
        VStack(alignment: .leading) {
            EmailView()
                .padding(.bottom, 20)
            
            Toggle(isOn: $devMode) {
                UniversalText("Advanced Options", size: Constants.UISubHeaderTextSize, lighter: true, true)
            }.tint(Colors.tint)
            
            if devMode {
                APIView()
                    .padding(.bottom)
                
                UniversalText("Anonymous", size: Constants.UISubHeaderTextSize, lighter: true)
                AsyncRoundedButton(label: "Login Anonymously", icon: "person.badge.clock") {
                    loginModel.AnonymousSignIn()
                    let _ = await loginModel.authenticateUser()
                }
                UniversalText( "An anonymous account has the same permissions as a regular user, but is deleted when logging out. Do not sign in anonymously for long term use.", size: Constants.UIDefaultTextSize, wrap: true, lighter: true )
                    .frame(width: geo.size.width - 65)
                    .fixedSize()
            
                AsyncRoundedButton(label: "Refresh", icon: "arrow.clockwise") {
                    EcheveriaModel.shared.realmManager.realm = nil
                    
                    do {
                        let user  = try await EcheveriaModel.shared.realmManager.app.login(credentials: .anonymous)
                        let configuration = user.flexibleSyncConfiguration()
                        _ = try Realm.deleteFiles(for: configuration)
                        
                    } catch { print(error.localizedDescription) }
                }
            }
        }
        .animation(.default, value: devMode)
        .padding()
        .rectangularBackgorund()
        .padding(.horizontal, 15)
        .padding(.vertical, 20)
        .padding(.bottom, 40)
        .shadow(radius: 10)
    }
    
    var body: some View {
    
        GeometryReader { geo in
            VStack {
                Spacer()
                Image("signin.backgorund")
                    .resizable()
                    .renderingMode(.template)
                    .rotationEffect(Angle( degrees: -20 ))
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geo.size.width + 200)
                    .offset(x: -120, y: 50)
                    .foregroundColor(Colors.main)
                    .opacity(0.7)
            }.ignoresSafeArea(.keyboard)
            
            VStack(alignment: .leading) {
                UniversalText("Choose Sign in Method", size: Constants.UITitleTextSize, true)
                    .padding(.horizontal, 15)
                
                if devMode { ScrollView(.vertical) {
                    form(geo: geo)
                }} else {
                    form(geo: geo)
                }
            }
        }
        .environmentObject(loginModel)
        .universalColoredBackground( Colors.tint )
    }
}

