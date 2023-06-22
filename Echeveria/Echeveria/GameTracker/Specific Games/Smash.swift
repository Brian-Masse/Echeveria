//
//  Smash.swift
//  Echeveria
//
//  Created by Brian Masse on 6/22/23.
//

import Foundation
import SwiftUI
import RealmSwift


protocol EcheveriaIndividualGame {
    
//    associatedtype Content: View
    
//    @ViewBuilder var formBuilder: ( Binding<Dictionary<String, Any>>, [EcheveriaProfile] ) -> Content   {get}
    
//    @ViewBuilder var viewBuilder: ( any EcheveriaIndividualGame ) -> Content            {get}
    
    var properties: Dictionary<String, String> {get set}
}

class Smash<Content>: EcheveriaIndividualGame where Content: View {

    var properties: Dictionary<String, String>
    
    init( _ properties: Dictionary<String, String> ) {
        self.properties = properties
    }
}

struct SmashForm: View {

    func retrieveValue<T>( _ key: String, defaultValue: T ) -> T {
        if let value: T = values[key] as? T { return value }
        return defaultValue
    }
    
    func createBinding(forKey key: String, defaultValue: String) -> Binding<String> {
        Binding {
            retrieveValue(key, defaultValue: defaultValue)
        } set: { newValue in
            values[key] = newValue
        }
    }
    
    @Binding var values: Dictionary<String, String>
    let players: [String]
    
    let smashPlayers = [ "Yoshi", "Gannondwarf", "Terrry" ]
    
    var body: some View {
        
        Section("Smash Specific Information") {
            ForEach( players, id:\.self ) { playerID in
                if let profile = EcheveriaProfile.getProfileObject(from: playerID) {
                    
                    Picker(selection: createBinding(forKey: playerID, defaultValue: "No Selection")) {
                        Text("No Selection").tag("No Selection")
                        ForEach( smashPlayers, id: \.self ) { player in
                            Text(player)
                        }
                    } label: {
                        Text(profile.firstName)
                    }
                }
            }
        }.universalFormSection()
    }
}
