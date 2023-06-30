//
//  SearchView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/22/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct SearchPageView: View {
    
    @State private var searchQuery: String = ""
    @State private var showingSearchView: Bool = false
    @FocusState private var formIsFocussed: Bool
    
    let geo: GeometryProxy
    
    @ObservedResults(EcheveriaGroup.self) var groups
    @ObservedResults(EcheveriaProfile.self) var profiles
    
    func search(_ search: String) async {
        
        await resetSearch()
        let realmManager = EcheveriaModel.shared.realmManager
        
        await realmManager.profileQuery.addQuery(QuerySubKey.profileSearch.rawValue) { profile in
            profile.firstName == search || profile.lastName == search
        }
        
        await EcheveriaModel.shared.realmManager.groupQuery.addQuery(QuerySubKey.groupSearch.rawValue) { query in
            query.name == search
        }
    }

    func resetSearch() async {
        let realmManager = EcheveriaModel.shared.realmManager
        await realmManager.profileQuery.removeQuery( QuerySubKey.profileSearch.rawValue )
        await realmManager.groupQuery.removeQuery( QuerySubKey.groupSearch.rawValue )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            UniversalText("Search", size: Constants.UIHeaderTextSize, true)
            UniversalText("Search for the name of other users or groups to join social parties, add friends, and log games together!", size: Constants.UIDefaultTextSize, lighter: true )
            
                .padding(.bottom)
            
            TextField("Search...", text: $searchQuery)
                .focused($formIsFocussed)
                .opaqueRectangularBackground()
                .padding(.horizontal, 7)
            
            AsyncRoundedButton(label: "Search", icon: "magnifyingglass.circle") {
                await search( searchQuery )
                formIsFocussed = false
                showingSearchView = true
            }
            Spacer()
            
            if showingSearchView {
                ScrollView(.vertical) {
                    VStack(alignment: .leading) {
                        
                        ListView(title: "Groups", collection: Array(groups), geo: geo) { group in !group.hasMember(EcheveriaModel.shared.profile.ownerID) }
                    contentBuilder: { group in GroupPreviewView( group: group, geo: geo ) }
                        
                        
                        let filtered = profiles.filter { profile in profile.firstName == searchQuery || profile.lastName == searchQuery }.compactMap { profile in
                            profile.ownerID
                        }
                        
//                            TODO: The first time this loads it will automatically dismiss the views
                        ListView(title: "Players", collection: Array(filtered), geo: geo) { _ in true } contentBuilder: { profileID in
                            ProfilePreviewView(profileID: profileID)
                        }
                    }
                }.padding(.bottom, 80)
            }
        }
    }
}
