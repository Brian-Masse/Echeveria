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
