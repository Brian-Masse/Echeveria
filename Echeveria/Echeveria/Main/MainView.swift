//
//  OpenFlexibleSyncRealmView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import SwiftUI
import RealmSwift


struct MainView: View {
    
    @ObservedResults(TestObject.self) var objs
    
    @State var presentingProfile: Bool = false
    
    var body: some View {
        VStack {
            
            RoundedButton(label: "Profile", icon: "person.crop.square") { presentingProfile = true }
            
            RoundedButton(label: "Add", icon: "plus.circle") {
                let object = TestObject(firstName: "Brian", lastName: "Masse",
                                        ownerID: EcheveriaModel.shared.realmManager.user!.id)
                EcheveriaModel.addObject( object )
            }
            RoundedButton(label: "Signout", icon: "shippingbox.and.arrow.backward") {
                EcheveriaModel.shared.realmManager.logoutUser()
            }
            
            ScrollView(.vertical) {
                ForEach( objs, id: \._id ) { obj in
                    CardView(item: obj)
                }
            }
        }
        .padding()
        .background(Colors.lightGrey)
        .sheet(isPresented: $presentingProfile) { ProfileView(profile: EcheveriaModel.shared.profile) }
    }
}

struct CardView: View {
    
    @ObservedRealmObject var item: TestObject
    
    var body: some View {
        
        VStack {
            VStack {
                HStack {
                    Image(systemName: "globe")
                    Text(item.firstName)
                    Text(item.lastName)
                    Spacer()
                }.bold(true)
                
                HStack {
                    Text(item.ownerID)
                    Spacer()
                }
            }.padding()
            
            HStack {
                RoundedButton(label: "Delete", icon: "delete.backward", action: {
                    print(item)
                    EcheveriaModel.deleteObject(item)
                })
                RoundedButton(label: "Edit", icon: "pencil.circle", action: { item.updateName(to: "Updated!") })
            }
            .padding([.horizontal, .bottom])
        }
    
        .background(
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(20)
        )
    }
}
