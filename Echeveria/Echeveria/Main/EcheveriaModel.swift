//
//  model.swift
//  Echeveria
//
//  Created by Brian Masse on 6/13/23.
//

import Foundation
import RealmSwift
import SwiftUI

class TestObject: Object, Identifiable {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var firstName: String = ""
    @Persisted var lastName: String = ""
    @Persisted var ownerID: String = ""
    
    
    convenience init( firstName: String, lastName: String, ownerID: String ) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.ownerID = ownerID
    }
    
    func updateName(to name: String) {
//        echeveriaModel.writeToRealm {
        do {
            try echeveriaModel.realm.write() {
                guard let thawedSelf = self.thaw() else {
                    print("failed to thaw object: \(self.ownerID), \(self)")
                    return
                }
                thawedSelf.firstName = name
            }
        }catch { print("Failed to save name change") }
    }
}

//MARK: Model
class EcheveriaModel: ObservableObject {
    
//    This realm will be generated once the user has authenticated themselves (handled in LoginModel)
//    and the AsyncOpen call in LoginView has completed
    var realm: Realm!
    var app = RealmSwift.App(id: "application-0-qufwt")
    var configuration: Realm.Configuration!
    
//    This is the realm user that signed into the app
    var user: User?
    
    @Published var signedIn: Bool = false
    @Published var realmLoaded: Bool = false
    
    var objects: Results<TestObject>!
    var notificationToken: NotificationToken?
    
//    MARK: Realm-Loaded Functions
//    Called once the realm is loaded in OpenSyncedRealmView
    func authRealm(realm: Realm) {
        self.realm = realm
        self.retreiveObject()
        self.setupNotificationTokens()
        self.realmLoaded = true
    }
    
    private func retreiveObject() {
        self.objects = realm.objects(TestObject.self)
    }
    
    private func setupNotificationTokens() {
//      Take action from an observed change, more than simple UI refresh
        notificationToken = self.objects.observe { (changes) in
            switch changes {
            case .initial: break
            case .update(_, let deletions, let insertions, let modifications):
                print("deleted ", deletions)
                print("inserted ", insertions)
                print("mods ", modifications)
                
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
//    MARK: Authentication Functions
    func authUser(credentials: Credentials) async {
//        this simply logs the user in and returns any status errors
//        Once the user is signed in, the LoginView loads the realm using the config generated in self.post-authentication()
        do {    
            self.user = try await app.login(credentials: credentials)
            await postAuthenticationInit()
        } catch { print("error logging in: \(error.localizedDescription)") }
    }
    
    private func postAuthenticationInit() async {
        await self.setConfiguration()
        DispatchQueue.main.sync { self.signedIn = true }
    }
    
    private func setConfiguration() async {
//        you add subscriptions at the initialization of this configuration, because the configuration is created before realm is initialized
        
    
        self.configuration = user!.flexibleSyncConfiguration { subs in
            let tempSubExists = subs.first(named: "testObject")
            
//                If there is a matching subscriber that alread exists
//                this likley will never be run—this configuration will probably just be set at the start of the app instance
            if tempSubExists != nil { return }
//                add queries for the objects that you want to use in this app
            
            subs.append(QuerySubscription<TestObject>(name: "testObject") {
                $0.ownerID == self.user!.id
            })
        }
        
        self.configuration.schemaVersion = 1
        Realm.Configuration.defaultConfiguration = self.configuration
    }
    
    //MARK: Convience Functions
    func writeToRealm(_ block: () -> Void ) {
        do { try realm.write {
            block()
        }}
        catch { print(error.localizedDescription) }
    }
    
    func writeObject( _ object: TestObject ) {
        self.writeToRealm { realm.add(object) }
    }
    
    private func deleteObject( _ object: TestObject ) {
        self.writeToRealm { realm.delete(object) }
    }
    
//    This is only when migrating and should not be used for now...
    private func setConfiguration() {
        self.configuration = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: TestObject.className()) { oldObject, newObject in
                        newObject!["ownerID"] = "defaultID"
                    }
                }
            }
        )
        Realm.Configuration.defaultConfiguration = configuration
    }
    
    
}
