//
//  GroupViewPages.swift
//  Echeveria
//
//  Created by Brian Masse on 6/24/23.
//

import Foundation
import SwiftUI
import RealmSwift
import Charts


//MARK: MainGroupViewPage
struct MainGroupViewPage: View {
    
    @ObservedRealmObject var group: EcheveriaGroup
    let games: Results<EcheveriaGame>
    let geo: GeometryProxy
    
    @State var editing: Bool = false
    
    var owner: Bool { group.owner == EcheveriaModel.shared.profile.ownerID }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                
                let recentGames = games.returnFirst(5)
                
                HStack {
                    ResizeableIcon(icon: group.icon, size: Constants.UIHeaderTextSize)
                    UniversalText(group.groupDescription, size: Constants.UIDefaultTextSize)
                }
                
                MembersView(group: group)
                    .padding(.bottom)
                
                UniversalText("Best Players", size: Constants.UIHeaderTextSize, true)
                ChartsGroupViewPage.OverviewChart(group: group, games: games)
                    .padding(.bottom)
                
                UniversalText("Recent Games", size: Constants.UIHeaderTextSize, true)
                GameScrollerView(filter: .none, filterable: false, geo: geo, games: recentGames )
                    .padding(.bottom)
                
                if owner {
                    RoundedButton(label: "Edit Group", icon: "pencil.line") { editing = true }
                    RoundedButton(label: "Delete Group", icon: "x.square") { group.deleteGroup() }
                }
            }
        }.sheet(isPresented: $editing) { EditingGroupView(group: group, name: group.name, icon: group.icon, description: group.groupDescription) }
    }
    
    struct MembersView: View {
        
        @ObservedRealmObject var group: EcheveriaGroup
        
        var body: some View {
            VStack {
                UniversalText("Members", size: Constants.UIHeaderTextSize, true)
                ForEach( group.members, id: \.self ) { memberID in
                    ReducedProfilePreviewView(profileID: memberID)
                        .padding(.bottom, 5)
                }
            }
            .rectangularBackgorund()
        }
    }
    
}


//MARK: ChartsGroupViewPage
struct ChartsGroupViewPage: View {
    
    enum GameCountFilter : String, CaseIterable, Identifiable {
        case byPlayer = "by Player"
        case byExperieince = "by Experience"
        
        var id: String { self.rawValue }
    }
    
    @ObservedRealmObject var group: EcheveriaGroup
    
    let games: Results<EcheveriaGame>
    let geo: GeometryProxy
    
    @State var gameCountFilter: GameCountFilter = .byPlayer
    
    var body: some View {
        
        let sorted = games.sorted { game1, game2 in game2.date > game1.date }
        
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                
                UniversalText("Stats", size: Constants.UIHeaderTextSize, true)
                OverviewChart(group: group, games: games)
                    .padding(.bottom)
                
                let gameCount = group.getGameCount(games: Array(sorted), filterByPlayer: gameCountFilter == .byPlayer)
                
                StaticGameChart(title: "Number of Games Played, Filtered", data: gameCount,
                                XAxisTitle: "GameType", XAxis: { history in history.type },
                                YAxisTitle: "Count", YAxis: { history in history.count },
                                styleTitle: "Style", Style: { history in history.styleData },
                                filter: Binding(get: { gameCountFilter }, set: { val in gameCountFilter = val! }) )
                
                let gameCountHistory = group.getGameCountHistory(games: Array(sorted))
                
                TimeBasedChart(initialDate: group.createdDate, title: "All Games", content: gameCountHistory,
                               xAxisTitle: "Date", xAxisContent: { history in history.date },
                               yAxisTitle: "Count", yAxisContent: { history in history.count },
                               styleTitle: "GameType", styleContent: { history in history.type })
                
                HStack {
                    UniversalText("Total Number of Games", size: Constants.UISubHeaderTextSize, true)
                    Spacer()
                    UniversalText("\(games.count)", size: Constants.UISubHeaderTextSize)
                    
                }
                .padding(.horizontal, 5)
                .padding(.bottom)
                
                ZStack(alignment: .topLeading) {
                    GameScrollerView(filter: .gameType, filterable: true, geo: geo, games: Array(games))
                    UniversalText("All Games", size: Constants.UIHeaderTextSize, true)
                }.padding(.bottom, 80)
            }
        }
    }
    
    struct OverviewChart: View {
        
        private func getSortedWinners(from winnerCountHistory: [EcheveriaGroup.WinnerHistoryNode]) -> [EcheveriaGroup.WinnerHistoryNode] {
            let memberCount = group.members.count
            let mostRecent = winnerCountHistory.returnLast(memberCount)
            return mostRecent.sorted { element1, element2 in
                element2.winCount > element1.winCount
            }
        }
        
        let colors: [Color] = [ .red, .orange, .init(red: 255 / 255, green: 129 / 255, blue: 120 / 255), .init(red: 107 / 255, green: 10 / 255, blue: 3 / 255), .purple, ]
        
        @State var dictionary: Dictionary<String, Color> = Dictionary()
        
        @ObservedRealmObject var group: EcheveriaGroup
        let games: Results<EcheveriaGame>
        
        var body: some View {
            
            let sorted = games.sorted { game1, game2 in game2.date > game1.date }
            
            let winnerCountHistory = group.getWinnerHistory(games: Array(sorted))
            let sortedRecentWinners = getSortedWinners(from: winnerCountHistory)
            
            let worstPlayer = sortedRecentWinners.first!
            let bestPlayer = sortedRecentWinners.last!
            
            
            TimeBasedChart(initialDate: group.createdDate, title: "Best Players", content: winnerCountHistory,
                           xAxisTitle: "Date", xAxisContent:        { history in history.date },
                           yAxisTitle: "WinCount", yAxisContent:    { history in history.winCount },
                           styleTitle: "Player", styleContent:      { history in history.player.firstName })
            .chartForegroundStyleScale { (value: String) in
                dictionary[value] ?? .red
            }
            .onAppear {
                
                var dic: Dictionary<String, Color> = Dictionary()
                for index in group.members.indices {
                    if let profile = EcheveriaProfile.getProfileObject(from: group.members[index]) {
                        dic[profile.firstName] = colors[index]
                    }
                }
                self.dictionary = dic
            }
            
            VStack {
                HStack {
                    UniversalText("Best Player", size: Constants.UISubHeaderTextSize, true)
                    Spacer()
                    UniversalText("\(bestPlayer.player.firstName) (\(bestPlayer.winCount) wins)", size: Constants.UISubHeaderTextSize)
                }.padding(.bottom, 5)
            
                HStack {
                    UniversalText("Worst Player", size: Constants.UISubHeaderTextSize, true)
                    Spacer()
                    UniversalText("\(worstPlayer.player.firstName) (\(worstPlayer.winCount) wins)", size: Constants.UISubHeaderTextSize)
                }
            }.padding([.horizontal, .bottom], 5)
            
        }
    }
}
