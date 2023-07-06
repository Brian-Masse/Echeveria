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
        
        VStack {
            if !realmManager.signedIn {
                LoginView()
                    .transition( .asymmetric(insertion: .push(from: .leading), removal: .push(from: .trailing)) )
                
            } else if !realmManager.realmLoaded {
                OpenFlexibleSyncRealmView()
                    .transition( .push(from: .trailing) )
                    .environment(\.realmConfiguration, realmManager.configuration)
                
            } else if !realmManager.hasProfile {
                ProfileViews.EditingProfileView(creatingProfile: true,
                                                firstName: "",
                                                lastName: "",
                                                userName: "",
                                                icon: "globe.europe.africa",
                                                color: Colors.main,
                                                preferences: Dictionary())
                    .transition( .push(from: .trailing) )
                    .environment(\.realmConfiguration, realmManager.configuration)
            }
            else {
                MainView()
                    .transition( .asymmetric(insertion: .push(from: .trailing), removal: .push(from: .leading)) )
                    .environment(\.realmConfiguration, realmManager.configuration)
            }
        }
        .animation(.default, value: realmManager.signedIn)
        .animation(.default, value: realmManager.realmLoaded)
        .animation(.default, value: realmManager.hasProfile)
        
    }
}
