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
                            .frame(width: 60, height: 60)
                        UniversalText(profile.userName, size: 45, true)
                    }
                    
                    Picker(selection: $page) {
                        ForEach(ProfilePage.allCases, id: \.self) { content in
                            Text(content.rawValue)
                        }
                    } label: { Text("View") }.pickerStyle(.segmented)
                    
                    switch page {
                    case .main: ProfileMainView(profile: profile, geo: geo)
                    case .games: ProfileGameView(profile: profile, geo: geo)
                    case .groups: EmptyView()
                    }
                }
            }
        }
        .universalBackground()
    }
}
