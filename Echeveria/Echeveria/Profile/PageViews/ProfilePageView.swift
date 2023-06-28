//
//  ProfilePageView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/21/23.
//

import Foundation
import RealmSwift
import SwiftUI

struct ProfilePageView: View {

    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var profile: EcheveriaProfile
    @ObservedResults(EcheveriaGroup.self) var groups
    @ObservedResults(EcheveriaGame.self) var games
    
    @Binding var page: MainView.ProfilePage
    
    var mainUser: Bool { profile.ownerID == EcheveriaModel.shared.profile.ownerID }
    
    var body: some View {
        GeometryReader { geo in
            
            AsyncLoader {
                let filteredGroups: [EcheveriaGroup] = groups.filter { group in
                    group.members.contains( profile.ownerID )
                } 
                await profile.updatePermissions(groups: filteredGroups, friendRequests: Array(profile.friendRequests), friends: Array(profile.friends), id: profile.ownerID)
            } content: {
                ZStack(alignment: .topTrailing) {
                    
                    ShapeBackgrond(page: $page, geo: geo,
                                   sizePath: [ .init(width: 150, height: 225), .init(width: 225, height: 337.5), .init(width: 225, height: 337.5) ],
                                   posPath: [ .init(x: -geo.size.width + 80, y: geo.size.height - 180), .init(x: -geo.size.width / 2, y: 50), .init(x: 100, y: 0) ],
                                   rotPath: [ -CGFloat.pi / 2.5, CGFloat.pi / 1.2, CGFloat.pi / 6 ])
                    
                    ShapeBackgrond(page: $page, geo: geo,
                                   sizePath: [ .init(width: 300, height: 450), .init(width: 225, height: 337.5), .init(width: 225, height: 337.5) ],
                                   posPath: [ .init(x: 70, y: 20), .init(x: 20, y: geo.size.height / 2), .init(x: -geo.size.width + 100, y: geo.size.height / 1.5) ],
                                   rotPath: [ 0, CGFloat.pi / 5, CGFloat.pi / 4.5 ])
                    
                    
                    VStack(alignment: .leading) {
                        TabView(selection: $page) {
                            ProfileMainView(profile:    profile, allGames: $games.wrappedValue, geo: geo).padding().tag( MainView.ProfilePage.main )
                            ProfileGameView(profile:    profile, allGames: $games.wrappedValue,     geo: geo).padding().tag(  MainView.ProfilePage.games )
                            ProfileSocialPage(profile:  profile, allGroups: $groups.wrappedValue,   geo: geo).padding().tag(  MainView.ProfilePage.social )
                            SearchPageView(geo: geo).padding().tag(  MainView.ProfilePage.search )
                        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    }
                    

                    if presentationMode.wrappedValue.isPresented {
                        
                        asyncShortRoundedButton(label: "dismiss", icon: "chevron.down") {
                            if !mainUser { await profile.closePermission(ownerID: profile.ownerID) }
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding(.top)
                        .padding(.top, 50)
                        .padding(.horizontal)
                    }
                }
            }
        }.universalColoredBackground(.blue)
    }
    
    struct ShapeBackgrond: View {
        
        @Environment(\.colorScheme) var colorScheme
        @Binding var page: MainView.ProfilePage
        let geo: GeometryProxy
        
        let sizePath: [CGSize]
        let posPath: [CGPoint]
        let rotPath: [CGFloat]
        
        private func getI() -> Int {
            switch page {
            case .main: return 0
            case .games: return 1
            case .social: return 2
            case .search: return 1
            }
        }
        
        var body: some View {
            
            Polygon()
                .foregroundColor(.blue)
                .opacity(colorScheme == .light ? 0.4 : 0.2)
                .rotationEffect(Angle(radians: rotPath[getI()]), anchor: .center)
                .frame(width: sizePath[getI()].width, height: sizePath[getI()].height)
                .offset(x: posPath[getI()].x, y: posPath[getI()].y)
                .animation(.easeOut(duration: 0.25), value: page)
        }
    }
    
    struct Polygon: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            let width = rect.width
            let height = rect.height
            
            path.move(to: .init(x: rect.maxX, y: rect.minY + (height / 4)))
            path.addLine(to: .init(x: rect.maxX + (width / 2), y: rect.maxY))
            path.addLine(to: .init(x: rect.maxX, y: rect.maxY + (height / 4)))
            path.addLine(to: .init(x: rect.minX, y: rect.maxX))
            path.addLine(to: .init(x: rect.minX + (width / 4), y: rect.minY + (height / 3.5)))
            path.addLine(to: .init(x: rect.maxX, y: rect.minY + (height / 4) ))
                         
            return path
        }
    }
}

struct ProfilePageTitle: View {
    
    let profile: EcheveriaProfile
    let text: String
    let size: CGFloat
    
    var body: some View {
        HStack {
            ResizeableIcon(icon: profile.icon, size: size)
            UniversalText(text, size: size, true)
            Spacer()
        }
    }
}

