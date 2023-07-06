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
        case none = "None"
        
        var id: String { self.rawValue }
    }
    
    @State var filter: Filter
    
    let filterable: Bool 
    let geo: GeometryProxy
    let games: [String]
    
    var body: some View {
        VStack {
            if filterable {
                HStack {
                    Spacer()
                    Menu {
                        Text("Filter")
                        Button("by Game") { filter = .gameType }
                        Button("by Group") { filter = .groupType }
                        Button("by Winner") { filter = .winnerType }
                    } label: { FilterButton() }
                }
            }
            
            if filter == GameScrollerView.Filter.none {
                GameListView(games: games, title: "", geo: geo) { game in true }
            }
            
            if filter == .gameType {
                ForEach( EcheveriaGame.GameType.allCases, id: \.self ) { type in
                    GameListView(games: games, title: type.rawValue, geo: geo) { gameID in
                        if let game = EcheveriaGame.getGameObject(from: gameID) { return game.type.strip() == type.rawValue.strip() } ; return false
                    }
                }
            } else if filter == .groupType {
                ForEach( EcheveriaModel.shared.profile.groups, id: \.self ) { group in
                    GameListView(games: games, title: group.name, geo: geo) { gameID in
                        if let game = EcheveriaGame.getGameObject(from: gameID) { return game.groupID == group._id }; return false
                    }
                }
            } else if filter == .winnerType {
                let winners = EcheveriaGame.getListOfWinners()
                
                ForEach( winners, id: \.self ) { winner in
                    let profile = EcheveriaProfile.getProfileObject(from: winner)
                    GameListView(games: games, title: profile!.firstName, geo: geo) { gameID in
                        if let game = EcheveriaGame.getGameObject(from: gameID) {
                            return game.winners.contains { winnerID in
                                winnerID == winner
                            }
                        }
                        return false
                    }
                }
            }
        }
    }
    
    struct GameListView: View {
        
        let games: [String]
        let title: String
        
        let geo: GeometryProxy
        let query: (String) -> Bool
        
        var body: some View {
            let filtered = Array(games.filter { game in query(game) })
            if filtered.count != 0 {
                HStack {
                    UniversalText(title, size: 20)
                    Spacer()
                }
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach( filtered, id: \.self ) { gameID in
                            if let game = EcheveriaGame.getGameObject(from: gameID) {
                                if let group = EcheveriaGroup.getGroupObject(from: game.groupID) {
                                    GamePreviewView(gameID: gameID, group: group, geo: geo)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
