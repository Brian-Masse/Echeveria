//
//  BestPlayerGraph.swift
//  Echeveria
//
//  Created by Brian Masse on 6/29/23.
//

import Foundation
import SwiftUI
import Charts
import RealmSwift

struct DataNode {
    var id: String
    var name: String {
        get { EcheveriaProfile.getProfileObject(from: id)?.firstName ?? "?" }
        set { id = newValue }
    }
    let wins: Int
    let date: Date
    let type: String
}

//MARK: TimeByPlayerAndTypeChart
struct TimeByPlayerAndTypeChart<Graph: View>: View {
    
    let title: String
    let group: EcheveriaGroup
    let games: [EcheveriaGame]
    
    @ViewBuilder var chartBuilder: ( Binding<[String]>, Binding<[String]>  ) -> Graph
    
    @State var filteredMembers: [String] = []
    @State var filteredGames:   [String] = []
    
    var body: some View {

        VStack {
            HStack {
                UniversalText(title, size: Constants.UISubHeaderTextSize, true)
                Spacer()
                let menu = Menu {
                    Menu {
                        ForEach( group.members ) { id in
                            Button { withAnimation { filteredMembers.toggleValue(id) }} label: {
                                let selected = !filteredMembers.contains { str in str == id }
                                if selected { Image(systemName: "checkmark") }
                                Text(EcheveriaProfile.getName(from: id))
                            }
                        }
                    } label: { Text("Players") }

                    Menu {
                        ForEach( EcheveriaGame.GameType.allCases.indices, id: \.self ) { i in
                            Button { withAnimation {filteredGames.toggleValue( EcheveriaGame.GameType.allCases[i].rawValue ) } } label: {
                                let selected = !filteredGames.contains { str in str.strip() == EcheveriaGame.GameType.allCases[i].rawValue.strip() }
                                if selected { Image(systemName: "checkmark") }
                                Text(EcheveriaGame.GameType.allCases[i].rawValue)
                            }
                        }
                    } label: { Text("Games") }
                } label: { FilterButton() }

                if #available(iOS 16.4, *) {
                    menu
                        .menuActionDismissBehavior(.disabled)
                } else {
                    menu
                }
                
                    
            }
            chartBuilder($filteredGames, $filteredMembers)
        }
        .padding()
        .universalTextStyle()
        .rectangularBackgorund()
    }
}

struct TimeByTypeChart<Graph: View>: View {
    
    let title: String
    let games: [EcheveriaGame]
    
    @ViewBuilder var chartBuilder: ( Binding<[String]> ) -> Graph
    @State var filteredGames:   [String] = []
    
    var body: some View {

        VStack {
            HStack {
                UniversalText(title, size: Constants.UISubHeaderTextSize, true)
                Spacer()
                let menu = Menu {
                    ForEach( EcheveriaGame.GameType.allCases.indices, id: \.self ) { i in
                        Button { withAnimation {filteredGames.toggleValue( EcheveriaGame.GameType.allCases[i].rawValue.strip() ) } } label: {
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
            chartBuilder($filteredGames)
                .chartYAxis {
                    AxisMarks() { value in
                        AxisValueLabel {
                            if let num =  value.as(Double.self) {
                                UniversalText("\(num)", size: Constants.UIDefaultTextSize, fixed: true)
                            }
                        }
                    }
                }
        }
        .padding()
        .universalTextStyle()
        .rectangularBackgorund()
    }
}

