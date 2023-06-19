//
//  ProfileView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/17/23.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var profile: EcheveriaProfile
    @State var editing: Bool = false
    
    var mainUser: Bool { profile.ownerID == EcheveriaModel.shared.profile.ownerID }
    
    var body: some View {
        

        VStack(alignment: .leading) {
            
            LabeledHeader(icon: "person.crop.square", title: "Profile")
            
            if mainUser {
                RoundedButton(label: "Edit", icon: "pencil.line") { editing = true }
            }
            
            HStack {
                Image(systemName: "globe.americas")
                    .resizable()
                    .frame(width: 60, height: 60)
                Text(profile.userName).font(UIUniversals.font(45))
            }
            
            HStack {
                Text(profile.firstName).font(UIUniversals.font(20))
                Text(profile.lastName).font(UIUniversals.font(20))
            }
            
            Text(profile.ownerID)
            .padding(.bottom)
            
            Text("Number of Cards: ").bold(true).font(.custom("Helvetica", size: 15))
            Text("\( profile.getNumCards() )")
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $editing) { EditingProfileView().environmentObject(profile) }
    }
    
    struct EditingProfileView: View {
        
        @Environment(\.presentationMode) var presentationMode
        @Environment(\.colorScheme) var colorScheme
        
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
                    }
                }
                .scrollContentBackground(.hidden)
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
            .padding()
            .background(colorScheme == .light ? Colors.lightGrey : .black)
        }
    }
}
