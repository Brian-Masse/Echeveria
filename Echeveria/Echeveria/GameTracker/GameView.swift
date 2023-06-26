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
            await game.updatePermissions()
        } content: {
            ScrollView(.vertical) {
                VStack(alignment:.leading) {
                    UniversalText("\(game.type)", size: Constants.UITitleTextSize, true)
                        .padding(.bottom, 5)
                    
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
                            ReducedProfilePreviewView(profileID: memberID).padding(.bottom, 5)
                        }.rectangularBackgorund()
                        
                        UniversalText( "Players", size: Constants.UISubHeaderTextSize, true)
                        ForEach( game.players, id: \.self ) { memberID in
                            ReducedProfilePreviewView(profileID: memberID).padding(.bottom, 5)
                        }.rectangularBackgorund()
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
                .padding()
            }
        }
        .universalColoredBackground(Colors.forestGreen)
    }
}

