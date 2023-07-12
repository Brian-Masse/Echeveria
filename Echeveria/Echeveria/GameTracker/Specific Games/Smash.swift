//
//  Smash.swift
//  Echeveria
//
//  Created by Brian Masse on 6/22/23.
//

import Foundation
import SwiftUI
import RealmSwift

class Smash {
    
    enum DataKey: String {
        case charachter     = "charachter"
        case damage         = "damage"
        case KOs            = "KOs"
        case charachterCount = "charachterCount"
    }
    
    struct PreferencesForm: View {
        
        @Environment(\.colorScheme) var colorScheme
        
        func createBinding(forKey key: String, defaultValue: String = "") -> Binding<String> {
            Binding { preferences[key] ?? defaultValue
            } set: { newValue in preferences[key] = newValue }
        }
        
        @Binding var preferences: Dictionary<String, String>
        
        var body: some View {
            
            let count = Int(preferences[EcheveriaModel.shared.profile.ownerID + Smash.DataKey.charachterCount.rawValue] ?? "0") ?? 0
            
            VStack {
                TransparentForm("Smash Preferences") {
                    ForEach( 0...count, id: \.self ) { i in
                        let key = EcheveriaModel.shared.profile.ownerID + Smash.DataKey.charachter.rawValue + "\(i)"
                        let value = preferences[ key ] ?? "No Selection"
                        
                        let binding: Binding<String> = createBinding(forKey: key, defaultValue: value)
                        BasicPicker(title: "Main \(i + 1)", noSeletion: "No Selection", sources: Smash.smashPlayers, selection: binding ) { obj in Text( obj ) }
//                            .tint( colorScheme == .light ? .black : .white )
                    }
                        
                }
                RoundedButton(label: "Add Another", icon: "plus") {
                    preferences[EcheveriaModel.shared.profile.ownerID + Smash.DataKey.charachterCount.rawValue] =
                        "\(Int( preferences[EcheveriaModel.shared.profile.ownerID + Smash.DataKey.charachterCount.rawValue]  ?? "0" )! + 1)"
                }
            }
        }
        
    }

    struct InputForm: View {
        
        func retrieveValue<T>( _ key: String, defaultValue: T) -> T {
            if let value: T = values[key] as? T { return value }
            return defaultValue
        }
        
        func createBinding(forKey key: String, defaultValue: String = "") -> Binding<String> {
            Binding { self.retrieveValue(key, defaultValue: defaultValue)
            } set: { newValue in values[key] = newValue }
        }

        @Binding var values: Dictionary<String, String>
        let players: [String]
        
        var body: some View {
            
            if players.count != 0 {
                TransparentForm("Smash Info") {
                    ForEach( players, id:\.self ) { playerID in
                        if let profile = EcheveriaProfile.getProfileObject(from: playerID) {
                            
                            let binding: Binding<String> = createBinding(forKey: playerID + Smash.DataKey.charachter.rawValue)
                            
                            HStack {
                                
                                UniversalText(profile.firstName, size: Constants.UIDefaultTextSize)
                                Spacer()
                                
                                Menu {
                                    Menu("Favorites") {
                                        let node = profile.getGameDataNode( profile.ownerID + Smash.DataKey.charachterCount.rawValue )
                                        let count = Int( node?.data ?? "0"  ) ?? 0
                                        
                                        ForEach( 0...count, id: \.self ) { i in
                                            let key = profile.ownerID + Smash.DataKey.charachter.rawValue + "\(i)"
                                            if let characterNode = profile.getGameDataNode(key) {
                                                Button(characterNode.data) { binding.wrappedValue = characterNode.data }
                                            }
                                        }
                                    }
                                    
                                    Menu("All") {
                                        ForEach(Smash.smashPlayers, id: \.self) { player in
                                            Button(player) { binding.wrappedValue = player }
                                        }
                                    }
                                    
                                } label: {
                                    Text( values[ playerID + Smash.DataKey.charachter.rawValue ] ?? "No Selection"  )
                                    ResizeableIcon(icon: "chevron.up.chevron.down", size: Constants.UIDefaultTextSize)
                                }
                                .foregroundColor(Colors.tint)
                            }
                            
                            TextField(text: createBinding(forKey:  playerID + Smash.DataKey.damage.rawValue)) { Text( "Damage %" ) }
                                .keyboardType(.decimalPad)

                            TextField(text: createBinding(forKey:  playerID + Smash.DataKey.KOs.rawValue)) { Text( "KOs" ) }
                                .keyboardType(.decimalPad)
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
            
            ForEach(players, id: \.self) { playerID in
                VStack(alignment: .leading) {
                    if let profile = EcheveriaProfile.getProfileObject(from: playerID) {
                        UniversalText("\(profile.firstName) \(profile.lastName)", size: Constants.UISubHeaderTextSize, true)
                            .padding(.bottom, 5)
                        HStack {
                            VStack(alignment:.leading) {
                                UniversalText("Character", size: Constants.UIDefaultTextSize, true)
                                UniversalText("Damage", size: Constants.UIDefaultTextSize, true)
                                UniversalText("KOs", size: Constants.UIDefaultTextSize, true)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                UniversalText( EcheveriaGame.getNodeData(from: playerID + Smash.DataKey.charachter.rawValue, in: gameData), size: Constants.UIDefaultTextSize, lighter: true)
                                UniversalText( EcheveriaGame.getNodeData(from: playerID + Smash.DataKey.damage.rawValue, in: gameData), size: Constants.UIDefaultTextSize, lighter: true)
                                UniversalText( EcheveriaGame.getNodeData(from: playerID + Smash.DataKey.KOs.rawValue, in: gameData), size: Constants.UIDefaultTextSize, lighter: true)
                            }
                        }
                    }
                }
                .padding()
                .universalTextStyle()
                .rectangularBackgorund()
                .padding(.bottom, 5)
                
            }
        }
    }
    
    static let smashPlayers = [ "Banjo and Kazooie",
                                "Bayonetta",
                                "Bowser",
                                "Bowser Jr.",
                                "Byleth",
                                "Captain Falcon",
                                "Chrom",
                                "Cloud",
                                "Corrin",
                                "Daisy",
                                "Dark Pit",
                                "Dark Samus",
                                "Diddy Kong",
                                "Donkey Kong",
                                "Dr. Mario",
                                "Duck Hunt",
                                "Falco",
                                "Fox",
                                "Ganondorf",
                                "Greninja",
                                "Hero",
                                "Ice Climbers",
                                "Ike",
                                "Incineroar",
                                "Inkling",
                                "Isabelle",
                                "Jigglypuff",
                                "Joker",
                                "Kazuya Mishima",
                                "Ken",
                                "King Dedede",
                                "King K. Rool",
                                "Kirby",
                                "Link",
                                "Little Mac",
                                "Lucario",
                                "Lucas",
                                "Lucina",
                                "Luigi",
                                "Mario",
                                "Marth",
                                "Mega Man",
                                "Meta Knight",
                                "Mewtwo",
                                "Mii Brawler",
                                "Mii Gunner",
                                "Mii Swordfighter",
                                "Min Min",
                                "Mr. Game & Watch",
                                "Ness",
                                "Olimar",
                                "Pac-Man",
                                "Palutena",
                                "Peach",
                                "Pichu",
                                "Pikachu",
                                "Piranha Plant",
                                "Pit",
                                "Pokémon Trainer",
                                "Princess Zelda",
                                "Pyra/Mythra",
                                "R.O.B.",
                                "Richter",
                                "Ridley",
                                "Robin",
                                "Rosalina and Luma",
                                "Roy",
                                "Ryu",
                                "Samus",
                                "Sephiroth",
                                "Sheik",
                                "Shulk",
                                "Simon",
                                "Snake",
                                "Sonic",
                                "Sora",
                                "Steve",
                                "Terry",
                                "Toon Link",
                                "Villager",
                                "Wario",
                                "Wii Fit Trainer",
                                "Wolf",
                                "Yoshi",
                                "Young Link",
                                "Zero Suit Samus",


 ]
    
}
