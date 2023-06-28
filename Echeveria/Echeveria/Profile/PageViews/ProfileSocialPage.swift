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
        VStack {
            ProfilePageTitle(profile: profile, text: "Social", size: Constants.UISubHeaderTextSize)
            
            ScrollView(.vertical) {
                VStack(alignment: .leading) {

                    ProfileViews.FriendView(profile: profile, geo: geo)
                        .padding(.bottom)

                    
                    UniversalText("Groups", size: Constants.UIHeaderTextSize, true)
                    GroupCollectionView(profile: profile, allGroups: allGroups, geo: geo)
                        .padding(.bottom)
                    
                }
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
            ZStack(alignment: .topTrailing) {
                
                ListView(title: "My Groups", collection: groups, geo: geo) { group in group.owner == profile.ownerID }
                contentBuilder: { group in GroupPreviewView(group: group, geo: geo) }
                
                if groups.count != 0 {
                    ShortRoundedButton("add", icon: "plus") { showingGroupCreationView = true }
                        .offset(y: -5)
                }
                    
            }
            .padding(.bottom)
            .sheet(isPresented: $showingGroupCreationView) { GroupCreationView(group: nil,
                                                                               name: "", icon:
                                                                                "rectangle.3.group",
                                                                               description: "",
                                                                               colorIndex: 0,
                                                                               editing: false) }
            
            if groups.count == 0 {
                LargeFormRoundedButton(label: "Add or Join Group", icon: "plus") { showingGroupCreationView = true }
            }
            
            ListView(title: "Joined Groups", collection: groups, geo: geo) { group in
                group.owner != profile.ownerID && group.members.contains(where: { str in str == profile.ownerID })
            } contentBuilder: { group in GroupPreviewView(group: group, geo: geo) }
                .padding(.bottom, 80)
        }
    }
}
