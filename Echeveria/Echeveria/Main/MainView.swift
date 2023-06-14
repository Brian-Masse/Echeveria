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
    
    var body: some View {
        VStack {
            
            CardView.Button(label: "Add", icon: "plus.circle") {
                let object = TestObject(firstName: "Brian", lastName: "Masse",
                                        ownerID: EcheveriaModel.shared.realmManager.user!.id)
                EcheveriaModel.addObject( object )
            }
            
            ScrollView(.vertical) {
                ForEach( objs, id: \._id ) { obj in
                    CardView(item: obj)
                }
            }
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
                Button(label: "Delete", icon: "delete.backward", action: {
                    print(item)
                    EcheveriaModel.deleteObject(item)
                })
                Button(label: "Edit", icon: "pencil.circle", action: { item.updateName(to: "Updated!") })
            }
            .padding([.horizontal, .bottom])
        }
    
        .background(
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(20)
        )
    }
    
    struct Button: View {
        
        let label:  String
        let icon:   String
        let action: ()->Void
        
        var body: some View {
            HStack {
                Spacer()
                Image(systemName: icon)
                Text(label)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
            .onTapGesture { action() }
            .background(
                Rectangle()
                    .foregroundColor(.blue)
                    .cornerRadius(50)
            )
        }
    }
}
