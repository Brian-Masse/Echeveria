//
//  ProfileView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/17/23.
//

import Foundation
import SwiftUI
import RealmSwift
import Realm
import Charts

//MARK: ProfileMainView
struct ProfileMainView: View {
    
    @ObservedObject var profile: EcheveriaProfile
    @State var editing: Bool = false
    
    let allGames: Results<EcheveriaGame>
    let geo: GeometryProxy
    
    var mainUser: Bool { profile.ownerID == EcheveriaModel.shared.profile.ownerID }
    
    var body: some View {
        VStack(alignment: .leading) {
        
            ProfilePageTitle(profile: profile, text: "\(profile.firstName) \(profile.lastName)", size: Constants.UITitleTextSize)

            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    UniversalText("\(profile.userName)", size: Constants.UISubHeaderTextSize, true)
                        .padding(.bottom)

                    if mainUser { FriendRequestView(profile: profile, geo: geo)
                    } else { FriendButtonView(profile: profile) }
                    
                    if profile.friends.count != 0 {
                        UniversalText("Friends", size: Constants.UIHeaderTextSize, true)
                        ListView(title: "", collection: profile.friends, geo: geo) { _ in true } contentBuilder: { friendID in
                            ProfilePreviewView(profileID: friendID)
                        }
                    }
                    
                    if profile.favoriteGroups.count != 0 {
                        UniversalText("Favorite Groups", size: Constants.UIHeaderTextSize, true)
                        ListView(title: "", collection: profile.favoriteGroups, geo: geo) { _ in true } contentBuilder: { groupID in
                            if let group = EcheveriaGroup.getGroupObject(from: groupID) {
                                GroupPreviewView(group: group, geo: geo)
                            }
                        }
                    }
                    
                    RecentGamesView(games: Array(allGames), geo: geo)
                        .padding(.bottom)
                }
                Spacer()
                
                if mainUser {
                    VStack {
                        RoundedButton(label: "Edit", icon: "pencil.line") { editing = true }
                        RoundedButton(label: "Signout", icon: "shippingbox.and.arrow.backward") { EcheveriaModel.shared.realmManager.logoutUser() }
                        UniversalText("id: \(profile.ownerID)", size: Constants.UIDefaultTextSize, lighter: true)
                            .padding(.horizontal, 5)
                    }
                    .padding(.bottom, 90)
                }
            }
        }
        .sheet(isPresented: $editing) { EditingProfileView().environmentObject(profile) }
    }
    
    struct FriendButtonView: View {
        
        @ObservedObject var profile: EcheveriaProfile
        
        @State var requested: Bool = false
        
        var body: some View {
            let mainProfile = EcheveriaModel.shared.profile!
            if !mainProfile.checkFriend(profile.ownerID)  {

                let title: String = ( profile.hasBeenRequested(by: mainProfile.ownerID) || requested ) ? "Requested" : "Add Friend"
                let icon: String = ( profile.hasBeenRequested(by: mainProfile.ownerID) || requested ) ? "checkmark" : "person.badge.plus"

                RoundedButton(label: title, icon: icon) {
                    EcheveriaModel.shared.profile.requestFriend( profile )
                    requested = true
                }
                
            } else {
                RoundedButton(label: "Unfriend", icon: "person.badge.minus") {
                    EcheveriaModel.shared.profile.removeFriend( profile.ownerID )
                }
            }
        }
    }
    
    struct FriendRequestView: View {
        
        @ObservedObject var profile: EcheveriaProfile
        let geo: GeometryProxy
        
        var body: some View {
            if profile.friendRequests.count != 0 {
                VStack(alignment: .leading) {
                    UniversalText("Friend Requests", size: Constants.UIHeaderTextSize, true)
                    
                    let requests = Array( profile.friendRequests as RealmSwift.List<String> )
                    
                    ListView(title: "", collection: requests.indices, geo: geo) { i in true} contentBuilder: { i in
                    
                        VStack(alignment: .leading) {
                            ZStack(alignment: .topTrailing) {
                                ProfilePreviewView(profileID:  requests[i] )
                                ShortRoundedButton("accept", icon: "checkmark") {
                                    profile.acceptFriend(requests[i], index: i)
                                }
                                .padding()
                            }
                            
                            let date = profile.friendRequestDates[i].formatted(date: .numeric, time: .omitted)
                            UniversalText( "Requested on \( date )", size: Constants.UIDefaultTextSize, lighter: true, true )
                                .padding(.leading)
                        }
                    }
                }.padding(.bottom)
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
    
    var body: some View {
        VStack {
            
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
