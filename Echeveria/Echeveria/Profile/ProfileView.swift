//
//  ProfileView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/17/23.
//

import Foundation
import SwiftUI
import RealmSwift

//MARK: ProfileMainView
struct ProfileMainView: View {
    
    @ObservedObject var profile: EcheveriaProfile
    @State var editing: Bool = false
    
    let geo: GeometryProxy
    
    var mainUser: Bool { profile.ownerID == EcheveriaModel.shared.profile.ownerID }
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.vertical) {
                UniversalText("\(profile.firstName) \(profile.lastName)", size: 20)
                UniversalText(profile.ownerID, size: 25, true)
                    .padding(.bottom)
                
                if mainUser {
                    RoundedButton(label: "Edit", icon: "pencil.line") { editing = true }
                }
            }
            Spacer()
        }
        .frame(width: geo.size.width)
        .sheet(isPresented: $editing) { EditingProfileView().environmentObject(profile) }
    }
    
}

//MARK: ProfileGameView
struct ProfileGameView: View {
    
    @ObservedObject var profile: EcheveriaProfile
    @State var logging: Bool = false
    
    let geo: GeometryProxy
    var mainUser: Bool { profile.ownerID == EcheveriaModel.shared.profile.ownerID }
    
    var body: some View {
        
        VStack(alignment: .leading) {
            ScrollView(.vertical) {

                if mainUser {
                    RoundedButton(label: "Log Game", icon: "signpost.and.arrowtriangle.up") { logging = true }
                }
                
                GameScrollerView(geo: geo, games: EcheveriaModel.retrieveObject { game in game.ownerID == profile.ownerID} )
            }
            Spacer()
        }
        .sheet(isPresented: $logging) { GameLoggerView() }
        .universalBackground()
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
    
    var body: some View {
        VStack {
            LabeledHeader(icon: "pencil.line", title: "Edit Profile")
            
            Form {
                Section("Basic Information") {
                    TextField( "First Name", text: $firstName )
                    TextField( "Last Name", text: $lastName )
                    TextField( "User Name", text: $userName )
                    TextField( "Icon", text: $icon )
                }.universalFormSection()
            }
            .universalForm()
            .onAppear {
                firstName = profile.firstName
                lastName = profile.lastName
                userName = profile.userName
                icon = profile.icon
            }
            RoundedButton(label: "Done", icon: "checkmark.seal") {
                profile.updateInformation(firstName: firstName, lastName: lastName, userName: userName, icon: icon)
                presentationMode.wrappedValue.dismiss()
            }
            RoundedButton(label: "Signout", icon: "shippingbox.and.arrow.backward") {
                EcheveriaModel.shared.realmManager.logoutUser()
            }
            
        }.universalBackground()
    }
}
