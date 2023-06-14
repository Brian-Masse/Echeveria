//
//  RealmManager.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import SwiftUI
import RealmSwift

//this handles logging in, and opening the right realm with the right credentials
    class RealmManager: ObservableObject {
    
//    This realm will be generated once the user has authenticated themselves (handled in LoginModel)
//    and the AsyncOpen call in LoginView has completed
    var realm: Realm!
    var app = RealmSwift.App(id: "application-0-qufwt")
    var configuration: Realm.Configuration!
    
//    This is the realm user that signed into the app
    var user: User?
    
    @Published var signedIn: Bool = false
    @Published var realmLoaded: Bool = false
    
    var notificationToken: NotificationToken?
    
    //    MARK: Authentication Functions
        func authUser(credentials: Credentials) async {
    //        this simply logs the user in and returns any status errors
    //        Once the user is signed in, the LoginView loads the realm using the config generated in self.post-authentication()
            do {
                self.user = try await app.login(credentials: credentials)
                self.postAuthenticationInit()
            } catch { print("error logging in: \(error.localizedDescription)") }
        }
        
        private func postAuthenticationInit() {
            self.setConfiguration()
            DispatchQueue.main.sync { self.signedIn = true }
        }

        private func setConfiguration() {
            self.configuration = user!.flexibleSyncConfiguration()
            self.configuration.schemaVersion = 1
            
            Realm.Configuration.defaultConfiguration = self.configuration
        }

    //    MARK: Realm-Loaded Functions
    //    Called once the realm is loaded in OpenSyncedRealmView
        func authRealm(realm: Realm) async {
            self.realm = realm
            await self.addSubcriptions()
            
            DispatchQueue.main.sync {
                self.setupNotificationTokens()
                self.realmLoaded = true
            }
        }
        
        private func setupNotificationTokens() {
            
            for item in self.realm.objects( TestObject.self ) {
                print(item)
            }
//            Take action from an observed change, more than simple UI refresh
//            See the quickStart docs for implementation: https://www.mongodb.com/docs/realm/sdk/swift/quick-start/
        }
        
        private func addSubcriptions() async {
//            This is a clunky way of doing this
//            Effectivley, the order is login -> auth (setup dud configuration) -> create synced realm (with responsive UI)
//             ->add the subscriptions (which downloads the data from the cloud) -> enter into the app with proper config and realm
//            Instead, when creating the configuration, use initalSubscriptions to provide the subs before creating the relam
//            This wasn't working before, but possibly if there is an instance of Realm in existence it might work?
            
            let subscriptions = self.realm.subscriptions
            let foundSubscriptions = subscriptions.first(named: "testObject")
            if foundSubscriptions != nil {return}
            
            do {
                try await subscriptions.update {
                    subscriptions.append(QuerySubscription<TestObject>(name: "testObject") {
                        $0.ownerID == self.user!.id
                    })
                }
            } catch { print("error adding subcription: \(error)") }
        
        }
    
    //    This is only when migrating and should not be used for now...
    //    private func setConfiguration() {
    //        self.configuration = Realm.Configuration(
    //            schemaVersion: 1,
    //            migrationBlock: { migration, oldSchemaVersion in
    //                if oldSchemaVersion < 1 {
    //                    migration.enumerateObjects(ofType: TestObject.className()) { oldObject, newObject in
    //                        newObject!["ownerID"] = "defaultID"
    //                    }
    //                }
    //            }
    //        )
    //        Realm.Configuration.defaultConfiguration = configuration
    //    }
        
    
}
