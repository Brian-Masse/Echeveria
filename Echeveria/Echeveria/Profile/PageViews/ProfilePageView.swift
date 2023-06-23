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
        case social = "social"
        case games = "games"
        
        var id: String {
            self.rawValue
        }
    }
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var profile: EcheveriaProfile
    @ObservedResults(EcheveriaGroup.self) var groups
    @ObservedResults(EcheveriaGame.self) var games
    
    @State var page: ProfilePage = .main
    
    var mainUser: Bool { profile.ownerID == EcheveriaModel.shared.profile.ownerID }
    
    var body: some View {
        GeometryReader { geo in
            
            AsyncLoader {
                let filteredGroups: [EcheveriaGroup] = groups.filter { group in
                    group.members.contains( profile.ownerID )
                } 
                await profile.updatePermissions(groups: filteredGroups, id: profile.ownerID)
            } content: {
                VStack(alignment: .leading) {
                    TabView(selection: $page) {
                        ProfileMainView(profile:    profile, geo: geo).tag( ProfilePage.main )
                        ProfileGameView(profile:    profile, allGames: $games.wrappedValue,     geo: geo).tag( ProfilePage.games )
                        ProfileSocialPage(profile:  profile, allGroups: $groups.wrappedValue,   geo: geo).tag( ProfilePage.social )
                    }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                }
            }
        }
        .universalBackground()
    }
}

struct ProfilePageTitle: View {
    
    let profile: EcheveriaProfile
    let text: String
    let size: CGFloat
    
    var body: some View {
        HStack {
            ResizeableIcon(icon: profile.icon, size: size)
            UniversalText(text, size: size, true)
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
