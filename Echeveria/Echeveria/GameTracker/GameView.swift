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

    var group: EcheveriaGroup {
        if let group = EcheveriaGroup.getGroupObject(from: game.groupID) {
            return group
        }else { return EcheveriaGroup(name: "", icon: "") }
            
    }
    
    var body: some View {
        AsyncLoader {
            await game.updatePermissions()
        } content: {
            VStack(alignment:.leading) {
                UniversalText("Game of \(game.type)", size: 20, true)
                HStack {
                    Text("with \(group.name)")
                    Image(systemName: group.icon)
                    Spacer()
                }
                Text("It was a \(game.experieince) time!")
                    .padding(.bottom, 5)
                
                UniversalText( game.winners.count == 1 ? "Winner" : "Winners", size: 20, true )
                ForEach( game.winners, id: \.self ) { playerID in
                    ProfileCard(profileID: playerID)
                }
                
                UniversalText( "Players", size: 20, true)
                ForEach( game.players, id: \.self ) { playerID in
                    ProfileCard(profileID: playerID)
                }
                
                UniversalText( "Game Information", size: 20, true)
                ForEach( game.players, id: \.self ) { playerID in
                    VStack {
                        Text(playerID)
    
                        if let data = gameData.where({ query in query.key == playerID }).first?.data {
                            Text( data )
                        }
                        
                    }
                }
                
                RoundedButton(label: "Delete Game Log", icon: "x.square") {
                    EcheveriaModel.deleteObject(game) { passedGame in
                        passedGame._id == game._id
                    }
                }

//                Spacer()
                
                
            }
        }
        .universalBackground()
    }
}

//TODO: if a game is deleted then the app crashes, which should not be the case!
struct GamePreviewView: View {
    
    @ObservedRealmObject var game: EcheveriaGame
    
    @State var showingGameView: Bool = false

    var group: EcheveriaGroup {
        if let group = EcheveriaGroup.getGroupObject(from: game.groupID) {
            return group
        }else { return EcheveriaGroup(name: "", icon: "") }
            
    }
    let geo: GeometryProxy
    
    var body: some View {
    
        VStack(alignment: .leading) {
            UniversalText(game.type, size: 30, true).textCase(.uppercase)
//            UniversalText("Winner: \(game.getWinners())", size: 20)
            Spacer()
            
            
            UniversalText("\(group.name)", size: 15)
            Text("\(game.date, style: .date )")
            
        }
        .aspectRatio(1, contentMode: .fit)
        .padding()
        .frame(width: geo.size.width / 2.5, height: geo.size.width / 2.5)
        .background(Rectangle()
            .cornerRadius(20)
            .universalForeground()
            .onTapGesture { showingGameView = true }
        )
        .sheet(isPresented: $showingGameView) {
            GameView(game: game)
            
        }
    }
    
}
