//
//  ContentView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/13/23.
//

import SwiftUI
import RealmSwift

struct EcheveriaView: View {
    
    @ObservedObject var realmManager: RealmManager = EcheveriaModel.shared.realmManager
    
    var body: some View {
        
        if !realmManager.signedIn {
            LoginView(loginModel: loginModel)
        
        } else if !realmManager.realmLoaded {
            OpenFlexibleSyncRealmView()
                .environment(\.realmConfiguration, realmManager.configuration)
            
        } else if !realmManager.hasAccount {
            AccountCreator()
                .environment(\.realmConfiguration, realmManager.configuration)
        }
        else {
            MainView()
                .environment(\.realmConfiguration, realmManager.configuration)
        }
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        signupForm()
//    }
//}
