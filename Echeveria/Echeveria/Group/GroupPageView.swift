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
    @State var dismissing: Bool = false
    
    var body: some View {

        GeometryReader { geo in
            
            AsyncLoader {
                await group.updatePermissionsForGroupView(id: group._id.stringValue)
                EcheveriaModel.shared.addActiveColor(with: group.getColor() )
            } content: { if !dismissing {
                ZStack(alignment: .topTrailing) {
                    VStack(alignment: .leading) {
                        HStack {
                            UniversalText(group.name, size: Constants.UITitleTextSize, wrap: false, true)
                            Spacer()
                            ProfileViews.DismissView { EcheveriaModel.shared.removeActiveColor() } action: {
                                dismissing = true
                                await group.closePermissions(id: group._id.stringValue)
                            }
                            
                        }
                        
                        TabView(selection: $page) {
                            MainGroupViewPage(group: group, games: games, geo: geo, deleting: $dismissing).tag(GroupPage.overview)
                            ChartsGroupViewPage(group: group, games: games, geo: geo).tag(GroupPage.stats)
                        }
                    }
                }
                .frame(width: geo.size.width)
                .padding(.top, Constants.UIFullScreenTopPadding)
                .padding(.bottom, 30)
            } }
        }
        .padding()
        .universalColoredBackground( group.getColor() )
    }
    

}
