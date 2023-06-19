//
//  GroupView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/18/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct GroupPageView: View {
    
    @State var showingGroupCreationView: Bool = false
    
    @State var searchQuery: String = ""
    @State var loadingSearch: Bool = false
    @State var showingGroupSearchView: Bool = false
    
    let profile = EcheveriaModel.shared.profile!
    
    var body: some View {
        
        VStack {
            RoundedButton(label: "Create Group", icon: "plus.square") { showingGroupCreationView = true }
            RoundedButton(label: "Search for Group", icon: "magnifyingglass.circle") { loadingSearch = true }
            TextField("Search...", text: $searchQuery)
            
            
            GroupListView(title: "My Groups:") { group in group.hasMember(profile.ownerID) }
            
            if showingGroupSearchView {
                GroupListView(title: "Search Results:") { group in !group.hasMember(profile.ownerID) }
            }
            
            if loadingSearch {
                AsyncLoader {
                    await EcheveriaGroup.searchForGroup(searchQuery, profile: profile)
                    showingGroupSearchView = true
                } closingTask: {
                    await EcheveriaGroup.resetSearch(profile: profile)
                }
            }
        }
        .sheet(isPresented: $showingGroupCreationView) { GroupCreationView() }
    }
    
}

struct GroupListView: View {
    
    let title: String
    let query: ((EcheveriaGroup) -> Bool)
    
    @ObservedResults(EcheveriaGroup.self) var groups
    
    var body: some View {
        
        let filtered = groups.filter(query)
        
        if !filtered.isEmpty {
            Text(title).bold(true)
            ForEach(groups, id: \._id) { group in
                if query(group) {
                    GroupPreviewView(group: group)
                }
            }
        }
    }
}

struct GroupPreviewView: View {
    
    @ObservedRealmObject var group: EcheveriaGroup
    let memberID = EcheveriaModel.shared.profile!.ownerID
    
    @State var showingGroup: Bool = false
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: group.icon)
                Text(group.name)
                    .bold(true)
                Spacer()
            }
            if group.owner == memberID  {
                Text("owner")
            }
            else if !group.hasMember(memberID) {
                RoundedButton(label: "join", icon: "plus.square") {
                    group.addMember(memberID)
                }
            } else {
                RoundedButton(label: "leave", icon: "shippingbox.and.arrow.backward") {
                    group.removeMember(memberID)
                }
            }
        }
        .padding(10)
        .background(Rectangle()
            .cornerRadius(15)
            .foregroundColor(.white)
            .onTapGesture { showingGroup = true }
            .sheet(isPresented: $showingGroup) { GroupView(group: group) }
        )
    }
}

struct GroupCreationView: View {
    
    @State var name: String = ""
    @State var icon: String = "square.on.square.squareshape.controlhandles"
    
    @Environment(\.presentationMode) var presentaitonMode
    
    var body: some View {
        
        VStack {
            Form {
                Section("Basic Information") {
                    TextField("Group Name", text: $name)
                    TextField("Icon", text: $icon)
                }
            }
            
            RoundedButton(label: "Submit", icon: "checkmark.seal") {
                let group = EcheveriaGroup(name: name, icon: icon)
                group.addToRealm()
                presentaitonMode.wrappedValue.dismiss()
            }
        }
        .padding()
        .background(Colors.lightGrey)
    }
}
