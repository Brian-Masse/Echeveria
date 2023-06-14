//
//  ContentView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/13/23.
//

import SwiftUI

struct ContentView: View {
    
    var model: Model
    
    @State var email: String = ""
    @State var password: String = ""
    @State var signingin: Bool = false
    
    var body: some View {
        VStack {
            
            
            
            if signingin { SignupForm(email: $email, password: $password) }
            else {
                ProgressView()
                    .task {

                        await model.authUser(email: email, password: password)

                        let object = TestObject(firstName: "Brian", lastName: "Masse", ownerID: model.user!.id)
                        model.writeObject( object )
                    }
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
        .padding()
    }
}

struct SignupForm: View {
    
    @Binding var email: String
    @Binding var password: String
    
    var body: some View {
        
        Form {
            Section(header: Text("Signup")) {
                TextField("Email", text: $email)
                TextField("Password", text: $password)
            }
        }
        
        Text("Sign up ")
        
    }
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        signupForm()
//    }
//}
