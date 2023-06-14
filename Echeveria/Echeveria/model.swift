//
//  model.swift
//  Echeveria
//
//  Created by Brian Masse on 6/13/23.
//

import Foundation
import RealmSwift

class TestObject: Object {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var firstName: String = ""
    @Persisted var lastName: String = ""
    @Persisted var ownerID: String = ""
//
    convenience init( firstName: String, lastName: String, ownerID: String ) {
        self.init()
        self.firstName = firstName
        self.lastName = lastName
        self.ownerID = ownerID
    }
    
    func updateName(to name: String) {
        print("tapped")
        model.writeToRealm { self.firstName = name }
    }
}

class Model {
    
    var realm: Realm!
    var app = RealmSwift.App(id: "application-0-qufwt")
    
    var user: User?
    var signedIn: Bool { user != nil }
    
    var objects: Results<TestObject>!
    
    var notificationToken: NotificationToken?
    
    init() {
        
        self.setConfiguration()
        self.openRealm()
        
        self.objects = realm.objects(TestObject.self)

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
    
    func openRealm() {
        do { self.realm = try Realm() }
        catch { print(error.localizedDescription) }
    }
    
    func authUser(email: String, password: String) async {
        do {
            
//            self.user = try await app.login(credentials: Credentials.anonymous)
            self.user = try await app.login(credentials: Credentials.emailPassword(email: email, password: password))
            await openSyncedRealm(user: user!)
        } catch { print("error logging in: \(error.localizedDescription)") }
    }
    
    @MainActor
    private func openSyncedRealm(user: User) async {
        do {
            var config = user.flexibleSyncConfiguration()
            
            config.objectTypes = [TestObject.self]
            let realm = try await Realm(configuration: config, downloadBeforeOpen: .always)
            
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
        var configuration = Realm.Configuration(
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
