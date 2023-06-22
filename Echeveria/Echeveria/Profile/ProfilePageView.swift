//
//  ProfilePageView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/21/23.
//

import Foundation
import RealmSwift
import SwiftUI

struct ProfilePageView: View {
    
    enum ProfilePage: String, CaseIterable, Identifiable {
        case main = "main"
        case groups = "groups"
        case games = "games"
        
        var id: String {
            self.rawValue
        }
    }
    
    private func getTextSize() -> CGFloat {
        switch page {
        case .main: return 45
        default:    return 20
        }
    }
    
    @ObservedObject var profile: EcheveriaProfile
    @ObservedResults(EcheveriaGroup.self) var groups
    
    @State var page: ProfilePage = .main
    
    var mainUser: Bool { profile.ownerID == EcheveriaModel.shared.profile.ownerID }
    
    var body: some View {
        GeometryReader { geo in
            
            AsyncLoader {
                let filteredGroups: [EcheveriaGroup] = groups.filter { group in
                    group.members.contains( profile.ownerID )
                }   
                if !profile.loaded { await profile.updatePermissions(groups: filteredGroups) }
            } content: {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: profile.icon)
                            .resizable()
                            .frame(width: getTextSize(), height: getTextSize())
                        UniversalText(profile.userName, size: getTextSize(), true)
                    }
                    
                    
                    TabView(selection: $page) {
                        ProfileMainView(profile: profile, geo: geo).tag( ProfilePage.main )
                        ProfileGameView(profile: profile, geo: geo).tag( ProfilePage.games )
                        Text("Groups").tag( ProfilePage.groups )
                    }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                }
            }
        }
        .universalBackground()
    }
}
