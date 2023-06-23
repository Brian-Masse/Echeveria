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
    let geo: GeometryProxy
    let query: (EcheveriaGroup) -> Bool
    
    var body: some View {
        
        let filtered = groups.filter { group in
            query(group)
        }
        
        VStack {
            if !filtered.isEmpty {
                HStack {
                    UniversalText(title, size: Constants.UISubHeaderTextSize, true)
                    Spacer()
                }
                ForEach(filtered, id: \._id) { group in
                    GroupPreviewView(group: group, geo: geo)
                }
            }
        }
    }
}

struct GroupPreviewView: View {
    
    @ObservedRealmObject var group: EcheveriaGroup
    let geo: GeometryProxy
    
    @State var showingGroup: Bool = false
    
    let memberID = EcheveriaModel.shared.profile!.ownerID
    var owner: Bool { group.owner == memberID }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                ResizeableIcon(icon: group.icon, size: Constants.UISubHeaderTextSize)
                UniversalText(group.name, size: Constants.UISubHeaderTextSize, true )
                Spacer()
                
                if owner  { UniversalText("owner", size: Constants.UIDefaultTextSize ).padding(.trailing) }
            }
            
            UniversalText( group.groupDescription, size: Constants.UIDefaultTextSize )
                .frame(width: geo.size.width - 20)
                .lineLimit(5)
            
        
            if !owner {
                if !group.hasMember(memberID) {
                    RoundedButton(label: "join", icon: "plus.square") {
                        group.addMember(memberID)
                    }
                } else {
                    RoundedButton(label: "leave", icon: "shippingbox.and.arrow.backward") {
                        group.removeMember(memberID)
                    }
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
    @State var description: String = ""
    
    var body: some View {
        
        VStack {
            Form {
                Section("Basic Information") {
                    TextField("Group Name", text: $name)
                    TextField("Group Description", text: $description)
                    TextField("Icon", text: $icon)
                }.universalFormSection()
            }.universalForm()
            
            RoundedButton(label: "Submit", icon: "checkmark.seal") {
                let group = EcheveriaGroup(name: name, icon: icon, description: description)
                group.addToRealm()
                presentaitonMode.wrappedValue.dismiss()
            }
        }
        .universalBackground()
    }
}
