//
//  GroupView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/18/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct GroupView: View {
    
    @ObservedRealmObject var group: EcheveriaGroup
    @State var loadingPermissions: Bool = true
    
    var body: some View {
        
        ZStack {
            VStack(alignment: .leading) {
                
                HStack {
                    Image(systemName: group.icon)
                    Text(group.name)
                    Spacer()
                }
                .font(UIUniversals.font(30))
                .padding(.bottom)
                
                if !loadingPermissions {
                    Text("Members:").font(UIUniversals.font(20))
                    ForEach( group.members, id: \.self ) { memberID in
                        ProfileCard(profileID: memberID)
                    }
                }
                Spacer()
            }
//        TODO: while the group is giving local users access to view other users profiles, show a loading view
//        TODO: also probably shouldnt be giving local users read/write access to other users profiles!
            AsyncLoader {
                await group.provideLocalUserAccess()
                loadingPermissions = false
            } closingTask: {
                await group.disallowLocalUserAccess()
            }
        }
        .padding()
        .background(Colors.lightGrey)
    }
}
