//
//  ProfileGameView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/23/23.
//

import Foundation
import RealmSwift
import SwiftUI
import Charts

//MARK: ProfileGameView
struct ProfileGameView: View {
    
    @ObservedObject var profile: EcheveriaProfile
    var allGames: Results<EcheveriaGame>
    
    let geo: GeometryProxy
    var mainUser: Bool { profile.ownerID == EcheveriaModel.shared.profile.ownerID }
    
    var body: some View {
        
        let games = profile.getAllowedGames(from: allGames)
        
        VStack {
            ProfilePageTitle(profile: profile, text: "Game Logs", size: Constants.UISubHeaderTextSize)
            
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    
                    UniversalText("Overview", size: Constants.UIHeaderTextSize, true)
                    
                    TimeByTypeChart(title: "Wins", games: games) { fgames in
                        ProfileWinHistoryChart(profile: profile, games: games, filteredGames: fgames)
                        let winCountData = profile.getWins(in: .now, games: games)

                        HStack {
                            StaticGameChart(title: "Wins by Game", data: winCountData, primaryColor: profile.getColor(),
                                            XAxisTitle: "GameType", XAxis: { dataPoint in dataPoint.game.rawValue },
                                            YAxisTitle: "WinCount", YAxis: { dataPoint in dataPoint.winCount })

                            StaticGameChart(title: "Win Rate by Game", data: winCountData, primaryColor: profile.getColor(),
                                            XAxisTitle: "GameType", XAxis: { dataPoint in dataPoint.game.rawValue },
                                            YAxisTitle: "WinRate", YAxis: { dataPoint in Float(dataPoint.winCount) / Float(max(1, dataPoint.totalCount)) })
                        }
                    }
                    
                    RecentGamesView(games: games, geo: geo)
                    
                    UniversalText("All Data", size: Constants.UIHeaderTextSize, true)
                    TimeByTypeChart(title: "Win Streaks", games: games) { fgames in
                        ProfileWinStreakHistoryChart(profile: profile, games: games, filteredGames: fgames)
//                        GameChart(profile: profile, games: games )
                    }.padding(.bottom)

//                    ZStack(alignment: .topLeading) {
                    GameScrollerView(title: "All Games", filter: .gameType, filterable: true, geo: geo, games: EcheveriaGame.reduceIntoStrings(from: games))
//                        UniversalText("All Games", size: Constants.UIHeaderTextSize, true)
//                    }
                .padding(.bottom, 80)
                }
                Spacer()
            }
        }
    }
    
//    MARK: Charts
    
    struct GameChart: View {
        enum AxisDataType: String {
            case winning = "by Winner"
            case experience = "by Experieince"
            case type = "by Type"
            case group = "by Group"
        }
        
        private func returnProperty(from type: AxisDataType, with game: EcheveriaGame) -> String {
            switch type {
            case .winning: return game.getWinners()
            case .experience: return game.experieince
            case .type: return game.type
            case .group: return EcheveriaGroup.getGroupName(game.groupID)
            }
        }
        
        private func formatTitle() -> String {
            var string = yAxisDataType.rawValue
            
            let start = string.startIndex
            let range = Range(uncheckedBounds: (start, string.index(start, offsetBy: 2)) )
        
            string.removeSubrange(range)
            return "\(string) over time"
        }
        
        @ObservedObject var profile: EcheveriaProfile
    
        @State var yAxisDataType: AxisDataType = .winning
        @State var typeAxisDataType: AxisDataType = .type
        
        let games: [EcheveriaGame]
        
        var body: some View {
            
            ZStack(alignment: .top) {
                Chart {
                    ForEach(games, id: \._id.stringValue) { game in
                        
                        PointMark (
                            x: .value("Date", game.date) ,
                            y: .value("Won?", returnProperty(from: yAxisDataType, with: game) )
                        )
                        .foregroundStyle(by: .value("Type", returnProperty(from: typeAxisDataType, with: game)) )
                    }
                }
                .chartXScale(domain: [ profile.createdDate, Date.now.advanced(by: 3600) ])
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)){ value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel( date.formatted(date: .numeric, time: .omitted)  )
                        }
                        
                        AxisGridLine()
                        AxisTick()
                    }
                }
                .universalChart()
                
                HStack {
                    UniversalText( formatTitle(), size: Constants.UISubHeaderTextSize, true)
                    Spacer()
                    Menu {
                        EditMenu(editingAxis: $yAxisDataType, title: "Y Axis")
                        EditMenu(editingAxis: $typeAxisDataType, title: "Series")
                    } label: { FilterButton() }
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
        }
        
        struct EditMenu: View {
            @Binding var editingAxis: AxisDataType
            let title: String
            
            var body: some View {
                Menu {
                    Button("by Winner") { editingAxis = .winning }
                    Button("by Experieince") { editingAxis = .experience }
                    Button("by Type") { editingAxis = .type }
                    Button("by Group") { editingAxis = .group }
                } label: { Text(title) }
            }
        }
    }
}
