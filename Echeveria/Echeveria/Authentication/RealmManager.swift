//
//  RealmManager.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import SwiftUI
import RealmSwift
import Realm

//this handles logging in, and opening the right realm with the right credentials
class RealmManager: ObservableObject {
    
//    This realm will be generated once the profile has authenticated themselves (handled in LoginModel)
//    and the AsyncOpen call in LoginView has completed
    var realm: Realm!
    var app = RealmSwift.App(id: "application-0-qufwt")
    var configuration: Realm.Configuration!
    
//    This is the realm profile that signed into the app
    var user: User?
    
    @Published var signedIn: Bool = false
    @Published var hasProfile: Bool = false
    @Published var realmLoaded: Bool = false
    
    var notificationToken: NotificationToken?
        
    init() {
        self.checkLogin()
    }
    
    func checkLogin() {
        if let user = app.currentUser {
            self.user = user
            self.postAuthenticationInit(loggingin: true)
        }
    }
    
//    if the profile has a profile, then skip past the create profile UI
    func checkProfile() async {
//        downloads it, if it exists
        let _:EcheveriaProfile? = await self.addGenericSubcriptions(name: "AccountCheck") { queryObject in
            queryObject.ownerID == self.user!.id
        }
        
//        Checks the downloads
        DispatchQueue.main.sync {
            let profile = retrieveUserProfile()
            if profile != nil { registerProfileLocally(profile!) }
        } 
        
        await self.removeSubscription(name: "AccountCheck")
    }
    
//    convenience function only being used in the above profile checker
    private func retrieveUserProfile() -> EcheveriaProfile? {
        let results = realm.objects(EcheveriaProfile.self).where { queryObject in
            queryObject.ownerID == self.user!.id
        }
        return results.first
    }
    
    
    func addProfile( profile: EcheveriaProfile ) async {
        let _:EcheveriaProfile? = await self.addGenericSubcriptions(name: "Account") { query in
            query.ownerID == self.user!.id
        }
        
        DispatchQueue.main.sync {
            profile.ownerID = user!.id
            EcheveriaModel.addObject(profile)
            registerProfileLocally(profile)
        }
    }
    
//    whether you're loading the profile from the databae or creating at startup, it should go throught this function to
//    let the model know that the profile now has a profile and send that profile object to the model
//    TODO: Im not sure if the model should store a copy of the profile. It might be better to pull directyl from the DB, but for now this works
    private func registerProfileLocally( _ profile: EcheveriaProfile ) {
        hasProfile = true
        EcheveriaModel.shared.setProfile(with: profile)
    }
    
    //    MARK: Authentication Functions
    func authUser(credentials: Credentials) async {
//        this simply logs the profile in and returns any status errors
//        Once the profile is signed in, the LoginView loads the realm using the config generated in self.post-authentication()
        do {
            self.user = try await app.login(credentials: credentials)
            self.postAuthenticationInit()
        } catch { print("error logging in: \(error.localizedDescription)") }
    }
    
    func logoutUser() {
        self.user!.logOut { error in
            if let error = error { print("error logging out: \(error.localizedDescription)") }
            
            DispatchQueue.main.sync {
                self.signedIn = false
                self.hasProfile = false
                self.realmLoaded = false
            }
        }
    }
        
    private func postAuthenticationInit(loggingin: Bool = false) {
        self.setConfiguration()
        if !loggingin { DispatchQueue.main.sync { self.signedIn = true } }
        else { self.signedIn = true }
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
//            Take action from an observed change, more than simple UI refresh
//            See the quickStart docs for implementation: https://www.mongodb.com/docs/realm/sdk/swift/quick-start/
    }
    
    private func addSubcriptions() async {
//            This is a clunky way of doing this
//            Effectivley, the order is login -> auth (setup dud configuration) -> create synced realm (with responsive UI)
//             ->add the subscriptions (which downloads the data from the cloud) -> enter into the app with proper config and realm
//            Instead, when creating the configuration, use initalSubscriptions to provide the subs before creating the relam
//            This wasn't working before, but possibly if there is an instance of Realm in existence it might work?
        
        let _:TestObject? = await self.addGenericSubcriptions(name: "testObject") { query in
            query.ownerID == self.user!.id
        }
    }
    
    func addGenericSubcriptions<T>(name: String, query: @escaping (Query<T>) -> Query<Bool> ) async -> T? where T:RealmSwiftObject  {
            
        let subscriptions = self.realm.subscriptions
        let foundSubscriptions = subscriptions.first(named: name)
        if foundSubscriptions != nil {return nil}
        
        do {
            try await subscriptions.update{
                let query = QuerySubscription(name: name) { queryObj in query(queryObj) }
                subscriptions.append(query)
            }
        } catch { print("error adding subcription: \(error)") }
        return nil
    }
    
    func removeSubscription(name: String) async {
            
        let subscriptions = self.realm.subscriptions
        let foundSubscriptions = subscriptions.first(named: name)
        if foundSubscriptions == nil {return}
        
        do {
            try await subscriptions.update{
                subscriptions.remove(named: name)
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
