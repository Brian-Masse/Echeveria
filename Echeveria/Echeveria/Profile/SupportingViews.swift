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
        
        @State var firstName: String = ""
        @State var lastName: String = ""
        @State var userName: String = ""
        @State var icon: String = ""
        @State var color: Color = .red
        
        @State var activePreferences: EcheveriaGame.GameType = .smash
        @State var preferences: Dictionary<String, String>
        
        @State var showingPicker: Bool = false
        
        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        
                        UniversalText("Edit Profile", size: Constants.UITitleTextSize, true)
                            .padding(.bottom)
                        
                        TransparentForm("Basic Information") {
                            TextField( "First Name", text: $firstName )
                            TextField( "Last Name", text: $lastName )
                            TextField( "User Name", text: $userName )
                        }
                        
                        TransparentForm("Personalization") {
                            HStack {
                                UniversalText("\(icon)", size: Constants.UIDefaultTextSize)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .onTapGesture { showingPicker = true }
                            .sheet(isPresented: $showingPicker) { SymbolPicker(symbol: $icon) }
                            
                            UniqueColorPicker(selectedColor: $color)
                        }
                        .onAppear {
                            firstName = profile.firstName
                            lastName = profile.lastName
                            userName = profile.userName
                            icon = profile.icon
                        }
                        
                        
                        HStack {
                            UniversalText("Preferences", size: Constants.UIHeaderTextSize, true)
                            Spacer()
                            
                            Picker("Game", selection: $activePreferences) {
                                ForEach(EcheveriaGame.GameType.allCases, id: \.self) { content in
                                    Text( content.rawValue )
                                }
                            }.tint(Colors.tint)
                        }
                        
                        switch activePreferences {
                        case .smash:   Smash.PreferencesForm(preferences: $preferences)
                        case .magic:   Magic.PreferencesForm(preferences: $preferences)
                        default: EmptyView()
                        }
                        
                        Spacer()
                    }
                    
                    RoundedButton(label: "Done", icon: "checkmark.seal") {
                        profile.updateInformation(firstName: firstName,
                                                  lastName: lastName,
                                                  userName: userName,
                                                  icon: icon,
                                                  color: color,
                                                  preferences: preferences
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding()
                    .shadow(radius: 5)
                    .padding(.bottom, 20)
                }
                .frame(height: geo.size.height)
            }
            .padding()
            .universalColoredBackground(Colors.tint)
        }
    }
}
