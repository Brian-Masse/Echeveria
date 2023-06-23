//
//  ProfileCard.swift
//  Echeveria
//
//  Created by Brian Masse on 6/18/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct ProfileCard: View {

    let profile: EcheveriaProfile
    
    @State var showingProfile: Bool = false
    
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
        .padding()
        .fullScreenCover(isPresented: $showingProfile) {
            ProfilePageView(profile: profile)
            
        }
        .background(Rectangle()
            .universalForeground()
            .cornerRadius(15)
            .onTapGesture { showingProfile = true }
        )
    }
    
}
