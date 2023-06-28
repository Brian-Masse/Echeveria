//
//  ProfileCard.swift
//  Echeveria
//
//  Created by Brian Masse on 6/18/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct ProfilePreviewView: View {

    let profile: EcheveriaProfile
    
    @State var showingProfile: Bool = false
    @State var page: MainView.ProfilePage = .main
    
    init( profileID: String ) {
        self.profile = EcheveriaModel.retrieveObject(where: { query in
            query.ownerID == profileID
        }).first!
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            UniversalText(profile.userName, size: 20, true)
            HStack {
                Text(profile.firstName)
                Text(profile.lastName)
                Spacer()
            }
            Text(profile.ownerID)
            
        }
        
        .fullScreenCover(isPresented: $showingProfile) { ProfilePageView(profile: profile, page: $page) }
        .opaqueRectangularBackground()
        .onTapGesture { showingProfile = true }
        
    }
}

struct ReducedProfilePreviewView: View {

    let profile: EcheveriaProfile
    @State var page: MainView.ProfilePage = .main
    
    init( profileID: String ) {
        self.profile = EcheveriaModel.retrieveObject(where: { query in
            query.ownerID == profileID
        }).first!
    }
    
    @State var presenting: Bool = false
    
    var body: some View {
        
        HStack {
            ResizeableIcon(icon: profile.icon, size: Constants.UISubHeaderTextSize)
            UniversalText( "\(profile.firstName) \(profile.lastName)", size: Constants.UISubHeaderTextSize, true )
            Spacer()
            UniversalText( "\(profile.userName)", size: Constants.UIDefaultTextSize )
        }
        .opaqueRectangularBackground()
        .fullScreenCover(isPresented: $presenting) { ProfilePageView(profile: profile, page: $page) }
        .onTapGesture { presenting = true }
        
            
    }
    
}
