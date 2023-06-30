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
                await group.updatePermissionsForGroupView(id: group._id.stringValue)
                EcheveriaModel.shared.addActiveColor(with: Colors.colorOptions[group.colorIndex])
            } content: {
                ZStack(alignment: .topTrailing) {
                    VStack(alignment: .leading) {
                        HStack {
                            UniversalText(group.name, size: Constants.UITitleTextSize, wrap: false, true)
                            Spacer()
                            ProfileViews.DismissView {
                                await group.closePermissions(id: group._id.stringValue)
                                EcheveriaModel.shared.removeActiveColor()
                            }
                        }
                        
                        TabView(selection: $page) {
                            MainGroupViewPage(group: group, games: games, geo: geo).tag(GroupPage.overview)
                            ChartsGroupViewPage(group: group, games: games, geo: geo).tag(GroupPage.stats)
                        }
                    }
                }
                .padding(.top, 45)
                .padding(.bottom, 30)
            }
        }
        .padding()
        .universalColoredBackground( Colors.colorOptions[ group.colorIndex ] )
    }
    

}
