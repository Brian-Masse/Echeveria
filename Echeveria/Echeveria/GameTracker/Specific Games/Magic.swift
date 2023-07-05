//
//  Magic.swift
//  Echeveria
//
//  Created by Brian Masse on 7/5/23.
//

import Foundation
import SwiftUI
import RealmSwift

class Magic {
    
    enum DataKey: String {
        case deckCount  = "deckCount"
        case deck       = "deck"
    }
    
    struct PreferencesForm: View {
        
        func createBinding(forKey key: String, defaultValue: String = "") -> Binding<String> {
            Binding { preferences[key] ?? defaultValue
            } set: { newValue in preferences[key] = newValue }
        }
        
        @Binding var preferences: Dictionary<String, String>
        
        var body: some View {
            
            let countKey    = EcheveriaModel.shared.profile.ownerID + Magic.DataKey.deckCount.rawValue
            let count       = Int(preferences[countKey] ?? "0") ?? 0
            
            VStack {
                
                TransparentForm("Magic Preferences") {
                    
                    ForEach(0...count, id: \.self) { i in
                        
                        let deckKey = EcheveriaModel.shared.profile.ownerID + Magic.DataKey.deck.rawValue + "\(i)"
                    
                        TextField(text: createBinding(forKey: deckKey)) {
                            UniversalText("Deck \( i + 1 )", size: Constants.UIDefaultTextSize, lighter: true )
                        }
                    }
                }
                
                RoundedButton(label: "Add Another Deck", icon: "plus") {
                    preferences[ countKey ] = "\(count + 1)"
                }
            }
        }   
    }
    
    struct InputForm: View {
     
        func createBinding(forKey key: String, defaultValue: String = "") -> Binding<String> {
            Binding { values[key] ?? defaultValue
            } set: { newValue in values[key] = newValue }
        }
        
        @Binding var values: Dictionary< String, String >
        let players: [String]
        
        var body: some View {
            
            if players.count != 0 {
                
                TransparentForm("Magic Info") {
                    ForEach( players, id: \.self ) { profileID in
                        if let profile = EcheveriaProfile.getProfileObject(from: profileID) {
                            
                            let deckCountKey = profile.ownerID + Magic.DataKey.deckCount.rawValue
                            let deckKey      = profile.ownerID + Magic.DataKey.deck.rawValue
                            
                            let count = Int( profile.getGameDataNode(deckCountKey)?.data ?? "0" ) ?? 0
                            
                            HStack {
                                UniversalText("\(profile.firstName)", size: Constants.UIDefaultTextSize, lighter: true)
                                Spacer()
                                
                                if count == 0 { UniversalText( "No Decks", size: Constants.UIDefaultTextSize, lighter: true ) }
                                
                                Picker("Deck", selection: createBinding(forKey: deckKey, defaultValue: "No Selection")) {
                                    ForEach( 0...count, id: \.self) { i in
                                        let key = profile.ownerID + Magic.DataKey.deck.rawValue + "\(i)"
                                        if let node = profile.getGameDataNode(key) {
                                            Text( node.data ).tag( node.data )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    struct GameDisplay: View {
        
        let players: [String]
        let gameData: [GameDataNode]
        
        var body: some View {
            
            if players.count != 0 {
                ForEach(players, id: \.self) { profileID in
                    if let profile = EcheveriaProfile.getProfileObject(from: profileID) {
                        
                        let deckKey = profileID + Magic.DataKey.deck.rawValue
                        
                        HStack {
                            UniversalText(profile.firstName, size: Constants.UIDefaultTextSize, true)
                            Spacer()
                            UniversalText( EcheveriaGame.getNodeData(from: deckKey, in: gameData), size: Constants.UIDefaultTextSize)
                        }
                        .padding()
                        .universalTextStyle()
                        .rectangularBackgorund()
                    }
                }
            }
        }
    }
}
