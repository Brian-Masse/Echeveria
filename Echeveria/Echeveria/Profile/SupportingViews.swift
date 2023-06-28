//
//  File.swift
//  Echeveria
//
//  Created by Brian Masse on 6/28/23.
//

import Foundation
import SwiftUI
import RealmSwift

//MARK: ProfileViews
struct ProfileViews {

    
    //MARK: FriendView
    struct FriendView: View {
        
        let profile: EcheveriaProfile
        let geo: GeometryProxy
        
        var body: some View {
            VStack(alignment: .leading) {
                UniversalText("Friends", size: Constants.UIHeaderTextSize, true)
                if profile.friends.count != 0 {
                    ListView(title: "", collection: profile.friends, geo: geo) { _ in true } contentBuilder: { friendID in
                        ProfilePreviewView(profileID: friendID)
                    }
                }else {
                    LargeFormRoundedButton(label: "Add Friends", icon: "plus") { }
                }
            }
        }
    }    
}
