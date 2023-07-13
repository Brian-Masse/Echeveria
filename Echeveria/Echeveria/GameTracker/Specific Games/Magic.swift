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
        case deckDescription = "deckDescription"
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
            
            VStack(alignment: .leading) {
                
                ForEach(0...count, id: \.self) { i in
                    
                    let deckKey = EcheveriaModel.shared.profile.ownerID + Magic.DataKey.deck.rawValue + "\(i)"
                    let descriptionKey = EcheveriaModel.shared.profile.ownerID + Magic.DataKey.deckDescription.rawValue + "\(i)"
                    
                    TransparentForm("\( preferences[deckKey] ?? "New Deck" )") {
                    
                        HStack {
                            TextField(text: createBinding(forKey: deckKey)) {
                                UniversalText("Deck \( i + 1 )", size: Constants.UIDefaultTextSize, lighter: true )
                            }
                            Spacer()
                            ShortRoundedButton("delete", icon: "trash") {
                                preferences[deckKey] = nil
                                preferences[descriptionKey] = nil
                                preferences[ countKey ] = "\(count - 1)"
                            }
                        }
                        
                        TextField(text: createBinding(forKey: descriptionKey)) {
                            UniversalText("Description", size: Constants.UIDefaultTextSize, lighter: true )
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
     
        func createBinding(for profile: EcheveriaProfile, defaultValue: String = "") -> Binding<String> {
            Binding { values[profile.ownerID + Magic.DataKey.deck.rawValue] ?? defaultValue
            } set: { newValue in
                values[profile.ownerID + Magic.DataKey.deck.rawValue] = newValue
                
                if let preferenceNode = profile.gamePreferences.first(where: { node in node.data == newValue }) {
                    let stripped = preferenceNode.key.replacingOccurrences(of: profile.ownerID, with: "")
                    let index = stripped.filter("0123456789.".contains)
                    if let node = profile.getGameDataNode(profile.ownerID + Magic.DataKey.deckDescription.rawValue + index ) {
                        values[profile.ownerID + Magic.DataKey.deckDescription.rawValue] = node.data
                    }
                }
            }
        }
        
        @Binding var values: Dictionary< String, String >
        let players: [String]
        
        var body: some View {
            
            if players.count != 0 {
                
                TransparentForm("Magic Info") {
                    ForEach( players, id: \.self ) { profileID in
                        if let profile = EcheveriaProfile.getProfileObject(from: profileID) {
                            
                            let deckCountKey = profile.ownerID + Magic.DataKey.deckCount.rawValue
                            
                            let count = Int( profile.getGameDataNode(deckCountKey)?.data ?? "0" ) ?? 0
                            
                            HStack {
                                UniversalText("\(profile.firstName)", size: Constants.UIDefaultTextSize, lighter: true)
                                Spacer()
                                
                                if count == 0 { UniversalText( "No Decks", size: Constants.UIDefaultTextSize, lighter: true ) }
                                
                                Picker("Deck", selection: createBinding(for: profile, defaultValue: "No Selection")) {
                                    ForEach( 0...count, id: \.self) { i in
                                        let key = profile.ownerID + Magic.DataKey.deck.rawValue + "\(i)"
                                        if let node = profile.getGameDataNode(key) {
                                            Text(node.data).tag( node.data )
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
                        let descriptionKey = profileID + Magic.DataKey.deckDescription.rawValue
                        
                        HStack {
                            UniversalText(profile.firstName, size: Constants.UISubHeaderTextSize, true)
                            Spacer()
                            VStack(alignment: .trailing) {
                                UniversalText( EcheveriaGame.getNodeData(from: deckKey, in: gameData), size: Constants.UISubHeaderTextSize, true)
                                UniversalText( EcheveriaGame.getNodeData(from: descriptionKey, in: gameData), size: Constants.UIDefaultTextSize)
                            }.padding(.leading, 20)
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
