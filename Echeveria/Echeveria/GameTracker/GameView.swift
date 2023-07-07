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
    
    var gameID: String
    @ObservedResults(GameDataNode.self) var gameData

    @State var favorited: Bool = false
    @State var editing: Bool = false
    
    var body: some View {
        
        if let game = EcheveriaGame.getGameObject(from: gameID) {
            AsyncLoader {
                EcheveriaModel.shared.addActiveColor(with: game.getColor() )
                await game.updatePermissions(id: game._id.stringValue)
            } content: {
                
                let group = EcheveriaGroup.getGroupObject(from: game.groupID)
                let owner = EcheveriaModel.shared.profile.ownerID == game.ownerID
                
                VStack {
                    HStack {
                        UniversalText("\(game.type)", size: Constants.UITitleTextSize, true)
                            .padding(.bottom, 5)
                        
                        Spacer()
                        ProfileViews.DismissView { EcheveriaModel.shared.removeActiveColor() } action: {
                            if favorited { EcheveriaModel.shared.profile.favoriteGame(game) }
                            else { EcheveriaModel.shared.profile.unfavoriteGame(game) }
                            await game.closePermissions(id: game._id.stringValue)
                        }
                    }
                    
                    ScrollView(.vertical) {
                        VStack(alignment:.leading) {
                            
                            HStack {
                                UniversalText("Overview", size: Constants.UIHeaderTextSize, true)
                                    .padding(.bottom, 5)
                                
                                Spacer()
                                
                                ShortRoundedButton("Favorite", to: "", icon: "seal", to: "checkmark.seal") { favorited } action: { favorited.toggle() }
                                    .onAppear { favorited = EcheveriaModel.shared.profile.favoriteGames.contains { str in game._id.stringValue == str } }
                            }
                            
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
                            }.padding(.bottom, 5)
                            
                            UniversalText(game.comments, size: Constants.UIDefaultTextSize)
                                .padding(.bottom)
                            
                            
                            VStack(alignment: .leading) {
                                
                                UniversalText( game.winners.count == 1 ? "Winner" : "Winners", size: Constants.UISubHeaderTextSize, true )
                                ForEach( game.winners, id: \.self ) { memberID in
                                    ProfilePreviewView(profileID: memberID).padding(.bottom, 5)
                                }
                                
                                UniversalText( "Players", size: Constants.UISubHeaderTextSize, true)
                                ForEach( game.players, id: \.self ) { memberID in
                                    ProfilePreviewView(profileID: memberID).padding(.bottom, 5)
                                }
                            }
                            
                            UniversalText( "Game Information", size: Constants.UISubHeaderTextSize, true )
                                .padding(.bottom, 5)
                            
                            VStack {
                                switch game.type {
                                case EcheveriaGame.GameType.smash.rawValue:     Smash.GameDisplay(players: Array(game.players), gameData: Array( game.gameData ))
                                case EcheveriaGame.GameType.magic.rawValue:     Magic.GameDisplay(players: Array(game.players), gameData: Array( game.gameData ))
                                case EcheveriaGame.GameType.spikeBall.rawValue: LawnGame.GameDisplay(players: Array(game.players), gameData: Array( game.gameData ))
                                case EcheveriaGame.GameType.bags.rawValue:      LawnGame.GameDisplay(players: Array(game.players), gameData: Array( game.gameData ))
                                default: EmptyView()
                                }
                            }
                            
                            Spacer()
                            
                            if game.players.contains(where: { str in str == EcheveriaModel.shared.profile.ownerID }) {
                                RoundedButton(label: "Edit", icon: "pencil.line") { editing = true }
                            }
                            
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
            .padding(.top, 40)
            .universalColoredBackground( game.getColor() )
            .sheet(isPresented: $editing) {
                if let gameCopy = EcheveriaGame.getGameObject(from: gameID) {
                    GameLoggerView(editing: true,
                                   gameID: gameID,
                                   gameType: gameCopy.getType(),
                                   group: gameCopy.groupID.stringValue,
                                   selectedPlayers: Array(gameCopy.players),
                                   selectedWinners: Array(gameCopy.winners),
                                   gameExperieince: gameCopy.getExperience(),
                                   gameComments: gameCopy.comments,
                                   gameValues: gameCopy.getGameDataAsDictionary())
                }
            }
        }
    }
}

struct RecentGamesView: View {
    
    let games: [EcheveriaGame]
    let geo: GeometryProxy
    
    var body: some View {
        
        let count = games.count - 1
        
        if count > 0 {
            let recentGames = games.sorted { game1, game2 in game1.date < game2.date }[ max( count - 5, 0 )...count ]
            
            VStack(alignment: .leading) {
                UniversalText("Recent Games", size: Constants.UIHeaderTextSize, true)
                if recentGames.count == 0 {
                    
                    LargeFormRoundedButton(label: "Log your First Game", icon: "plus", action: {})
                    
                } else {
                    let games = EcheveriaGame.reduceIntoStrings(from: Array(recentGames))
                    GameScrollerView(title: "", filter: .none, filterable: false, geo: geo, games: games.reversed() )
                        .padding(.bottom)
                }
            }
        }
    }
}
