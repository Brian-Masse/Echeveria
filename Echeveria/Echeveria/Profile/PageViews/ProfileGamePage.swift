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
    
    @State var logging: Bool = false
    
    let geo: GeometryProxy
    var mainUser: Bool { profile.ownerID == EcheveriaModel.shared.profile.ownerID }
    
    var body: some View {
        
        let games = profile.getAllowedGames(from: allGames)
        let recentGames = games.returnFirst(5)
        
        VStack {
            ProfilePageTitle(profile: profile, text: "Game Logs", size: Constants.UISubHeaderTextSize)
            
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    
                    UniversalText("Recent Games", size: Constants.UIHeaderTextSize, true)
                    GameScrollerView(filter: .none, filterable: false, geo: geo, games: recentGames )
                        .padding(.bottom)
                    
                    UniversalText("Stats", size: Constants.UIHeaderTextSize, true)
                    
                    let winStreakData = profile.getWinStreakData(games: Array(games), profileID: profile.ownerID)
                    let longestWinStreak = profile.getLongestWinStreak(from: Array(games), profileID: profile.ownerID)
                    
                    TimeBasedChart(initialDate: profile.createdDate, title: "Winstreak History", content: winStreakData, primaryColor: profile.getColor(),
                                   xAxisTitle: "Date", xAxisContent: { data in data.date },
                                   yAxisTitle: "Streak", yAxisContent: { data in data.streak },
                                   styleTitle: "GameType", styleContent: { data in data.type },
                                   styleCount: EcheveriaGame.GameType.allCases.count)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            UniversalText("Longest Winstreak", size: Constants.UISubHeaderTextSize, true)
                        }
                        Spacer()
                        UniversalText("\(longestWinStreak)", size: Constants.UISubHeaderTextSize )
                    }.padding(.bottom, 5)
                    
                    GameChart(profile: profile, games: games )

                    let winCountData = profile.getWins(in: .now, games: games)

                    HStack {
                        StaticGameChart(title: "Wins by Game", data: winCountData, primaryColor: profile.getColor(),
                                        XAxisTitle: "GameType", XAxis: { dataPoint in dataPoint.game.rawValue },
                                        YAxisTitle: "WinCount", YAxis: { dataPoint in dataPoint.winCount })

                        StaticGameChart(title: "Win Rate by Game", data: winCountData, primaryColor: profile.getColor(),
                                        XAxisTitle: "GameType", XAxis: { dataPoint in dataPoint.game.rawValue },
                                        YAxisTitle: "WinRate", YAxis: { dataPoint in Float(dataPoint.winCount) / Float(max(1, dataPoint.totalCount)) })

                    }
                    .padding(.bottom)

                    ZStack(alignment: .topLeading) {
                        GameScrollerView(filter: .gameType, filterable: true, geo: geo, games: games)
                        UniversalText("All Games", size: Constants.UIHeaderTextSize, true)
                    }.padding(.bottom, 80)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $logging) { GameLoggerView() }
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
