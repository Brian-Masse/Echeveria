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
    
    @ObservedRealmObject var game: EcheveriaGame
    
    @State var showingGameView: Bool = false

    var group: EcheveriaGroup? { EcheveriaGroup.getGroupObject(from: game.groupID) }
            
    let geo: GeometryProxy
    
    var body: some View {
    
        VStack(alignment: .leading) {
            UniversalText(game.type, size: Constants.UIHeaderTextSize - 5, true).textCase(.uppercase)
            
            if group != nil { UniversalText("\(group!.name)", size: Constants.UIDefaultTextSize, lighter: true, true) }
            UniversalText(game.date.formatted(date: .numeric, time: .omitted), size: Constants.UIDefaultTextSize, lighter: true )
            
        }
        .padding()
        .frame(width: geo.size.width / 2.5, height: geo.size.width / 5)
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
