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
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                UniversalText("Groups", size: Constants.UIHeaderTextSize, true)
                GroupCollectionView(profile: profile, allGroups: allGroups)
            }
        }
    }
    
//    MARK: GroupCollectionView
    struct GroupCollectionView: View {
        
        let profile: EcheveriaProfile
        let allGroups: Results<EcheveriaGroup>
        
        @State var showingGroupCreationView = true
        
        var body: some View {
            let groups = profile.getAllowedGroups(from: allGroups)
            
            ScrollView(.vertical) {
                GroupListView(title: "My Groups:", groups: groups )
            }
            
            RoundedButton(label: "Create Group", icon: "plus.square") { showingGroupCreationView = true }
            .sheet(isPresented: $showingGroupCreationView) { GroupCreationView() }
        }
        
    }
}
