//
//  EcheveriaApp.swift
//  Echeveria
//
//  Created by Brian Masse on 6/13/23.
//

import SwiftUI

let echeveriaModel = EcheveriaModel()
let loginModel = LoginModel()

@main
struct EcheveriaApp: App {
    var body: some Scene {
        WindowGroup {
            EcheveriaView()
        }
    }
}
