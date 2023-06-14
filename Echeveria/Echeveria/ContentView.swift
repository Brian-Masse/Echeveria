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
    @ObservedObject var app: RealmSwift.App = echeveriaModel.app
    
    var body: some View {
        
        if !model.signedIn {
            LoginView(loginModel: loginModel)
        
        } else if !model.realmLoaded {
            OpenFlexibleSyncRealmView()
                .environment(\.realmConfiguration, echeveriaModel.configuration)
        } else {
            
            TestStruct()
                .environment(\.realmConfiguration, echeveriaModel.configuration)
        }
    }
}

struct TestStruct: View {
    
    @ObservedResults(TestObject.self) var objs
    
    var body: some View {
        VStack {
            Text("Hello World!")
                .task {
//                    let object = TestObject(firstName: "Brian", lastName: "Masse", ownerID: echeveriaModel.user!.id)
//                    echeveriaModel.writeObject( object )
                }
            
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
                .task { await echeveriaModel.authRealm(realm: realm) }
        
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
