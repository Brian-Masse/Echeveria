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
    @State var loadingPermissions: Bool = true
    
    @ObservedResults(EcheveriaGame.self, where: { game in game.ownerID == EcheveriaModel.shared.profile.ownerID}) var games
    
    var mainUser: Bool { profile.ownerID == EcheveriaModel.shared.profile.ownerID }
    
    var body: some View {
    
        VStack(alignment: .leading) {
            
            HStack {
                Image(systemName: "globe.americas")
                    .resizable()
                    .frame(width: 60, height: 60)
                Text(profile.userName).font(UIUniversals.font(45))
            }
            
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    HStack {
                        Text(profile.firstName).font(UIUniversals.font(20))
                        Text(profile.lastName).font(UIUniversals.font(20))
                    }
                    Text(profile.ownerID)
                        .padding(.bottom)
                    
                    if mainUser {
                        RoundedButton(label: "Edit", icon: "pencil.line") { editing = true }
                        RoundedButton(label: "Log Game", icon: "signpost.and.arrowtriangle.up") { logging = true }
                    }
                    
                    if !loadingPermissions {
                        Text("Games").font(UIUniversals.font(20))
                        ForEach( games, id: \.self ) { game in
                            GameTrackerCardPreviewView(game: game)
                        }
                    }else {
                        AsyncLoader { await profile.provideLocalUserFullAccess()
                            loadingPermissions = false
                        } closingTask: { await profile.disallowLocalUserFullAccess() }
                    }
                }
            }
            Spacer()
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
        
        var body: some View {
            
            VStack {
                
                LabeledHeader(icon: "pencil.line", title: "Edit Profile")
                
                Form {
                    Section("Basic Information") {
                        TextField( "First Name", text: $firstName )
                        TextField( "Last Name", text: $lastName )
                        TextField( "User Name", text: $userName )
                    }.universalFormSection()
                }
                .universalForm()
                .onAppear {
                    firstName = profile.firstName
                    lastName = profile.lastName
                    userName = profile.userName
                }
                RoundedButton(label: "Done", icon: "checkmark.seal") {
                    profile.updateInformation(firstName: firstName, lastName: lastName, userName: userName)
                    presentationMode.wrappedValue.dismiss()
                }
                
            }
            .universalBackground()
        }
    }
}
