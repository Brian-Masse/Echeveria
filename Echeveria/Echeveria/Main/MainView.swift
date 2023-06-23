//
//  OpenFlexibleSyncRealmView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import SwiftUI
import RealmSwift


struct MainView: View {
    
    enum MainViewPage {
        case main
        case search
        case profile
    }
    
    @State var page: MainViewPage = .main
    @State var logging: Bool = false
    
    var body: some View {
        
        VStack {
            
            switch page {
            case .profile: ProfilePageView(profile: EcheveriaModel.shared.profile)
            case .search: SearchPageView()
            case .main: EmptyView()
            }
            Spacer()
            HStack {
                
                RoundedButton(label: "Log Game", icon: "signpost.and.arrowtriangle.up") { logging = true }
                
                Spacer()
                NamedButton("Home", and: "house.lodge", oriented: .vertical).onTapGesture { page = .main }
//                    .padding(.horizontal)
                NamedButton("Search", and: "magnifyingglass", oriented: .vertical).onTapGesture { page = .search }
//                    .padding(.horizontal)
                NamedButton("Profile", and: "person.crop.square", oriented: .vertical).onTapGesture { page = .profile }
//                    .padding(.horizontal)
            }.padding([.top, .horizontal])
        }
        .sheet(isPresented: $logging) { GameLoggerView() }
        .universalBackground()
    }
}

struct CardView: View {
    @ObservedRealmObject var item: TestObject
    
    var body: some View {
        
        VStack {
            VStack {
                HStack {
                    Image(systemName: "globe")
                    Text(item.firstName)
                    Text(item.lastName)
                    Spacer()
                }.bold(true)
                
                HStack {
                    Text(item.ownerID)
                    Spacer()
                }
            }.padding()
            
            HStack {
                RoundedButton(label: "Delete", icon: "delete.backward", action: { EcheveriaModel.deleteObject(item) })
                RoundedButton(label: "Edit", icon: "pencil.circle", action: { item.updateName(to: "Updated!") })
            }
            .padding([.horizontal, .bottom])
        }
    
        .background(
            Rectangle()
                .universalForeground()
                .cornerRadius(20)
        )
    }
}
