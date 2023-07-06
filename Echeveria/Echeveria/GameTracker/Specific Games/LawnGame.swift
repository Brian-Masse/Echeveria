//
//  Spikeball.swift
//  Echeveria
//
//  Created by Brian Masse on 7/5/23.
//

import Foundation
import SwiftUI

class LawnGame {
    
    enum DataKey: String {
        case team1  = "team1"
        case team1Score = "team1Score"
        case team2  = "team2"
        case team2Score = "team2Score"
    }
    
    struct InputForm: View {
     
        func createBinding(forKey key: String, defaultValue: String = "") -> Binding<String> {
            Binding { values[key] ?? defaultValue
            } set: { newValue in values[key] = newValue }
        }
        
        func createListBinding(forBaseKey teamKey: String) -> Binding<[String]> {
            Binding {
                var node: String? = values[teamKey + "0"]
                var iterator: Int = 0
                var list: [String] = []
                
                while node != nil {
                    list.append(node!)
                    iterator += 1
                    node = values[teamKey + "\(iterator)"]
                }
                return list

            } set: { newValues in
                for i in 0..<newValues.count {
                    let key = teamKey + "\(i)"
                    values[key] = newValues[i]
                }
            }
        }
        
        @Binding var values: Dictionary< String, String >
        let players: [String]
        
        @ViewBuilder
        private func teamFormBuilder(teamKey: String, scoreKey: String) -> some View {
            let team1Binding = createListBinding(forBaseKey: teamKey)
            
            MultiPicker(title: "Team 1", selectedSources: team1Binding, sources: players) { profileID in
                if let profile = EcheveriaProfile.getProfileObject(from: profileID) { return profile.firstName }; return nil
            } sourceName: { profileID in
                if let profile = EcheveriaProfile.getProfileObject(from: profileID) { return "\(profile.firstName) \(profile.lastName)" }; return nil
            }

        
            TextField("score", text: createBinding(forKey: scoreKey))
        }
        
        var body: some View {
            
            if players.count != 0 {
                
                TransparentForm("Spikeball teams") {
                    
                    teamFormBuilder(teamKey: LawnGame.DataKey.team1.rawValue, scoreKey: LawnGame.DataKey.team1Score.rawValue)
                    teamFormBuilder(teamKey: LawnGame.DataKey.team2.rawValue, scoreKey: LawnGame.DataKey.team2Score.rawValue)
                }
            }
        }
    }
    
    struct GameDisplay: View {
        
        let players: [String]
        let gameData: [GameDataNode]
        
        private func getTeamNames(from key: String) -> [String] {
            
            var names: [String] = []
            var name: String = EcheveriaGame.getNodeData(from: key + "0", in: gameData)
            var iterator = 0
            
            while name != EcheveriaGame.emptyGameDataNodeTitle {
                names.append(name)
                iterator += 1
                name = EcheveriaGame.getNodeData(from: key + "\(iterator)", in: gameData)
            }
            return names
        }
        
        @ViewBuilder
        private func teamViewBuilder( _ title: String, teamKey: String, scoreKey: String ) -> some View {
            
            let names = getTeamNames(from: teamKey)
            let score = EcheveriaGame.getNodeData(from: scoreKey, in: gameData)
            
            if names.count != 0 {
                
                VStack(alignment: .leading) {
                    UniversalText(title, size: Constants.UIHeaderTextSize, true)
                        .padding(.bottom, 5)
                    
                    HStack {
                        UniversalText("Score", size: Constants.UISubHeaderTextSize, true)
                        Spacer()
                        UniversalText(score, size: Constants.UIDefaultTextSize)
                            .padding(.trailing)
                    }
                    .padding(.bottom, 5)
                    
                    UniversalText("Members", size: Constants.UISubHeaderTextSize, true)
                    ForEach( players, id: \.self ) { profileID in
                        ProfilePreviewView(profileID: profileID)
                    }
                }
                .padding()
                .universalTextStyle()
                .rectangularBackgorund()
                
            }
        }
        
        var body: some View {
            
            VStack {
                
                teamViewBuilder("Team 1", teamKey: LawnGame.DataKey.team1.rawValue, scoreKey: LawnGame.DataKey.team1Score.rawValue)
                teamViewBuilder("Team 2", teamKey: LawnGame.DataKey.team2.rawValue, scoreKey: LawnGame.DataKey.team2Score.rawValue)
            }
            
        }
    }
}
