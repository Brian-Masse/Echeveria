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
//
                    UniversalText("Friends", size: Constants.UIHeaderTextSize, true)
                    ListView(title: "", collection: profile.friends, geo: geo) { id in true } contentBuilder: { profileID in
                        ProfilePreviewView(profileID: profileID)
                    }
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
                
                CircularButton(icon: "plus") { showingGroupCreationView = true  }
                    .padding( [.leading], 5 )
                    .sheet(isPresented: $showingGroupCreationView) { GroupCreationView(group: nil,
                                                                                       name: "", icon:
                                                                                        "rectangle.3.group",
                                                                                       description: "",
                                                                                       colorIndex: 0,
                                                                                       editing: false) }
            }.padding(.bottom)
            
            ListView(title: "Joined Groups", collection: groups, geo: geo) { group in
                group.owner != profile.ownerID && group.members.contains(where: { str in str == profile.ownerID })
            } contentBuilder: { group in GroupPreviewView(group: group, geo: geo) }
                .padding(.bottom, 80)
        }
    }
}
