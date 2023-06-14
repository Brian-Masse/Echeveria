//
//  model.swift
//  Echeveria
//
//  Created by Brian Masse on 6/13/23.
//

import Foundation
import RealmSwift
import SwiftUI

class TestObject: Object {
    
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
        echeveriaModel.writeToRealm { self.firstName = name }
    }
}

//MARK: Model
class EcheveriaModel: ObservableObject {
    
    var realm: Realm!
    var app = RealmSwift.App(id: "application-0-qufwt")
    
    var user: User?
    @Published var signedIn: Bool = false
    
    var objects: Results<TestObject>!
    var notificationToken: NotificationToken?
    
    //MARK: Initialization Functions
    init() {
        self.setConfiguration()
        //the rest of initialization needs to be handled after the user signs in, and will be called from the LoginModel
    }
    
    func postAuthenticationInit() {
        self.retreiveObject()
        self.setupNotificationTokens()
        self.signedIn = true
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
    
    
    //MARK: Authentication Functions
    func authUser(credentials: Credentials) async {
        do {    
            self.user = try await app.login(credentials: credentials)
            await openSyncedRealm(user: user!)
        } catch { print("error logging in: \(error.localizedDescription)") }
    }
    
    @MainActor
    private func openSyncedRealm(user: User) async {
        do {
            var config = user.flexibleSyncConfiguration()
            
            config.objectTypes = [TestObject.self]
            self.realm = try await Realm(configuration: config, downloadBeforeOpen: .always)
            
            let subscriptions = realm.subscriptions
            try await subscriptions.update {
                subscriptions.append(
                    QuerySubscription<TestObject> {
                        $0.ownerID == user.id
                    }
                )
            }
        }
        catch {
            print("error opening synced Realm: \(error.localizedDescription)")
        }
        
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
    
    private func setConfiguration() {
        let configuration = Realm.Configuration(
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
