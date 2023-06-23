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

struct ProfilePageTitle: View {
    
    let profile: EcheveriaProfile
    let size: CGFloat
    
    var body: some View {
        HStack {
            Image(systemName: profile.icon)
                .resizable()
                .frame(width: size, height: size)
            UniversalText(profile.userName, size: size, true)
            Spacer()
        }
    }
}

struct ProfileListView: View {
    
    let title: String
    let query: ((EcheveriaProfile) -> Bool)

    @ObservedResults(EcheveriaProfile.self) var profiles
    
    var body: some View {
        
        let filtered = profiles.filter(query)
        
        if !filtered.isEmpty {
            HStack {
                Text(title).bold(true)
                Spacer()
            }
            ForEach(profiles, id: \._id) { profile in
                if query(profile) {
                    ProfileCard(profileID: profile.ownerID)
                }
            }
        }
    }
    
}
