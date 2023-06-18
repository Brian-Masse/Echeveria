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
    
    enum MainViewPage {
        case main
        case group
        case profile
    }
    
    @ObservedResults(TestObject.self) var objs
    
    @State var page: MainViewPage = .main
    
    var body: some View {
        
        VStack {
            
            switch page {
            case .profile: ProfileView(profile: EcheveriaModel.shared.profile)
            case .group: GroupPageView()
            case .main:
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
            Spacer()
            HStack {
                NamedButton("Home", and: "house.lodge", oriented: .vertical).onTapGesture { page = .main }
                Spacer()
                NamedButton("Group", and: "rectangle.3.group", oriented: .vertical).onTapGesture { page = .group }
                Spacer()
                NamedButton("Profile", and: "person.crop.square", oriented: .vertical).onTapGesture { page = .profile }
            }.padding([.top, .horizontal])
        }
        .padding()
        .background(Colors.lightGrey)
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
