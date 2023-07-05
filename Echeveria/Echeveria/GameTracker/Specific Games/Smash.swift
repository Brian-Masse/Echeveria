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
    
    enum SmashDataKey: String {
        case charachter     = "charachter"
        case damage         = "damage"
        case KOs            = "KOs"
        case charachterCount = "charachterCount"
    }
    
    struct SmashPreferencesForm: View {
        
        func retrieveValue<T>( _ key: String, defaultValue: T) -> T {
            if let value: T = preferences[key] as? T { return value }
            return defaultValue
        }
        
        func createBinding(forKey key: String, defaultValue: String = "") -> Binding<String> {
            Binding { self.retrieveValue(key, defaultValue: defaultValue)
            } set: { newValue in preferences[key] = newValue }
        }
        
        @Binding var preferences: Dictionary<String, String>
        
        var body: some View {
            
            let count = Int(preferences[EcheveriaModel.shared.profile.ownerID + Smash.SmashDataKey.charachterCount.rawValue] ?? "0") ?? 0
            
            VStack {
                TransparentForm("Smash Preferences") {
                    ForEach( 0...count, id: \.self ) { i in
                        let key = EcheveriaModel.shared.profile.ownerID + Smash.SmashDataKey.charachter.rawValue + "\(i)"
                        let value = preferences[ key ] ?? "No Selection"
                        
                        let binding: Binding<String> = createBinding(forKey: key, defaultValue: value)
                        BasicPicker(title: "Main \(i + 1)", noSeletion: "No Selection", sources: Smash.smashPlayers, selection: binding ) { obj in Text( obj ) }
                        
                    }
                        
                }
                RoundedButton(label: "Add Another", icon: "plus") {
                    preferences[EcheveriaModel.shared.profile.ownerID + Smash.SmashDataKey.charachterCount.rawValue] =
                        "\(Int( preferences[EcheveriaModel.shared.profile.ownerID + Smash.SmashDataKey.charachterCount.rawValue]  ?? "0" )! + 1)"
                }
            }
        }
        
    }

    struct SmashForm: View {
        
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
                TransparentForm("Game Specific Info") {
                    ForEach( players, id:\.self ) { playerID in
                        if let profile = EcheveriaProfile.getProfileObject(from: playerID) {
                            
                            let binding: Binding<String> = createBinding(forKey: playerID + Smash.SmashDataKey.charachter.rawValue)
                            
                            HStack {
                                
                                UniversalText(profile.firstName, size: Constants.UIDefaultTextSize)
                                Spacer()
                                
                                Menu {
                                    Menu("Favorites") {
                                        let node = profile.getGameDataNode( profile.ownerID + Smash.SmashDataKey.charachterCount.rawValue )
                                        let count = Int( node?.data ?? "0"  ) ?? 0
                                        
                                        ForEach( 0...count, id: \.self ) { i in
                                            let key = profile.ownerID + Smash.SmashDataKey.charachter.rawValue + "\(i)"
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
                                    Text( values[ playerID + Smash.SmashDataKey.charachter.rawValue ] ?? "No Selection"  )
                                    ResizeableIcon(icon: "chevron.up.chevron.down", size: Constants.UIDefaultTextSize)
                                }
                                .foregroundColor(Colors.tint)
                            }
                            
                            TextField(text: createBinding(forKey:  playerID + Smash.SmashDataKey.damage.rawValue)) { Text( "Damage %" ) }

                            TextField(text: createBinding(forKey:  playerID + Smash.SmashDataKey.KOs.rawValue)) { Text( "KOs" ) }
                        }
                    }
                }
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
