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
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedRealmObject var group: EcheveriaGroup
    let games: Results<EcheveriaGame>
    let geo: GeometryProxy
    
    @State var editing: Bool = false
    @Binding var deleting: Bool
    
    var owner: Bool { group.owner == EcheveriaModel.shared.profile.ownerID }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                
                HStack {
                    ResizeableIcon(icon: group.icon, size: Constants.UIHeaderTextSize)
                    UniversalText(group.groupDescription, size: Constants.UIDefaultTextSize)
                }
                
                UniversalText("Created on \(group.createdDate.formatted(date: .numeric, time: .omitted))", size: Constants.UIDefaultTextSize, lighter: true)
                
                MembersView(group: group)
                    .padding(.bottom)
//
                if games.count != 0 {
                    UniversalText("Highlights", size: Constants.UIHeaderTextSize, true)
                    TimeByPlayerAndTypeChart(title: "Win History", group: group, games: Array(games)) { fgames, fmembers in
                        WinHistoryChart(group: group, games: Array(games), filteredMembers: fmembers, filteredGames: fgames)
                    }


                } else {
                    LargeFormRoundedButton(label: "Log Games to View Data", icon: "signpost.and.arrowtriangle.up") {}
                }

                if group.members.contains(where: { str in str == EcheveriaModel.shared.profile.ownerID }) {
                    RoundedButton(label: "Edit Group", icon: "pencil.line") { editing = true }
                }
                
                if owner {
                    AsyncRoundedButton(label: "Delete Group", icon: "x.square") {
                        deleting = true

                        EcheveriaModel.shared.removeActiveColor()
                        presentationMode.wrappedValue.dismiss()

                        await group.closePermissions(id: group._id.stringValue)
                        group.deleteGroup()
                    }
                }
            }.padding(.bottom, 20)
        }
        .padding()
        .presentableContent(.sheet, presenting: $editing, getColor: group.getColor) {
            GroupCreationView(title: "Edit Group",
                              group: group,
                              name: group.name,
                              icon: group.icon,
                              description: group.groupDescription,
                              color: group.getColor(),
                              editing: true)
        }
    }
    
    struct MembersView: View {
        
        @ObservedRealmObject var group: EcheveriaGroup
        
        var body: some View {
            VStack(alignment: .leading) {
                UniversalText("Members", size: Constants.UIHeaderTextSize, true)
                VStack {
                    ForEach( group.members, id: \.self ) { memberID in
                        ProfilePreviewView(profileID: memberID)
                            .padding(.bottom, 5)
                    }
                }
            }
            
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
        
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                
                if games.count != 0 {
                    
                    UniversalText("Stats", size: Constants.UIHeaderTextSize, true)
                    
                    let games = Array(games)
                    
                    TimeByPlayerAndTypeChart(title: "Win History", group: group, games: games) { fgames, fmembers in
                        WinHistoryChart(        group: group, games: Array(games), filteredMembers: fmembers, filteredGames: fgames)
                        TotalWinHistoryChart(   group: group, games: Array(games), filteredMembers: fmembers, filteredGames: fgames)
                        WinRateChart(           group: group, games: Array(games), filteredMembers: fmembers, filteredGames: fgames)
                    }
                    
                    
                    RecentGamesView(games: games, geo: geo)
                    
                    GameCountHistoryGraph(group: group, games: Array(games))
                        .padding(.bottom)
                    
                    TimeByPlayerAndTypeChart(title: "Win Streaks", group: group, games: games) { fgames, fmembers in
                        WinStreakHistoryChart(group: group, games: games, filteredMembers: fmembers, filteredGames: fgames)
                    }
                        .padding(.bottom)
                    
                    GameScrollerView(title: "All Games", filter: .gameType, filterable: true, geo: geo, games: EcheveriaGame.reduceIntoStrings(from: Array(games)))
                        .padding(.bottom, 80)
                } else {
                    LargeFormRoundedButton(label: "Log Games to View Data", icon: "signpost.and.arrowtriangle.up") {}
                }
            }
        }
        .padding()
    }
}
