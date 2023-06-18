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
                NamedButton("Connecting to Realm", and: "externaldrive.connected.to.line.below", oriented: .vertical)
                ProgressView()
            }
        case .waitingForUser:
            Text("Failed to Login")
            
        case .open(let realm):
            NamedButton("Success!", and: "checkmark.circle", oriented: .vertical)
                .task {
                    await EcheveriaModel.shared.realmManager.authRealm(realm: realm)
                    await EcheveriaModel.shared.realmManager.checkProfile()
                }
            
        
        case .progress(let progress):
            VStack {
                NamedButton("Downloading Realm from Server", and: "server.rack", oriented: .vertical)
                ProgressView(progress)
            }
        
        case .error(let error):
            NamedButton("Error Connecting to Realm: \(error)", and: "xmark.seal", oriented: .vertical)
        }
    }
}
