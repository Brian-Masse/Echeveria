//
//  EcheveriaApp.swift
//  Echeveria
//
//  Created by Brian Masse on 6/13/23.
//

import SwiftUI

@main

struct EcheveriaApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        
        WindowGroup {
            EcheveriaView()
                .onChange(of: scenePhase) { newValue in
                    if newValue == .background {
                        Task { await EcheveriaModel.shared.realmManager.removeAllNonBaseSubscriptions() }
                    }
                }
        }
    }
}
