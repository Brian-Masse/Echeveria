//
//  GameScrollerView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/19/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct GameScrollerView: View {
    
    enum Filter: String, CaseIterable, Identifiable {
        case gameType = "by Game"
        case groupType = "by Group"
        case winnerType = "by Winner"
        
        var id: String { self.rawValue }
    }
    
    @State var filter: Filter = .gameType
    
    let geo: GeometryProxy
    let games: Results<EcheveriaGame>
    
    var body: some View {
        VStack {
            HStack {
                UniversalText("Games", size: 20, true)
                Spacer()
                Menu {
                    Button("by Game") { filter = .gameType }
                    Button("by Group") { filter = .groupType }
                    Button("by Winner") { filter = .winnerType }
                } label: {
                    RoundedButton(label: "Filter: \(filter.rawValue)", icon: "line.3.horizontal.decrease.circle") {}
                        .universalTextStyle()
                }
            }
            
            if filter == .gameType {
                ForEach( EcheveriaGame.GameType.allCases, id: \.self ) { type in
                    GameListView(games: games, title: type.rawValue, geo: geo) { game in
                        game.type == type.rawValue
                    }
                }
            } else if filter == .groupType {
                ForEach( EcheveriaModel.shared.profile.groups, id: \.self ) { group in
                    GameListView(games: games, title: group.name, geo: geo) { game in
                        game.groupID == group._id
                    }
                }
            } else if filter == .winnerType {
                let winners = EcheveriaGame.getListOfWinners()
                
                ForEach( winners, id: \.self ) { winner in
                    let profile = EcheveriaProfile.getProfileObject(from: winner)
                    GameListView(games: games, title: profile!.firstName, geo: geo) { game in
                        game.winners.contains { winnerID in
                            winnerID == winner
                        }
                    }
                }
            }
        }
    }
    
    struct GameListView: View {
        
        let games: Results<EcheveriaGame>
        let title: String
        
        let geo: GeometryProxy
        let query: (EcheveriaGame) -> Bool
        
        var body: some View {
            let filtered = Array(games.filter { game in query(game) })
            if filtered.count != 0 {
                HStack {
                    UniversalText(title, size: 20)
                    Spacer()
                }
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach( filtered, id: \.self ) { game in
                            GameTrackerCardPreviewView(game: game, geo: geo)
                        }
                    }
                }
            }
        }
    }
}
