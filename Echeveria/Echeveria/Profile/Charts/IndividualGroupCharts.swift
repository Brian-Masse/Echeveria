//
//  IndividualCharts.swift
//  Echeveria
//
//  Created by Brian Masse on 6/29/23.
//

import Foundation
import SwiftUI
import Charts

//MARK: WinHistoryChart
struct WinHistoryChart: View {
    private func makeNodes() -> [DataNode] {
        let sorted = EcheveriaGame.sort(games)
        return group.members.filter { id in !filteredMembers.contains(where: { str in str == id }) }.flatMap { memberID in
            return sorted.flatMap { game in
                let count = sorted.filter { g in g.date <= game.date && g.winners.contains{ str in str == memberID} && !filteredGames.contains(where: { str in str.strip() == g.type.strip() })}.count
                return [ DataNode(id: memberID, wins: count, date: game.date, type: "") ]
            }
        }
    }
    
    private func getWins() -> [DataNode] {
        group.members.filter { id in !filteredMembers.contains { str in str == id } }.compactMap { profileID in
            let count = games.filter { g in !filteredGames.contains { type in type.strip() == g.type.strip() } && g.winners.contains { str in str == profileID}}.count
            return DataNode(id: profileID, wins: count, date: .now, type: "")
        }
    }
    
    let group: EcheveriaGroup
    let games: [EcheveriaGame]
    
    @Binding var filteredMembers: [String]
    @Binding var filteredGames: [String]
    
    var body: some View {
        
        VStack {
            let nodes = makeNodes()
            let totalWins = getWins().sorted { node1, node2 in node1.wins < node2.wins }
            
            Chart {
                ForEach(nodes.indices) { i in
                    LineMark(x: .value("X", nodes[i].date),
                             y: .value("Y", nodes[i].wins))
                    .foregroundStyle(by: .value("g", nodes[i].name))
                    
                    if group.members.count - filteredMembers.count == 1 {
                        AreaMark(x: .value("X", nodes[i].date),
                                 y: .value("Y", nodes[i].wins))
                        .foregroundStyle(by: .value("g", nodes[i].name)).opacity(0.5)
                    }
                }
            }
            .coloredChart( group.members.map { id in EcheveriaProfile.getName(from: id) } , color: group.getColor() )
            .opaqueRectangularBackground()
            .frame(height: 200)
            
            HStack {
                VStack(alignment: .leading) {
                    UniversalText("Best Player", size: Constants.UISubHeaderTextSize, true)
                    UniversalText("Worst Player", size: Constants.UISubHeaderTextSize, true)
                }
                Spacer()
                
                VStack(alignment: .trailing) {
                    UniversalText("\( totalWins.last?.name ?? "?" ) (\(totalWins.last?.wins ?? 0) wins)", size: Constants.UISubHeaderTextSize, true)
                    UniversalText("\( totalWins.first?.name ?? "?" ) (\(totalWins.first?.wins ?? 0) wins)", size: Constants.UISubHeaderTextSize, true)
                }
            }
            .padding(.vertical, 7)
        }
    }
}

//MARK: WinRateChart
struct WinRateChart: View {
    
    private func getData() -> [DataNode] {
        return group.members.filter { str in !filteredMembers.contains(where: { id in id == str } ) }.compactMap { profileID in
            let filtered = games.filter { game in
                !filteredGames.contains { type in type.strip() == game.type.strip() } && game.players.contains { str in str == profileID }
            }
            let wins = filtered.filter { game in game.winners.contains { str in str == profileID } }
            let rate = Double( wins.count ) / max(Double( filtered.count ), 1)
            return DataNode(id: profileID, wins: Int(rate * 100 ), date: .now, type: "")
        }
    }
    
    let group: EcheveriaGroup
    let games: [EcheveriaGame]
    
    @Binding var filteredMembers: [String]
    @Binding var filteredGames: [String]
    
    var body: some View {
        
        VStack(alignment: .leading) {
            let data = getData()
            let sorted = data.sorted { node1, node2 in node1.wins < node2.wins }
            
            UniversalText("Win Rate", size: Constants.UISubHeaderTextSize, true)
                .padding(.top)
            
            Chart {
                ForEach(data.indices) { i in
                    BarMark(x: .value("X", data[i].name),
                            y: .value("Y", data[i].wins))
                    .foregroundStyle( group.getColor() )
                }
            }
            .frame(height: 100)
            
            HStack {
                UniversalText("Best Player", size: Constants.UISubHeaderTextSize, true)
                Spacer()
                UniversalText("\(sorted.last?.name ?? "?") (\(sorted.last?.wins ?? 0)% win rate)", size: Constants.UIDefaultTextSize)
            }
            
            HStack {
                UniversalText("Worst Player", size: Constants.UISubHeaderTextSize, true)
                Spacer()
                UniversalText("\(sorted.first?.name ?? "?") (\(sorted.first?.wins ?? 0)% win rate)", size: Constants.UIDefaultTextSize)
            }
        }
    }
}


//MARK: TotalWinChart
struct TotalWinHistoryChart: View {
    private func makeTotalWinData() -> [DataNode] {
        return group.members.filter { id in !filteredMembers.contains(where: { str in str == id }) }.flatMap { memberID in
            return EcheveriaGame.GameType.allCases.filter { type in !filteredGames.contains { str in str.strip() == type.rawValue.strip() } }.compactMap { type in
                let count = games.reduce(0) { partialResult, game in
                    (game.type.strip() == type.rawValue.strip() && game.winners.contains {str in str == memberID}) ? partialResult + 1 : partialResult }
                return DataNode(id: memberID, wins: count, date: .now, type: type.rawValue )
            }
        }
    }
    
    let group: EcheveriaGroup
    let games: [EcheveriaGame]
    
    @Binding var filteredMembers: [String]
    @Binding var filteredGames: [String]
    
    var body: some View {
        VStack {
            let data = makeTotalWinData()
            
            Chart {
                ForEach(data.indices) { i in
                    BarMark(x: .value("X", data[i].name),
                            y: .value("Y", data[i].wins))
                    .foregroundStyle(by: .value("series", data[i].type ))
                    
                }
            }
            .coloredChart( EcheveriaGame.GameType.allCases.map { type in type.rawValue}, color: group.getColor() )
            .frame(height: 100)
        }
    }
}


struct WinStreakHistoryChart: View {
    private func makeWinStreakData() -> [DataNode] {
        let sorted = EcheveriaGame.sort(games)
        return group.members.filter { id in !filteredMembers.contains(where: { str in str == id }) }.flatMap { memberID in
            return sorted.compactMap { game in
                let filtered = sorted.filter { g in g.date <= game.date && g.players.contains { str in str == memberID } }
                let last = filtered.lastIndex { g in !g.winners.contains { str in str == memberID } && g.players.contains { str in str == memberID } } ?? filtered.count - 1
                return DataNode(id: memberID, wins: filtered.count - last - 1, date: game.date, type: "")
            }
        }
    }
    
    let group: EcheveriaGroup
    let games: [EcheveriaGame]
    
    @Binding var filteredMembers: [String]
    @Binding var filteredGames: [String]
    
    var body: some View {
        
        VStack {
            let data = makeWinStreakData()
            let sorted = data.sorted { node1, node2 in node1.wins < node2.wins }
            
            Chart {
                ForEach(data.indices) { i in
                    LineMark(x: .value("X", data[i].date),
                             y: .value("Y", data[i].wins))
                    .foregroundStyle(by: .value("series", data[i].name ))
                }
            }
            
            .opaqueRectangularBackground()
            .coloredChart( group.members.map { id in EcheveriaProfile.getName(from: id) } , color: group.getColor() )
            .frame(height: 200)
            
            Chart {
                ForEach( group.members ) { memberID in
                    BarMark(x: .value("X", EcheveriaProfile.getName(from: memberID)),
                            y: .value("Y", data.filter{ node in node.id == memberID }.sorted{ node1, node2 in node1.wins > node2.wins }.first?.wins ?? 0 ))
                    .foregroundStyle(group.getColor())
                }
            }
            .frame(height: 100)
            
            HStack {
                UniversalText("Longest Winstreak", size: Constants.UISubHeaderTextSize, true)
                Spacer()
                
                VStack(alignment: .trailing) {
                    if let longest = sorted.last {
                        UniversalText("\( longest.name) (\(longest.wins) games)", size: Constants.UISubHeaderTextSize, true)
                        
                        let startDate = sorted.filter { node in node.date < longest.date && node.id == longest.id }.last { node in node.wins == 0 }?.date ?? .now
                        
                        UniversalText( "\(startDate.formatted(date: .abbreviated, time: .omitted)) - \(longest.date.formatted(date: .abbreviated, time: .omitted))", size: Constants.UIDefaultTextSize, lighter: true )
                    }
                }
            }
        }
    }
}


//MARK: GameCountHistoryGraph
struct GameCountHistoryGraph: View {
    
    let group: EcheveriaGroup
    let games: [EcheveriaGame]
    
    struct GameCountDataNode {
        let count: Int
        let totalCount: Int
        let date: Date
    }
    
    @State var filteredGames: [String] = []
    
    private func getData() -> [GameCountDataNode] {
        var list: [GameCountDataNode] = []
        var date: Date = group.createdDate
        
        let filtered = games.filter { game in !filteredGames.contains { str in str.strip() == game.type.strip() } }
        
        while date < .now + Constants.DayTime {
            let count = filtered.filter { game in Calendar.current.isDate(game.date, equalTo: date, toGranularity: .day) }.count
            let totalCount = filtered.filter { game in game.date <= date }.count
            list.append( GameCountDataNode(count: count, totalCount: totalCount, date: date ) )
            date += Constants.DayTime
        }
        return list
    }
    
    private func getPlayerCountData() -> [DataNode] {
        group.members.reduce([]) { partialResult, profileID in
            partialResult + EcheveriaGame.GameType.allCases.filter { type in !filteredGames.contains(where: { str in str.strip() == type.rawValue.strip() }) }.compactMap { type in
                let count = games.filter { game in game.players.contains{ str in str == profileID } && game.type.strip() == type.rawValue.strip()  }.count
                return DataNode(id: profileID, wins: count, date: .now, type: type.rawValue)
            }
        }
    }
    
    private func getTotalPlayerCountData() -> [DataNode] {
        group.members.compactMap { profileID in
            let count = games.filter { game in game.players.contains { str in str == profileID } && !filteredGames.contains { type in type.strip() == game.type.strip() }  }.count
            return DataNode(id: profileID, wins: count, date: .now, type: "")
        }
    }
    
    var body: some View {
        
        let data = getData()
        let totalGames: Float = Float(data.last!.totalCount)
        
        VStack(alignment: .leading) {
            
            HStack {
                UniversalText("Games Played", size: Constants.UISubHeaderTextSize, true)
                Spacer()
                let menu = Menu {
                    ForEach( EcheveriaGame.GameType.allCases.indices, id: \.self ) { i in
                        Button { withAnimation { filteredGames.toggleValue( EcheveriaGame.GameType.allCases[i].rawValue ) }} label: {
                            let selected = !filteredGames.contains { str in str.strip() == EcheveriaGame.GameType.allCases[i].rawValue.strip() }
                            if selected { Image(systemName: "checkmark") }
                            Text(EcheveriaGame.GameType.allCases[i].rawValue)
                        }
                    }
                } label: { FilterButton() }
                if #available(iOS 16.4, *) {
                    menu.menuActionDismissBehavior(.disabled)
                }
            }
            
            VStack(alignment: .leading) {
                let playerData = getPlayerCountData()
                let total = getTotalPlayerCountData()
                
                UniversalText("By player", size: Constants.UISubHeaderTextSize, true)
                
                Chart {
                    ForEach(playerData.indices) { i in
                        BarMark(x: .value("X", playerData[i].name),
                                y: .value("Y", playerData[i].wins) )
                        .foregroundStyle( by: .value("series", playerData[i].type.strip() ))
                    }
                }
                .opaqueRectangularBackground()
                .coloredChart( EcheveriaGame.GameType.allCases.map { type in type.rawValue.strip() } , color: group.getColor() )
                
                Chart {
                    ForEach(total.indices) { i in
                        BarMark(x: .value("X", total[i].name),
                                y: .value("Y", (Float(total[i].wins) / totalGames * 100 ) ) )
                        .foregroundStyle( group.getColor() )
                    }
                }
                
                let sorted = total.sorted { node1, node2 in node1.wins < node2.wins }
                
                HStack {
                    UniversalText("Most Played", size: Constants.UISubHeaderTextSize, true)
                    Spacer()
                    UniversalText( "\(sorted.last?.name ?? "?") (\( sorted.last?.wins ?? 0 ), \( (Float(sorted.last?.wins ?? 0) / totalGames * 100).rounded(.down))%)", size: Constants.UIDefaultTextSize, true )
                }
                
                HStack {
                    UniversalText("Least Played", size: Constants.UISubHeaderTextSize, true)
                    Spacer()
                    UniversalText( "\(sorted.first?.name ?? "?") (\( sorted.first?.wins ?? 0 ), \( (Float(sorted.first?.wins ?? 0) / totalGames * 100).rounded(.down))%)", size: Constants.UIDefaultTextSize, true )
                }
            }
            .padding(.bottom)
            
            UniversalText("Over Time", size: Constants.UISubHeaderTextSize, true)
            
            Chart {
                ForEach(data.indices) { i in
                    BarMark(x: .value("X", data[i].date),
                            y: .value("Y", data[i].count) )
                    .foregroundStyle( group.getColor() )
                }
            }
            .opaqueRectangularBackground()
            .padding(.bottom)
            
            Chart {
                ForEach(data.indices) { i in
                    LineMark(x: .value("X", data[i].date),
                             y: .value("Y", data[i].totalCount))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 10]))
                    .foregroundStyle(group.getColor())
                    
                    AreaMark(x: .value("X", data[i].date),
                             y: .value("Y", data[i].totalCount))
                    .foregroundStyle(group.getColor()).opacity(0.3)
                }
            }
            
            HStack {
                UniversalText("Total Games", size: Constants.UISubHeaderTextSize, true)
                Spacer()
                UniversalText("\(totalGames)", size: Constants.UISubHeaderTextSize, true)
            } .padding(.bottom)
        }
        .padding()
        .universalTextStyle()
        .rectangularBackgorund()
    }
}
