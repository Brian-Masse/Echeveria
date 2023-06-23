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
    
    @State var searchQuery: String = ""
    @State var showingSearchView: Bool = false
    
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
        
        TextField("Search...", text: $searchQuery)
        
        AsyncRoundedButton(label: "Search", icon: "magnifyingglass.circle") {
            await search( searchQuery )
            showingSearchView = true
        }
        
        if showingSearchView {
            VStack {
                GroupListView(title: "Groups") { group in !group.hasMember(EcheveriaModel.shared.profile.ownerID) }
                
                ProfileListView(title: "Players") { profile in profile.firstName == searchQuery || profile.lastName == searchQuery }
            }
        }
    }
}
