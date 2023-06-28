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

        GeometryReader { geo in
            
            AsyncLoader {
                await group.updatePermissionsForGroupView()
            } content: {
                VStack(alignment: .leading) {
                    UniversalText(group.name, size: Constants.UITitleTextSize, wrap: false, true)
                    
                    TabView(selection: $page) {
                        MainGroupViewPage(group: group, games: games, geo: geo).tag(GroupPage.overview)
                        ChartsGroupViewPage(group: group, games: games, geo: geo).tag(GroupPage.stats)
                    }
                }
            }
        }
        .padding()
        .universalColoredBackground( Colors.colorOptions[ group.colorIndex ] )
    }
    

}
