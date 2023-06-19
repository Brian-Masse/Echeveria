//
//  LoginModel.swift
//  Echeveria
//
//  Created by Brian Masse on 6/13/23.
//

import Foundation
import RealmSwift

//These are the API keys that can be used to login to the app

// DEV1-RW-ACESS
//XlT89XaRYXqoWEuvO15uZLYkfx7ztwb1otSz1zr5CmiE9DG3Rnx12l0XBy1IKsIf
// DEV2-RW-ACCESS
//LpOlH5uMKGInzmMFQ7EBqf3Nj4VOd6RY3ztoPqnjsLnY0S40NWRhoH6qJQS1TH6u

class LoginModel: ObservableObject {
    enum LoginMethod: String, CaseIterable, Identifiable {
        case API = "API"
        case email = "email"
        case Apple = "Apple"
        case Anonymous = "Anonymous"
        
        var id: Self { self }
    }
    
    var credentials: Credentials!
    
    static let shared = LoginModel()
    
    func APISignIn( _ token: String ) {
        self.credentials = Credentials.userAPIKey(token)
    }
    
    func AnonymousSignIn() {
        self.credentials = Credentials.anonymous
    }
    
    func authenticateUser() async {
        await EcheveriaModel.shared.realmManager.authUser(credentials: self.credentials)
    }
    
}
