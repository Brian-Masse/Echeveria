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
    
    //MARK: EditingProfileView
    struct EditingProfileView: View {
        
        @Environment(\.presentationMode) var presentationMode
        
        @EnvironmentObject var profile: EcheveriaProfile
        
        @State var firstName: String = ""
        @State var lastName: String = ""
        @State var userName: String = ""
        @State var icon: String = ""
        @State var color: Color = .red
        
        @State var showingPicker: Bool = false
        
        var body: some View {
            VStack {
                
                Form {
                    Section("Basic Information") {
                        TextField( "First Name", text: $firstName )
                        TextField( "Last Name", text: $lastName )
                        TextField( "User Name", text: $userName )
                    }.universalFormSection()
                    
                    Section("Personalization") {
                        HStack {
                            UniversalText("\(icon)", size: Constants.UIDefaultTextSize)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .onTapGesture { showingPicker = true }
                        .sheet(isPresented: $showingPicker) { SymbolPicker(symbol: $icon) }
                        
                        ColorPicker(selection: $color, supportsOpacity: false) {
                            Text("Accent Color")
                        }
                    }
                }
                .universalForm()
                .onAppear {
                    firstName = profile.firstName
                    lastName = profile.lastName
                    userName = profile.userName
                    icon = profile.icon
                }
                RoundedButton(label: "Done", icon: "checkmark.seal") {
                    profile.updateInformation(firstName: firstName, lastName: lastName, userName: userName, icon: icon, color: color)
                    presentationMode.wrappedValue.dismiss()
                }
                
            }.universalBackground()
        }
    }

}
