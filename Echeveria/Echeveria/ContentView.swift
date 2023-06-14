//
//  ContentView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/13/23.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    
    @ObservedObject var model: EcheveriaModel
    
    var body: some View {
        
        if !model.signedIn {
            LoginView(loginModel: loginModel)
        
        } else if !model.realmLoaded {
            OpenFlexibleSyncRealmView()
                .environment(\.realmConfiguration, echeveriaModel.configuration)
        } else {
            
            TestStruct()
                .environment(\.realmConfiguration, echeveriaModel.configuration)
            
            Text("Hello World!")
                .task {
//                    let object = TestObject(firstName: "Brian", lastName: "Masse", ownerID: model.user!.id)
//                    model.writeObject( object )
                }
        
        }
    }
}

struct TestStruct: View {
    
    @ObservedResults(TestObject.self) var objs
    
    var body: some View {
        ForEach( objs, id: \._id ) { obj in
            HStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text( obj.firstName )
                    .onTapGesture {
                        obj.updateName(to: "Broan")
                    }
            }
        }
    }
}

struct OpenFlexibleSyncRealmView: View {
    
    @AsyncOpen(appId: "application-0-qufwt", timeout: 4000) var asyncOpen
    
    
    var body: some View {
        
        switch asyncOpen {
            
        case .connecting:
            VStack {
                NamedButton(text: "Connecting to Realm", icon: "externaldrive.connected.to.line.below")
                ProgressView()
            }
        case .waitingForUser:
            Text("Failed to Login")
            
        case .open(let realm):
            NamedButton(text: "Success!", icon: "checkmark.circle")
                .task {
                    echeveriaModel.authRealm(realm: realm)
                }
        
        case .progress(let progress):
            VStack {
                NamedButton(text: "Downloading Realm from Server", icon: "server.rack")
                ProgressView(progress)
            }
        
        case .error(let error):
            NamedButton(text: "Error Connecting to Realm: \(error)", icon: "xmark.seal")
            
        }
        
    }
    
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        signupForm()
//    }
//}
