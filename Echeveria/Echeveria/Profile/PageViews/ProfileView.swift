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
    
    let geo: GeometryProxy
    
    var mainUser: Bool { profile.ownerID == EcheveriaModel.shared.profile.ownerID }
    
    var body: some View {
        VStack(alignment: .leading) {
            ProfilePageTitle(profile: profile, text: profile.userName, size: Constants.UITitleTextSize)

            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    UniversalText("\(profile.firstName) \(profile.lastName)", size: 20)
                    UniversalText(profile.ownerID, size: 25, true)
                        .padding(.bottom)

                    if mainUser {
                        FriendRequestView(profile: profile, geo: geo)
                        RoundedButton(label: "Edit", icon: "pencil.line") { editing = true }
                    } else {
                       FriendButtonView(profile: profile)
                    }
                }
            }
            Spacer()
        }
        .frame(width: geo.size.width)
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
                UniversalText("Friend Requests", size: Constants.UIHeaderTextSize, true)
                
                let requests = Array( profile.friendRequests as RealmSwift.List<String> )
                
                ListView(title: "", collection: requests.indices, geo: geo) { i in true}
                contentBuilder: { i in
                    ProfilePreviewView(profileID:  requests[i] )
                    
                    HStack {
                        let date = profile.friendRequestDates[i].formatted(date: .numeric, time: .omitted)
                        
                        UniversalText( "Requested on \( date )", size: Constants.UIDefaultTextSize )
                        Spacer()
                        RoundedButton(label: "Accept", icon: "checkmark") {
                            profile.acceptFriend(requests[i], index: i)
                        }
                        
                    }
                }
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
            RoundedButton(label: "Signout", icon: "shippingbox.and.arrow.backward") {
                EcheveriaModel.shared.realmManager.logoutUser()
            }
            
        }.universalBackground()
    }
}
