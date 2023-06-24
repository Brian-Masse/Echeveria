//
//  GroupView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/18/23.
//

import Foundation
import SwiftUI
import RealmSwift

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
    
    let group: EcheveriaGroup?
    
    @State var name: String
    @State var icon: String
    @State var description: String
    @State var colorIndex: Int
    
    let editing: Bool
    
    var body: some View {
        
        VStack {
            Form {
                Section("Basic Information") {
                    TextField("Group Name", text: $name)
                    TextField("Group Description", text: $description)
                    TextField("Icon", text: $icon)
                    
                    Picker(selection: $colorIndex) {
                        ForEach(Colors.colorOptions.indices, id: \.self) { i in
                            Text( Colors.colorOptions[i].description ).tag( i )
                        }
                    } label: {
                        Text("Group Color")
                    }

                    
                }.universalFormSection()
            }.universalForm()
            
            RoundedButton(label: "Submit", icon: "checkmark.seal") {
                if !editing {
                    let group = EcheveriaGroup(name: name, icon: icon, description: description, colorIndex: colorIndex)
                    group.addToRealm()
                }else {
                    group!.updateInformation(name: name, icon: icon, description: description, colorIndex: colorIndex)
                }
                presentaitonMode.wrappedValue.dismiss()
            }
        }
        .universalBackground()
    }
}
