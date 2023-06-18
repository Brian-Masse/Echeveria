//
//  OpenFlexibleSyncRealmView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct OpenFlexibleSyncRealmView: View {
    
    @AsyncOpen(appId: "application-0-qufwt", timeout: 4000) var asyncOpen
    
    var body: some View {
        
        switch asyncOpen {
            
        case .connecting:
            VStack {
                NamedButton(text: "Connecting to Realm", icon: "externaldrive.connected.to.line.below")
                ProgressView()
            }
        case .waitingForUser:
            Text("Failed to Login")
            
        case .open(let realm):
            NamedButton(text: "Success!", icon: "checkmark.circle")
                .task {
                    await EcheveriaModel.shared.realmManager.authRealm(realm: realm)
                    await EcheveriaModel.shared.realmManager.checkProfile()
                }
            
        
        case .progress(let progress):
            VStack {
                NamedButton(text: "Downloading Realm from Server", icon: "server.rack")
                ProgressView(progress)
            }
        
        case .error(let error):
            NamedButton(text: "Error Connecting to Realm: \(error)", icon: "xmark.seal")
        }
    }
}
