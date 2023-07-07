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
    
    var isFavorite: Bool { EcheveriaModel.shared.profile.favoriteGroups.contains(where: { str in str == group._id.stringValue }) }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack {
                ResizeableIcon(icon: group.icon, size: Constants.UISubHeaderTextSize)
                UniversalText(group.name, size: Constants.UISubHeaderTextSize, wrap: false, true )
                Spacer()
                
                
                ShortRoundedButton("Favorite", to: "", icon: "seal", to: "checkmark.seal") { isFavorite } action: {
                    if isFavorite   { withAnimation { EcheveriaModel.shared.profile.unfavoriteGroup(group) }}
                    else            { withAnimation { EcheveriaModel.shared.profile.favoriteGroup(group) }}
                }
            }
            
            if owner  { UniversalText("owner", size: Constants.UIDefaultTextSize ) }
            
            UniversalText( group.groupDescription, size: Constants.UIDefaultTextSize, wrap: true, lighter: true )
            
        
            if !owner {
                if !group.hasMember(memberID) {
                    RoundedButton(label: "join", icon: "plus.square") {
                        group.addMember(memberID)
                    }
                } else {
                    AsyncRoundedButton(label: "leave", icon: "shippingbox.and.arrow.backward") {
                        group.removeMember(memberID)
                        if let profile = EcheveriaProfile.getProfileObject(from: memberID) {
                            await profile.refreshGamePermissions(id: memberID, groups: Array( profile.groups ))
                        }
                    }
                }
            }
        }
        .padding()
        .background(Rectangle()
            .cornerRadius(15)
            .universalForeground()
            .onTapGesture { showingGroup = true }
            .fullScreenCover(isPresented: $showingGroup) { GroupView(group: group, games: EcheveriaModel.retrieveObject { game in game.groupID == group._id } ) }
        )
    }
}

struct GroupCreationView: View {
    
    @Environment(\.presentationMode) var presentaitonMode
    
    let title: String
    
    let group: EcheveriaGroup?
    
    @State var name: String
    @State var icon: String
    @State var description: String
    @State var color: Color
    
    let editing: Bool
    @State var showingAlert: Bool = false
    
    private func submit() {
        
        if name.strip().isEmpty || icon.strip().isEmpty { showingAlert = true; return }
        
        if !editing {
            let group = EcheveriaGroup(name: name, icon: icon, description: description, color: color)
            group.addToRealm()
        } else { group!.updateInformation(name: name, icon: icon, description: description, color: color) }
        presentaitonMode.wrappedValue.dismiss()
    }
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    UniversalText(title, size: Constants.UITitleTextSize, true)
                        .padding(.bottom)
                    
                    ScrollView(.vertical) {
                        
                        VStack(alignment: .leading) {
                            TransparentForm("Basic Info") {
                                TextField("Group Name", text: $name)
                                TextField("Group Description", text: $description)
                            }
                            
                            TransparentForm("Preferences") {
                                IconPicker(icon: $icon)
                                UniqueColorPicker(selectedColor: $color)
                            }
                            .padding(.bottom, Constants.UIHoverButtonBottonPadding * 4)
                            
                            Spacer()
                        }
                    }
                }
                
                RoundedButton(label: "Submit", icon: "checkmark.seal") { submit() }
                    .padding()
                    .shadow(radius: 5)
                    .padding(.bottom, Constants.UIHoverButtonBottonPadding)
            }
            .frame(height: geo.size.height)
        }
        .padding()
        .universalColoredBackground( color )
        .alert(isPresented: $showingAlert) {
            Alert(title: Text( "Form Incomplete" ).bold(true), message: Text( "Double check you have provided a group name and icon" ))
        }

    }
}
