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

    enum SmashDataKey: String {
        case charachter     = "charachter"
        case damage         = "damage"
        case KOs            = "KOs"
    }
    
    func retrieveValue<T>( _ key: String, defaultValue: T ) -> T {
        if let value: T = values[key] as? T { return value }
        return defaultValue
    }
    
    func createBinding(forKey key: String, defaultValue: String = "") -> Binding<String> {
        Binding { retrieveValue(key, defaultValue: defaultValue)
        } set: { newValue in values[key] = newValue }
    }
    
    @Binding var values: Dictionary<String, String>
    let players: [String]
    
    let smashPlayers = [ "Yoshi", "Gannondwarf", "Terrry" ]
    
    var body: some View {
        
        if players.count != 0 {
            TransparentForm("Game Specific Info") {
                ForEach( players, id:\.self ) { playerID in
                    if let profile = EcheveriaProfile.getProfileObject(from: playerID) {
                        
                        let binding: Binding<String> = createBinding(forKey: playerID + SmashDataKey.charachter.rawValue)
                        BasicPicker(title: profile.firstName, noSeletion: "No Selection", sources: smashPlayers, selection: binding ) { obj in Text( obj ) }
                        
                        TextField(text: createBinding(forKey:  playerID + SmashDataKey.damage.rawValue)) { Text( "Damage %" ) }

                        TextField(text: createBinding(forKey:  playerID + SmashDataKey.KOs.rawValue)) { Text( "KOs" ) }
                    }
                }
            }
        }
    }
}
