//
//  GamePreviewView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/26/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct GamePreviewView: View {
    
    let gameID: String
    
    @State var showingGameView: Bool = false

    let groupName: String
    let geo: GeometryProxy
    
    var body: some View {
    
        if let game = EcheveriaGame.getGameObject(from: gameID) {
            
            VStack(alignment: .leading) {
                HStack {
                    UniversalText(game.type, size: Constants.UIHeaderTextSize - 5, true).textCase(.uppercase)
                }
                
                UniversalText(groupName, size: Constants.UIDefaultTextSize, lighter: true, true)
                UniversalText(game.date.formatted(date: .numeric, time: .omitted), size: Constants.UIDefaultTextSize, lighter: true )
                
            }
            .padding()
            .frame(width: geo.size.width / 2.5, height: geo.size.width / 5)
            .background(Rectangle()
                .cornerRadius(20)
                .universalForeground()
                .onTapGesture { showingGameView = true }
            )
            .fullScreenCover(isPresented: $showingGameView) {
                GameView(gameID: gameID)       
            }
        }
    }
    
}
