//
//  IndividualProfileCharts.swift
//  Echeveria
//
//  Created by Brian Masse on 6/29/23.
//

import Foundation
import SwiftUI
import Charts

//MARK: WinHistoryChart
struct ProfileWinHistoryChart: View {
    private func makeNodes() -> [DataNode] {
        let sorted = EcheveriaGame.sort(games)
        return sorted.flatMap { game in
            let count = sorted.filter { g in g.date <= game.date && g.winners.contains{ str in str == ownerID } && !filteredGames.contains(where: { str in str.strip() == g.type.strip() })}.count
            return [ DataNode(id: ownerID, wins: count, date: game.date, type: "") ]
        }
    }
    
    var ownerID: String { profile.ownerID }
    
    let profile: EcheveriaProfile
    let games: [EcheveriaGame]
    
    @Binding var filteredGames: [String]
    
    var body: some View {
        
        VStack {
            let nodes = makeNodes()
            let sortedWins = nodes.sorted { node1, node2 in node1.wins < node2.wins }
            
            Chart {
                ForEach(nodes.indices) { i in
                    LineMark(x: .value("X", nodes[i].date),
                             y: .value("Y", nodes[i].wins))
                    .foregroundStyle(profile.getColor())
                
                    AreaMark(x: .value("X", nodes[i].date),
                             y: .value("Y", nodes[i].wins))
                    .foregroundStyle( LinearGradient(colors: [profile.getColor().opacity(0.5), .clear], startPoint: .top, endPoint: .bottom) )
                }
            }
            .opaqueRectangularBackground()
            .frame(height: 150)
            
            HStack {
                UniversalText("Total Wins", size: Constants.UISubHeaderTextSize, true)
                Spacer()
                UniversalText("\(sortedWins.last?.wins ?? 0)", size: Constants.UISubHeaderTextSize, true)
            }
            .padding(.vertical, 7)
        }
    }
}


struct ProfileWinStreakHistoryChart: View {
    private func makeWinStreakData() -> [DataNode] {
        let sorted = EcheveriaGame.sort(games)
        return sorted.compactMap { game in
            let filtered = sorted.filter { g in g.date <= game.date }
            let last = filtered.lastIndex { g in !g.winners.contains { str in str == ownerID } && g.players.contains { str in str == ownerID } } ?? filtered.count - 1
            let number = filtered.count - last - 1
            return DataNode(id: ownerID, wins: number, date: game.date, type: "")
        }
    }
    
    var ownerID: String { profile.ownerID }

    let profile: EcheveriaProfile
    let games: [EcheveriaGame]

    @Binding var filteredGames: [String]

    var body: some View {

        VStack {
            let data = makeWinStreakData()
            let sorted = data.sorted { node1, node2 in node1.wins < node2.wins }

            Chart {
                ForEach(data.indices) { i in
                    LineMark(x: .value("X", data[i].date),
                             y: .value("Y", data[i].wins))
                    .foregroundStyle( profile.getColor() )
                    
                    AreaMark(x: .value("X", data[i].date),
                             y: .value("Y", data[i].wins))
                    .foregroundStyle( LinearGradient(colors: [profile.getColor().opacity(0.5), .clear], startPoint: .top, endPoint: .bottom) )
                }
            }
            .opaqueRectangularBackground()
            .frame(height: 150)

            HStack(alignment: .top) {
                UniversalText("Longest Winstreak", size: Constants.UISubHeaderTextSize, true)
                Spacer()

                VStack(alignment: .trailing) {
                    if let longest = sorted.last {
                        UniversalText("\(longest.wins) games", size: Constants.UISubHeaderTextSize, true)

                        let startDate = sorted.filter { node in node.date < longest.date && node.id == longest.id }.last { node in node.wins == 0 }?.date ?? .now

                        UniversalText( "\(startDate.formatted(date: .abbreviated, time: .omitted)) - \(longest.date.formatted(date: .abbreviated, time: .omitted))", size: Constants.UIDefaultTextSize, lighter: true )
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
    }
}

