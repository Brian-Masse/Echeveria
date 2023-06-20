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
    let games: Results<EcheveriaGame>
    
    @State var loadingPermissions: Bool = true
    @State var editing: Bool = false
    
    var owner: Bool { group.owner == EcheveriaModel.shared.profile.ownerID }
    
    var body: some View {
        
        GeometryReader { geo in
            VStack(alignment: .leading) {
                if owner {
                    RoundedButton(label: "Edit Group", icon: "pencil.line") { editing = true }
                }
                
                HStack {
                    Image(systemName: group.icon)
                    UniversalText(group.name, size: 30, true)
                    Spacer()
                }
                .padding(.bottom)
                
                ScrollView(.vertical) {
                    if !loadingPermissions {
                        UniversalText("Members:", size: 20, true)
                        ForEach( group.members, id: \.self ) { memberID in
                            ProfileCard(profileID: memberID)
                        }
                        
                        GameScrollerView(geo: geo, games: games)
                            
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
        .universalBackground()
        .sheet(isPresented: $editing) { EditingGroupView(group: group, name: group.name, icon: group.icon) }
    }
    
    
    struct EditingGroupView: View {
        
        @Environment(\.presentationMode) var presentationMode
        
        let group: EcheveriaGroup
        
        @State var name: String
        @State var icon: String
        
        var body: some View {
            VStack {
                Form {
                    Section("Basic Information") {
                        TextField("Group Name", text: $name)
                        TextField("Group Icon", text: $icon)
                    }
                }
                .scrollContentBackground(.hidden)
                
                RoundedButton(label: "Done", icon: "checkmark.seal") {
                    group.updateInformation(name: name, icon: icon)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .universalBackground()
        }
            
    }

}