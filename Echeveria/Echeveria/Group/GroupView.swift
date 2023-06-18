//
//  GroupView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/18/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct GroupPageView: View {
    
    @State var showingGroupCreationView: Bool = false
    
    @ObservedResults(EcheveriaGroup.self) var groups
    
    var body: some View {
        
        VStack {
            RoundedButton(label: "Create Group", icon: "plus.square") { showingGroupCreationView = true }
            
            ForEach(groups, id: \._id) { group in
                GroupView(group: group)
            }
            .padding(.horizontal)
            
        }.sheet(isPresented: $showingGroupCreationView) { GroupCreationView() }
    }
    
}

struct GroupView: View {
    
    @ObservedRealmObject var group: EcheveriaGroup
    
    var body: some View {
        
        HStack {
            Image(systemName: group.icon)
            Text(group.name)
                .bold(true)
            Spacer()
        }
        .padding(10)
        .background(Rectangle()
            .cornerRadius(40)
            .foregroundColor(.white)
        )
    }
}


struct GroupCreationView: View {
    
    @State var name: String = ""
    @State var icon: String = "square.on.square.squareshape.controlhandles"
    
    @Environment(\.presentationMode) var presentaitonMode
    
    var body: some View {
        
        VStack {
            Form {
                Section("Basic Information") {
                    TextField("Group Name", text: $name)
                    TextField("Icon", text: $icon)
                }
            }
            
            RoundedButton(label: "Submit", icon: "checkmark.seal") {
                let group = EcheveriaGroup(name: name, icon: icon)
                group.addToRealm()
                presentaitonMode.wrappedValue.dismiss()
            }
        }
        .padding()
        .background(Colors.lightGrey)
        
    }
    
}
