//
//  GroupView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/18/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct GroupView: View {
    
    enum GroupPage: Hashable {
        case overview
        case stats
    }
    
    @ObservedRealmObject var group: EcheveriaGroup    
    let games: Results<EcheveriaGame>
    
    @State var page: GroupPage = .overview
    
    var body: some View {

        ZStack(alignment: .top) {
            LinearGradient(colors: [.red.opacity(0.8), .clear], startPoint: .top, endPoint: .bottom )
                .frame(maxHeight: 300)
            
            GeometryReader { geo in
                VStack {
                    UniversalText(group.name, size: Constants.UITitleTextSize, wrap: false, true)
                    
                    TabView(selection: $page) {
                        MainGroupViewPage(group: group, games: games, geo: geo).tag(GroupPage.overview)
                        ChartsGroupViewPage(group: group, games: games, geo: geo).tag(GroupPage.stats)
                    }
                }
                
                
            }.padding()
        }
        .universalBackground(padding: false)
        .ignoresSafeArea()
    }
    

}

struct EditingGroupView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let group: EcheveriaGroup
    
    @State var name: String
    @State var icon: String
    @State var description: String
    
    var body: some View {
        VStack {
            Form {
                Section("Basic Information") {
                    TextField("Group Name", text: $name)
                    TextField("Group Description", text: $description)
                    TextField("Group Icon", text: $icon)
                }
            }
            .scrollContentBackground(.hidden)
            
            RoundedButton(label: "Done", icon: "checkmark.seal") {
                group.updateInformation(name: name, icon: icon, description: description)
                presentationMode.wrappedValue.dismiss()
            }
        }
        .universalBackground()
    }
}
