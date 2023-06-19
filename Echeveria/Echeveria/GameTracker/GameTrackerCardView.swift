//
//  GameTrackerCardView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/19/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct GameTrackerCardPreviewView: View {
    
    @ObservedRealmObject var game: EcheveriaGame

    var group: EcheveriaGroup { EcheveriaGroup.getGroupObject(from: game.groupID)! }
    
    var body: some View {
    
        VStack(alignment:.leading) {
            Text( "Game of \(game.type)" ).font(UIUniversals.font(20))
            HStack {
                Text("with \(group.name)")
                Image(systemName: group.icon)
                Spacer()
            }
            Text("It was a \(game.experieince) time!")
                .padding(.bottom, 5)
            
            Text( game.winners.count == 1 ? "Winner" : "Winners" ).font(UIUniversals.font(20))
            ForEach( game.winners, id: \.self ) { playerID in
                ProfileCard(profileID: playerID)
            }
            
            Text( "Players" ).font(UIUniversals.font(20))
            ForEach( game.players, id: \.self ) { playerID in
                ProfileCard(profileID: playerID)
            }
            
            Text(game.comments)
        }
        .padding()
        .background(Rectangle()
            .cornerRadius(20)
            .universalForeground()
        )
    }
    
}
