//
//  File.swift
//  Echeveria
//
//  Created by Brian Masse on 6/28/23.
//

import Foundation
import SwiftUI
import RealmSwift
import SymbolPicker

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
    
//    MARK: DismissView {
    struct DismissView: View {
        
        @Environment(\.presentationMode) var presentationMode
        let preAction: () async -> Void
        let action: () async -> Void
        
        
        var body: some View {
            if presentationMode.wrappedValue.isPresented {
                asyncShortRoundedButton(label: "dismiss", icon: "chevron.down") {
                    await preAction()
                    presentationMode.wrappedValue.dismiss()
                    await action()
                }
                .padding(.horizontal, 5)
            }
        }
    }
    
    //MARK: EditingProfileView
    struct EditingProfileView: View {
        
        @Environment(\.presentationMode) var presentationMode
        
        @EnvironmentObject var profile: EcheveriaProfile
        @ObservedObject var model = EcheveriaModel.shared
        
        @State var creatingProfile: Bool
        
        @State var firstName: String
        @State var lastName: String
        @State var userName: String
        @State var icon: String
        @State var color: Color
        
        @State var activePreferences: EcheveriaGame.GameType = .smash
        @State var preferences: Dictionary<String, String>
        
        @State var showingPicker: Bool = false
        
        private func submit() async {
            if creatingProfile {
                //TODO: need to checks that all fields are filled in and that they are a minimum length
                let profile = EcheveriaProfile(ownerID: "", firstName: firstName, lastName: lastName, userName: userName, icon: icon, color: .blue)
                await EcheveriaModel.shared.realmManager.addProfile(profile: profile)
            }else {
                profile.updateInformation(firstName: firstName,
                                          lastName: lastName,
                                          userName: userName,
                                          icon: icon,
                                          color: color,
                                          preferences: preferences
                )
                presentationMode.wrappedValue.dismiss()
            }
        }
        
        
        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    ScrollView(.vertical) {
                        VStack(alignment: .leading) {
                            
                            let title = creatingProfile ? "Create Profile" : "Edit Profile"
                            
                            UniversalText(title, size: Constants.UITitleTextSize, true)
                                .padding(.bottom)
                            
                            TransparentForm("Basic Information") {
                                TextField( "First Name", text: $firstName )
                                TextField( "Last Name", text: $lastName )
                                TextField( "User Name", text: $userName )
                            }
                            
                            TransparentForm("Personalization") {
                                IconPicker(icon: $icon)
                                UniqueColorPicker(selectedColor: $color)
                            }
                            
                            if !creatingProfile {
                                HStack {
                                    UniversalText("Preferences", size: Constants.UIHeaderTextSize, true)
                                    Spacer()
                                    
                                    BasicPicker(title: "", noSeletion: "No Selecton", sources: EcheveriaGame.GameType.allCases, selection: $activePreferences) { content in
                                        Text( content.rawValue )
                                    }
                                }
                                
                                VStack {
                                    switch activePreferences {
                                    case .smash:   Smash.PreferencesForm(preferences: $preferences)
                                    case .magic:   Magic.PreferencesForm(preferences: $preferences)
                                    default: LargeFormRoundedButton(label: "No preferences for this game", icon: "camera.metering.unknown", action: {})
                                    }
                                }
                                .padding(.bottom, 80)
                                Spacer()
                            }
                        }
                    }
                    
                    AsyncRoundedButton(label: "Done", icon: "checkmark.seal") { await submit() }
                        .padding()
                        .shadow(radius: 5)
                }
                .frame(height: geo.size.height)
            }
            .padding()
            .universalColoredBackground( color )
        }
    }
}
