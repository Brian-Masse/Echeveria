//
//  ContentView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/13/23.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var model: Model
    
    var body: some View {
        
        if !model.signedIn {
            LoginView(loginModel: loginModel)
        } else {
            
            Text("Hello World!")
                .task {
                    let object = TestObject(firstName: "Brian", lastName: "Masse", ownerID: model.user!.id)
                    model.writeObject( object )
                }
        
            ForEach( model.objects, id: \._id ) { obj in
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


//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        signupForm()
//    }
//}
