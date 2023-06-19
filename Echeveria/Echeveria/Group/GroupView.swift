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
    @State var leaving: Bool = false
    
    @ObservedResults(EcheveriaGroup.self) var groups
    
    let profile = EcheveriaModel.shared.profile!
    
    var body: some View {
        
        VStack {
            RoundedButton(label: "Create Group", icon: "plus.square") { showingGroupCreationView = true }
            
            TextField("Search...", text: $searchQuery)
            RoundedButton(label: "Search for Group", icon: "magnifyingglass.circle") { loadingSearch = true }
            
            Text("My Groups:").bold(true)
            
            
            ForEach(groups, id: \._id) { group in
                if group.owner == profile.ownerID {
                    Text("owner")
                }
                if group.members.contains(where: { id in id == profile.ownerID }) {
                    GroupView(group: group)
                }
            }
            
            if loadingSearch {
                ProgressView()
                    .task {
                        await EcheveriaGroup.searchForGroup(searchQuery, profile: profile)
                        loadingSearch = false
                        showingGroupSearchView = true
                    }
            }
            
            if showingGroupSearchView {
                Text("Found Groups:").bold(true)
                ForEach(groups, id: \._id) { group in
                    if group.members.contains(where: { id in id != profile.ownerID }) {
                        GroupView(group: group)
                    }
                }
            }
            
            if leaving {
                ProgressView()
                    .task { await EcheveriaGroup.resetSearch(profile: profile) }
            }
        }
        .onDisappear { leaving = true }
        .sheet(isPresented: $showingGroupCreationView) { GroupCreationView() }
    }
    
}

struct GroupView: View {
    
    @ObservedRealmObject var group: EcheveriaGroup
    
    var body: some View {
        
        HStack {
            Image(systemName: group.icon)
            Text(group.name)
                .bold(true)
            Spacer()
        }
        .padding(10)
        .background(Rectangle()
            .cornerRadius(40)
            .foregroundColor(.white)
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
