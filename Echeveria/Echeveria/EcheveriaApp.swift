//
//  EcheveriaApp.swift
//  Echeveria
//
//  Created by Brian Masse on 6/13/23.
//

import SwiftUI

let model = Model()

@main
struct EcheveriaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
    }
}
