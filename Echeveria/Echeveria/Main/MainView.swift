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
    
    enum ProfilePage: String, CaseIterable, Identifiable {
        case main = "Home"
        case games = "Games"
        case social = "Social"
        case search = "search"
        
        var id: String {
            self.rawValue
        }
    }
    
    @Namespace var mainView
    @State var page: ProfilePage = .main
    @State var logging: Bool = false
    
    @ObservedResults( EcheveriaGroup.self ) var groups
    @ObservedResults( EcheveriaProfile.self, where: { query in query.ownerID == EcheveriaModel.shared.profile.ownerID } ) var profiles
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                
                ProfilePageView(profile: profiles.first!, page: $page)
                
                ZStack(alignment: .leading) {
                    
                    HStack {
                        ResizeableIcon(icon: "signpost.and.arrowtriangle.up", size: Constants.UISubHeaderTextSize)
                        VStack(alignment: .leading) {
                            UniversalText("Log", size: Constants.UIDefaultTextSize, true)
                            UniversalText("Game", size: Constants.UIDefaultTextSize, true)
                        }
                    }
                    .padding()
                    .padding(.horizontal, 5)
                    .universalTextStyle()
                    .background(.ultraThickMaterial)
                    .cornerRadius(100)
                    .padding(.leading, 15)
                    .shadow(radius: 7)
                    .onTapGesture { logging = true }
                    
                    HStack {
                        Spacer()
                        TabBarButton(icon: "house.lodge", test: mainView, geo: geo, activePage: $page, page: .main)
                        TabBarButton(icon: "chart.bar", test: mainView, geo: geo, activePage: $page, page: .games)
                        TabBarButton(icon: "person.3.sequence", test: mainView, geo: geo, activePage: $page, page: .social)
                        TabBarButton(icon: "magnifyingglass", test: mainView, geo: geo, activePage: $page, page: .search)
                            .padding(.trailing, 15)
                    }
                        
                }
                .frame(width: geo.size.width)
                .padding(.vertical, 15)
                .padding(.bottom)
                .rectangularBackgorund(radius: 45)
                .shadow(color: .black.opacity(0.4), radius: 15, x: 0, y: 0)
            }.frame(width: geo.size.width)
        }
        .ignoresSafeArea()
        .sheet(isPresented: $logging) {
            GameLoggerView(editing: false,
                           gameID: nil,
                           gameType: .smash,
                           group: "",
                           selectedPlayers: [],
                           selectedWinners: [],
                           gameExperieince: .good,
                           gameComments: "",
                           gameValues: Dictionary())
             }
    }
    
    struct TabBarButton: View {
        
        @Environment(\.colorScheme) var colorScheme
        let icon: String
        let test: Namespace.ID
        let geo: GeometryProxy

        @Binding var activePage: ProfilePage
        let page: ProfilePage
        
        var body: some View {
            
            ZStack {
                
                if activePage == page {
                    Rectangle()
                        .frame(width: (50 / 414) * geo.size.width, height: (50 / 414) * geo.size.width)
                        .foregroundStyle(.ultraThickMaterial)
                        .cornerRadius(Constants.UIDefaultCornerRadius)
                        .rotationEffect(Angle(radians: CGFloat.pi / 4))
                        .matchedGeometryEffect(id: "highlight", in: test)
                }
                
                Image(systemName: icon)
                    .onTapGesture { withAnimation { activePage = page }}
                    .padding(13)
                    .universalTextStyle()
                
            }
        }
    }
}
