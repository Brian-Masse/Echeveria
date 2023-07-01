//
//  GameTrackerCardView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/19/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct GameView: View {
    
    @ObservedRealmObject var game: EcheveriaGame
    @ObservedResults(GameDataNode.self) var gameData

    var group: EcheveriaGroup? { EcheveriaGroup.getGroupObject(from: game.groupID) }
    var owner: Bool { EcheveriaModel.shared.profile.ownerID == game.ownerID }
    
    var body: some View {
        AsyncLoader {
            EcheveriaModel.shared.addActiveColor(with: EcheveriaGame.getGameColor(game.type) )
            await game.updatePermissions(id: game._id.stringValue)
        } content: {
            
            VStack {
                HStack {
                    UniversalText("\(game.type)", size: Constants.UITitleTextSize, true)
                        .padding(.bottom, 5)
                    
                    Spacer()
                    ProfileViews.DismissView { EcheveriaModel.shared.removeActiveColor() } action: {
                        await game.closePermissions(id: game._id.stringValue)
                    }
                }
                
                ScrollView(.vertical) {
                    VStack(alignment:.leading) {
                        
                        UniversalText("Overview", size: Constants.UIHeaderTextSize, true)
                            .padding(.bottom, 5)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                UniversalText("Date", size: Constants.UISubHeaderTextSize, lighter: true, true)
                                UniversalText("Group", size: Constants.UISubHeaderTextSize, lighter: true, true)
                                UniversalText("Experieince", size: Constants.UISubHeaderTextSize, lighter: true, true)
                            }
                            
                            Spacer()
                            VStack(alignment: .trailing) {
                                UniversalText(game.date.formatted(date: .numeric, time: .omitted), size: Constants.UIDefaultTextSize)
                                HStack { if group != nil {
                                    UniversalText(group!.name, size: Constants.UIDefaultTextSize, lighter: true)
                                    Image(systemName: group!.icon)
                                } }
                                UniversalText(game.experieince, size: Constants.UIDefaultTextSize)
                            }
                        }
                        .padding(.bottom)
                        
                        VStack(alignment: .leading) {
                            UniversalText("Game Information", size: Constants.UIHeaderTextSize, true)
                                .padding(.bottom, 5)
                            
                            UniversalText( game.winners.count == 1 ? "Winner" : "Winners", size: Constants.UISubHeaderTextSize, true )
                            ForEach( game.winners, id: \.self ) { memberID in
                                ProfilePreviewView(profileID: memberID).padding(.bottom, 5)
                            }
                            
                            UniversalText( "Players", size: Constants.UISubHeaderTextSize, true)
                            ForEach( game.players, id: \.self ) { memberID in
                                ProfilePreviewView(profileID: memberID).padding(.bottom, 5)
                            }
                        }
                        
                        //                UniversalText( "Game Information", size: 20, true)
                        //                ForEach( game.players, id: \.self ) { playerID in
                        //                    VStack {
                        //                        Text(playerID)
                        //
                        //                        if let data = gameData.where({ query in query.key == playerID }).first?.data {
                        //                            Text( data )
                        //                        }
                        //
                        //                    }
                        //                }
                        
                        
                        Spacer()
                        if owner {
                            RoundedButton(label: "Delete Game Log", icon: "x.square") {
                                EcheveriaModel.deleteObject(game) { passedGame in
                                    passedGame._id == game._id
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .padding(.bottom, 30)
        }
        .universalColoredBackground(EcheveriaGame.getGameColor(game.type) )
    }
}

struct RecentGamesView: View {
    
    let games: [EcheveriaGame]
    let geo: GeometryProxy
    
    var body: some View {
        
        let recentGames = games.returnFirst(5)
    
        VStack(alignment: .leading) {
            UniversalText("Recent Games", size: Constants.UIHeaderTextSize, true)
            if recentGames.count == 0 {
                
                LargeFormRoundedButton(label: "Log your First Game", icon: "plus", action: {})
                
            } else {
                GameScrollerView(filter: .none, filterable: false, geo: geo, games: recentGames )
                    .padding(.bottom)
            }
        }
    }
}
