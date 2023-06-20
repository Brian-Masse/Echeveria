//
//  ProfileView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/17/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct ProfileView: View {
    @ObservedObject var profile: EcheveriaProfile
    
    @State var editing: Bool = false
    @State var logging: Bool = false
    @State var loadingPersmissions: Bool = true
    
    
    var mainUser: Bool { profile.ownerID == EcheveriaModel.shared.profile.ownerID }
    
    var body: some View {
        GeometryReader { geo in
            if !loadingPersmissions {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: profile.icon)
                            .resizable()
                            .frame(width: 60, height: 60)
                        UniversalText(profile.userName, size: 45, true)
                    }
                    
                    ScrollView(.vertical) {
                        VStack(alignment: .leading) {
                            UniversalText("\(profile.firstName) \(profile.lastName)", size: 20)
                            UniversalText(profile.ownerID, size: 25, true)
                                .padding(.bottom)
                            
                            if mainUser {
                                RoundedButton(label: "Edit", icon: "pencil.line") { editing = true }
                                RoundedButton(label: "Log Game", icon: "signpost.and.arrowtriangle.up") { logging = true }
                            }
                            
                            GameScrollerView(geo: geo, games: EcheveriaModel.retrieveObject { game in game.ownerID == profile.ownerID} )
                        }
                    }
                    Spacer()
                }
            }else {
                AsyncLoader {
//                    let ids = [ profile.ownerID, EcheveriaModel.shared.profile.ownerID ]
//                    await profile.provideLocalUserProfileAccess(ids: ids)
                    loadingPersmissions = false
                } closingTask: {
                    await profile.disallowLocalUserProfileAccess()
                }

            }
        }
        .sheet(isPresented: $editing) { EditingProfileView().environmentObject(profile) }
        .sheet(isPresented: $logging) { GameLoggerView() }
        .universalBackground()
    }
    
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
            }.universalBackground()
        }
    }
}