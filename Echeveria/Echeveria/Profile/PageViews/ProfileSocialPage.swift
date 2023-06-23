//
//  ProfileSocialPage.swift
//  Echeveria
//
//  Created by Brian Masse on 6/23/23.
//

import Foundation
import SwiftUI
import RealmSwift

//MARK: ProfileSocialPage
struct ProfileSocialPage: View {
    
    @ObservedRealmObject var profile: EcheveriaProfile
    let allGroups: Results<EcheveriaGroup>
    let geo: GeometryProxy
    
    var body: some View {
        VStack(alignment: .leading) {
            ProfilePageTitle(profile: profile, text: "Social", size: Constants.UISubHeaderTextSize)
            
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    UniversalText("Groups", size: Constants.UIHeaderTextSize, true)
                    GroupCollectionView(profile: profile, allGroups: allGroups, geo: geo)
                        .padding(.bottom)
                    
                }.frame(width: geo.size.width)
            }
        }
    }
//    MARK: GroupCollectionView
    struct FriendsCollectionView: View {
        
        var body: some View {
            Text("he")
        }
        
    }
    
    
//    MARK: GroupCollectionView
    struct GroupCollectionView: View {
        
        let profile: EcheveriaProfile
        let allGroups: Results<EcheveriaGroup>
        let geo: GeometryProxy
        
        @State var showingGroupCreationView = false
        
        var body: some View {
            let groups = profile.getAllowedGroups(from: allGroups)
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    ZStack(alignment: .topTrailing) {
                        GroupListView(title: "My Groups", groups: groups, geo: geo ) { group in group.owner == profile.ownerID }
                        CircularButton(icon: "plus") { showingGroupCreationView = true  }
                            .padding( [.leading], 5 )
                            .sheet(isPresented: $showingGroupCreationView) { GroupCreationView() }
                    }
                    
                    GroupListView(title: "Joined Groups", groups: groups, geo: geo ) { group in
                        group.owner != profile.ownerID && group.members.contains(where: { str in str == profile.ownerID })
                    }
                }
            }
        }
    }
}
