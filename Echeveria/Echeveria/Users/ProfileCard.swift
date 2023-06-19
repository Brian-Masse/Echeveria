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
    
    init( profileID: String ) {
        self.profile = EcheveriaModel.retrieveObject(where: { query in
            query.ownerID == profileID
        }).first!
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(profile.userName).font(UIUniversals.font(20))
            HStack {
                Text(profile.firstName)
                Text(profile.lastName)
                Spacer()
            }
            Text(profile.ownerID)
            
        }
        .padding()
        .background(Rectangle()
            .foregroundColor(.white)
            .cornerRadius(15)
        )
    }
    
}
