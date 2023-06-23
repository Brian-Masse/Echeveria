//
//  GroupView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/18/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct GroupListView: View {
    let title: String
    
    let groups: [EcheveriaGroup]
    
    var body: some View {
        
        if !groups.isEmpty {
            HStack {
                Text(title).bold(true)
                Spacer()
            }
            ForEach(groups, id: \._id) { group in
                GroupPreviewView(group: group)
            }
        }
    }
}

struct GroupPreviewView: View {
    
    @ObservedRealmObject var group: EcheveriaGroup
    
    @State var showingGroup: Bool = false
    
    let memberID = EcheveriaModel.shared.profile!.ownerID
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: group.icon)
                Text(group.name)
                    .bold(true)
                Spacer()
            }
            if group.owner == memberID  {
                Text("owner")
            }
            else if !group.hasMember(memberID) {
                RoundedButton(label: "join", icon: "plus.square") {
                    group.addMember(memberID)
                }
            } else {
                RoundedButton(label: "leave", icon: "shippingbox.and.arrow.backward") {
                    group.removeMember(memberID)
                }
            }
        }
        .padding(10)
        .background(Rectangle()
            .cornerRadius(15)
            .universalForeground()
            .onTapGesture { showingGroup = true }
            .sheet(isPresented: $showingGroup) { GroupView(group: group, games: EcheveriaModel.retrieveObject { game in game.groupID == group._id } ) }
        )
    }
}

struct GroupCreationView: View {
    
    @Environment(\.presentationMode) var presentaitonMode
    
    @State var name: String = ""
    @State var icon: String = "square.on.square.squareshape.controlhandles"
    
    var body: some View {
        
        VStack {
            Form {
                Section("Basic Information") {
                    TextField("Group Name", text: $name)
                    TextField("Icon", text: $icon)
                }.universalFormSection()
            }.universalForm()
            
            RoundedButton(label: "Submit", icon: "checkmark.seal") {
                let group = EcheveriaGroup(name: name, icon: icon)
                group.addToRealm()
                presentaitonMode.wrappedValue.dismiss()
            }
        }
        .universalBackground()
    }
}
