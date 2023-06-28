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
    
    @ObservedResults( EcheveriaGroup.self ) var groups
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                
                switch page {
                case .profile: ProfilePageView(profile: EcheveriaModel.shared.profile)
                case .search: SearchPageView()
                case .main: VStack { Text("top")
                    
//                    ProfileSocialPage(profile: EcheveriaModel.shared.profile, allGroups: groups, geo: geo)
                    
                    Spacer()
                    Text("bottom") }
                }
                
                HStack {
                    
//                    RoundedButton(label: "Log Game", icon: "signpost.and.arrowtriangle.up") { logging = true }
                    
                    Spacer()
                    NamedButton("Home", and: "house.lodge", oriented: .vertical).onTapGesture { page = .main }
                    NamedButton("Search", and: "magnifyingglass", oriented: .vertical).onTapGesture { page = .search }
                    NamedButton("Profile", and: "person.crop.square", oriented: .vertical).onTapGesture { page = .profile }
                    
                }
                .padding()
                .background(Rectangle()
                    .cornerRadius(30)
                    .universalForeground()
                    .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
                )
                .padding(.horizontal)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .sheet(isPresented: $logging) { GameLoggerView() }
    }
}
