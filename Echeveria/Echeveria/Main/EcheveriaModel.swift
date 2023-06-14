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
    func authRealm(realm: Realm) async {
        self.realm = realm
        await self.addSubcriptions()
        
        DispatchQueue.main.sync {
            self.retreiveObject()
            self.setupNotificationTokens()
            self.realmLoaded = true
        }
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
                break
//                print("deleted ", deletions)
//                print("inserted ", insertions)
//                print("mods ", modifications)
                
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
    private func addSubcriptions() async {
        
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
