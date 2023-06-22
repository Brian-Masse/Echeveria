//
//  ProfileView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/17/23.
//

import Foundation
import SwiftUI
import RealmSwift
import Charts

//MARK: ProfileMainView
struct ProfileMainView: View {
    
    @ObservedObject var profile: EcheveriaProfile
    @State var editing: Bool = false
    
    let geo: GeometryProxy
    
    var mainUser: Bool { profile.ownerID == EcheveriaModel.shared.profile.ownerID }
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.vertical) {
                UniversalText("\(profile.firstName) \(profile.lastName)", size: 20)
                UniversalText(profile.ownerID, size: 25, true)
                    .padding(.bottom)
                
                if mainUser {
                    RoundedButton(label: "Edit", icon: "pencil.line") { editing = true }
                }
            }
            Spacer()
        }
        .frame(width: geo.size.width)
        .sheet(isPresented: $editing) { EditingProfileView().environmentObject(profile) }
    }
    
}

//MARK: ProfileGameView
struct ProfileGameView: View {
    
    @ObservedObject var profile: EcheveriaProfile
    
    @State var logging: Bool = false
    
    let geo: GeometryProxy
    var mainUser: Bool { profile.ownerID == EcheveriaModel.shared.profile.ownerID }
    
    var body: some View {
        
        let games: Results<EcheveriaGame> = EcheveriaModel.retrieveObject { game in game.ownerID == profile.ownerID}
        let recentGames = games.returnFirst(5)
        
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                
                UniversalText("Recent Games", size: 30, true)    
                GameScrollerView(filter: .none, filterable: false, geo: geo, gamesArr: recentGames )
                
                
                GameChart(profile: profile, games: games)
                
                let winCountData = profile.getWins(in: .now, games: Array(games))
                
                HStack {
                    StaticGameChart(profile: profile, games: games, title: "Wins by Game", data: winCountData)
                        { dataPoint in dataPoint.game.rawValue } getYAxis: { dataPoint in dataPoint.winCount }
                    
                    StaticGameChart(profile: profile, games: games, title: "Win Rate by Game", data: winCountData)
                        { dataPoint in dataPoint.game.rawValue } getYAxis: { dataPoint in Float(dataPoint.winCount) / Float(max(1, dataPoint.totalCount)) }
                }

                GameScrollerView(filter: .gameType, filterable: true, geo: geo, games: EcheveriaModel.retrieveObject { game in game.ownerID == profile.ownerID} )
            }
            Spacer()
        }
        .sheet(isPresented: $logging) { GameLoggerView() }
        .universalBackground()
    }
    
    struct StaticGameChart<DataType: Collection, XAxisData, YAxisData>: View where DataType: RandomAccessCollection, XAxisData: Plottable, YAxisData: Plottable, DataType.Index: Hashable {
        
        @ObservedObject var profile: EcheveriaProfile
        
        let games: Results<EcheveriaGame>
        
        let title: String
        
        let data: DataType
        let getXAxis: ( DataType.Element ) -> XAxisData
        let getYAxis: ( DataType.Element ) -> YAxisData
        
        var body: some View {
            ZStack(alignment: .topLeading) {
                Chart {
                    ForEach(data.indices, id: \.self) { i in
                        BarMark(
                            x: .value("X", getXAxis( data[i] ) ),
                            y: .value("Y", getYAxis( data[i] ) ))
                        
                    }
                }.universalChart()
                UniversalText(title, size: 20, true)
                    .padding(5)
            }
        }
    }
    
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
        
        @ObservedObject var profile: EcheveriaProfile
        
        @State var yAxisDataType: AxisDataType = .type
        @State var typeAxisDataType: AxisDataType = .winning
        
        let games: Results<EcheveriaGame>
        
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
                            AxisValueLabel( date.formatted(.dateTime)  )
                        }
                        
                        AxisGridLine()
                        AxisTick()
                    }
                }
                .universalChart()
                
                HStack {
                    UniversalText("Graph 1", size: 20, true)
                    Spacer()
                    Menu {
                        EditMenu(editingAxis: $yAxisDataType, title: "Y Axis")
                        EditMenu(editingAxis: $typeAxisDataType, title: "Series")
                    } label: {
                        CircularButton(icon: "chart.dots.scatter") {}
                            .universalTextStyle()
                    }
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

//MARK: EditingProfileView
struct EditingProfileView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var profile: EcheveriaProfile
    
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var userName: String = ""
    @State var icon: String = ""
    
    var body: some View {
        VStack {
            LabeledHeader(icon: "pencil.line", title: "Edit Profile")
            
            Form {
                Section("Basic Information") {
                    TextField( "First Name", text: $firstName )
                    TextField( "Last Name", text: $lastName )
                    TextField( "User Name", text: $userName )
                    TextField( "Icon", text: $icon )
                }.universalFormSection()
            }
            .universalForm()
            .onAppear {
                firstName = profile.firstName
                lastName = profile.lastName
                userName = profile.userName
                icon = profile.icon
            }
            RoundedButton(label: "Done", icon: "checkmark.seal") {
                profile.updateInformation(firstName: firstName, lastName: lastName, userName: userName, icon: icon)
                presentationMode.wrappedValue.dismiss()
            }
            RoundedButton(label: "Signout", icon: "shippingbox.and.arrow.backward") {
                EcheveriaModel.shared.realmManager.logoutUser()
            }
            
        }.universalBackground()
    }
}
