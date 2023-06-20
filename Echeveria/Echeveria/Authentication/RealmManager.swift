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

enum QuerySubKey: String {
    
    case testObject = "testObject"
    case account = "Account"
    case groups = "Groups"
    case games = "Games"
    
}

class QueryPermission<T: Object> {
    
    struct WrappedQuery<O: Object> {
        let name: String
        let query: ((Query<O>) -> Query<Bool>)
    }
    
    let baseQuery: (Query<T>) -> Query<Bool>
    var additionalQueries: [ WrappedQuery<T> ] = []
    
    init( baseQuery: @escaping (Query<T>) -> Query<Bool> ) {
        self.baseQuery = baseQuery
    }
    
    private func makePredicateFromQuery( passedQuery: Query<T>, evaluatingQuery: ((Query<T>) -> Query<Bool>)) -> NSPredicate {
        let predicateArgs = evaluatingQuery(passedQuery)._constructPredicate()
        let predicate = NSPredicate(format: predicateArgs.0, predicateArgs.1)
        return predicate
    }
    
//    This takes all the queries, base and those stored in the list of additioanl queries, evaluates them wiht some passed values (ie. EcheveriaProfile)
//    Then combines those with the or operator into a single NSPredicate that represents wheter any one of them evalutaed to true
    func completeQuery( query: Query<T> ) -> NSPredicate {
    
        var queryList: [NSPredicate] = additionalQueries.compactMap { wrappedQuery in
            makePredicateFromQuery(passedQuery: query, evaluatingQuery: wrappedQuery.query)
        }
        
        queryList.append( makePredicateFromQuery(passedQuery: query, evaluatingQuery: baseQuery) )
    
        return NSCompoundPredicate(orPredicateWithSubpredicates: queryList)
    }
    
    func addQuery( _ name: String, query: @escaping ((Query<T>) -> Query<Bool>) ) {
        let wrappedQuery = WrappedQuery(name: name, query: query)
        additionalQueries.append(wrappedQuery)
    }

    func removeQuery(_ name: String) {
        if let index = additionalQueries.firstIndex(where: { wrappedQuery in
            wrappedQuery.name == name
        }) {
            additionalQueries.remove(at: index)
        }
    }
}

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
    
    private func setConfiguration() {
        self.configuration = user!.flexibleSyncConfiguration()
        self.configuration.schemaVersion = 1
        
        Realm.Configuration.defaultConfiguration = self.configuration
    }
    
//    MARK: Authentication Functions
//    If there is a user already signed in,skip the user authentication system
    func checkLogin() {
        if let user = app.currentUser {
            
            self.user = user
            self.postAuthenticationInit(loggingin: true)
        }
    }
    
//    Called by the LoginModel once credentials are provided
    func authUser(credentials: Credentials) async {
//        this simply logs the profile in and returns any status errors
//        Once the user is signed in, the LoginView loads the realm using the config generated in self.post-authentication()
        do {
            self.user = try await app.login(credentials: credentials)
            self.postAuthenticationInit()
        } catch { print("error logging in: \(error.localizedDescription)") }
    }
    
    private func postAuthenticationInit(loggingin: Bool = false) {
        self.setConfiguration()
        if !loggingin { DispatchQueue.main.sync { self.signedIn = true } }
        else { self.signedIn = true }
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
    
//    MARK: Profile Functions
    
    private func addProfileSubscription() async {
        let _:EcheveriaProfile? = await self.addGenericSubcriptions(name: .account) { query in
            query.ownerID == self.user!.id
        }
    }
    
//    if the profile has a profile, then skip past the create profile UI
//    if not the profile objcet on EcheveriaModel will remain nil and the UI will show
    func checkProfile() async {
//     the only place the subscription is added is when they create a profile
        if !self.checkSubscription(name: .account) { await self.addProfileSubscription() }
        
        DispatchQueue.main.sync {
            let profile = realm.objects(EcheveriaProfile.self).where { queryObject in
                queryObject.ownerID == self.user!.id
            }.first
            if profile != nil { registerProfileLocally(profile!) }
        }
    }
    
//    If they dont, this function is called to create one. It is sent in from the CreateProfileView
    func addProfile( profile: EcheveriaProfile ) async {
//        Add Subscription to donwload your profile
        await addProfileSubscription()
        
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
//            Effectivley, the order is login -> authenticate user (setup dud realm configuration) -> create synced realm (with responsive UI)
//             ->add the subscriptions (which downloads the data from the cloud) -> enter into the app with proper config and realm
//            Instead, when creating the configuration, use initalSubscriptions to provide the subs before creating the relam
//            This wasn't working before, but possibly if there is an instance of Realm in existence it might work?
        
        let _:TestObject? = await self.addGenericSubcriptions(name: .testObject) { query in
            query.ownerID == self.user!.id
        }
        
//        Add subscriptions to donwload any groups that youre a part of
        let _:EcheveriaGroup? = await self.addGenericSubcriptions(name: .groups) { query in
            return query.members.contains( self.user!.id )
        }
        
        let _:EcheveriaGame? = await self.addGenericSubcriptions(name: .games, query: { query in
            query.ownerID == self.user!.id
        })
            
    }
    
//    MARK: Helper Functions
    func addGenericSubcriptions<T>(name: QuerySubKey, query: @escaping (Query<T>) -> Query<Bool> ) async -> T? where T:RealmSwiftObject  {
            
        let subscriptions = self.realm.subscriptions
        
        do {
            try await subscriptions.update {
                
                let querySub = QuerySubscription(name: name.rawValue) { queryObj in query(queryObj) }
                if checkSubscription(name: name) {
                    let foundSubscriptions = subscriptions.first(named: name.rawValue)!
                    
                    foundSubscriptions.updateQuery(toType: T.self, where: query)
                }
                else { subscriptions.append(querySub)}
            }
        } catch { print("error adding subcription: \(error)") }
        return nil
    }
    
    func removeSubscription(name: QuerySubKey) async {
            
        let subscriptions = self.realm.subscriptions
        let foundSubscriptions = subscriptions.first(named: name.rawValue)
        if foundSubscriptions == nil {return}
        
        do {
            try await subscriptions.update{
                subscriptions.remove(named: name.rawValue)
            }
        } catch { print("error adding subcription: \(error)") }
    }
    
    private func checkSubscription(name: QuerySubKey) -> Bool {
        let subscriptions = self.realm.subscriptions
        let foundSubscriptions = subscriptions.first(named: name.rawValue)
        return foundSubscriptions != nil
    }
}
