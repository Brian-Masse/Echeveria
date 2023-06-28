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
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                
                ProfilePageView(profile: EcheveriaModel.shared.profile, page: $page)
                
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
//                    .background( Colors.tint )
                    .background(.ultraThickMaterial)
                    .cornerRadius(100)
                    .padding(.leading, 20)
                    .shadow(radius: 7)
                    
//                    RoundedButton(label: "Log Game", icon: "signpost.and.arrowtriangle.up") { logging = true }
                    
                    HStack {
                        Spacer()
                        TabBarButton(icon: "house.lodge", test: mainView, activePage: $page, page: .main)
                        TabBarButton(icon: "chart.bar.xaxis", test: mainView, activePage: $page, page: .games)
                        TabBarButton(icon: "person.3.sequence", test: mainView, activePage: $page, page: .social)
                        TabBarButton(icon: "magnifyingglass", test: mainView, activePage: $page, page: .search)
                            .padding(.trailing, 20)
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
        .sheet(isPresented: $logging) { GameLoggerView() }
    }
    
    struct TabBarButton: View {
        
        @Environment(\.colorScheme) var colorScheme
        let icon: String
        let test: Namespace.ID

        @Binding var activePage: ProfilePage
        let page: ProfilePage
        
        var body: some View {
            
            ZStack {
                
                if activePage == page {
                    Rectangle()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.ultraThickMaterial)
                        .cornerRadius(Constants.UIDefaultCornerRadius)
                        .rotationEffect(Angle(radians: CGFloat.pi / 4))
                        .matchedGeometryEffect(id: "highlight", in: test)
                }
                
                Image(systemName: icon)
                    .onTapGesture { withAnimation { activePage = page }}
                    .padding(15)
                    .universalTextStyle()
                
            }
        }
    }
}
