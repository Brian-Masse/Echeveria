//
//  User.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import RealmSwift


class EcheveriaProfile: Object, Identifiable {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var ownerID: String = ""
    
    @Persisted var firstName: String = ""
    @Persisted var lastName: String = ""
    @Persisted var userName: String = ""
    @Persisted var icon: String = ""
    
    @Persisted var groups: List<EcheveriaGroup> = List()
    
    convenience init(ownerID: String, firstName: String, lastName: String, userName: String, icon: String) {
        self.init()
        self.ownerID = ownerID
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
        self.icon = icon
    }
    
    static func getProfileObject(from ownerID: String) async -> EcheveriaProfile?  {
        
        await EcheveriaModel.shared.realmManager.profileQuery.addQuery(name: ownerID) { query in query.ownerID == ownerID }
        
        if let profile = findLocalProfile(ownerID) {
            if checkPermission(profile) { return profile }
            else { await EcheveriaModel.shared.realmManager.profileQuery.removeQuery(ownerID) }
        }
    
        print( "No profile exists with the given id: \(ownerID)")
        return nil
            
        @Sendable func findLocalProfile(_ ownerID: String) -> EcheveriaProfile? {
            return DispatchQueue.main.sync {
                var obj: EcheveriaProfile? = nil
                let results: Results<EcheveriaProfile> = EcheveriaModel.retrieveObject { query in
                    query.ownerID == ownerID
                }
                if let profile = results.first  { obj = profile }
                return obj
            }
        }
    
        @Sendable func checkPermission(_ profile: EcheveriaProfile) -> Bool {
            return true
        }
    }
    
    
    
    static func getName(from ownerID: String) async -> String {
        let result = await EcheveriaProfile.getProfileObject(from: ownerID)!
        return result.firstName
    }
    
    func getNumCards() -> Int {
        let cards: Results<TestObject> = EcheveriaModel.retrieveObject { query in query.ownerID == self.ownerID }
        return cards.count
    }
    
    func updateInformation( firstName: String, lastName: String, userName: String, icon: String ) {
        EcheveriaModel.updateObject(self) { thawed in
            thawed.firstName = firstName
            thawed.lastName = lastName
            thawed.userName = userName
            thawed.icon = icon
        }
    }

    func joinGroup(_ groupID: ObjectId) {
        guard let group = EcheveriaGroup.getGroupObject(from: groupID) else { return }
        EcheveriaModel.updateObject(self) { thawed in
            if thawed.groups.contains(group) { return }
            thawed.groups.append(group)
        }
    }
    
    func leaveGroup(_ group: EcheveriaGroup) {
        EcheveriaModel.updateObject(self) { thawed in
            if let index = thawed.groups.firstIndex(of: group) {
                thawed.groups.remove(at: index)
            }
        }
    }
    
//    When another person enters your profile, give them access to the profile and all the games
//    ids is a list of the signed in users ownerID, and the profiles owner ID
//    it needs to be passed in to make sure realm is onyl accessed on the main thread
//    func provideLocalUserProfileAccess(ids: [String]) async {
//
//        if ids[0] == ids[1] { return }
//
//        let _:EcheveriaProfile? = await EcheveriaModel.shared.realmManager.addGenericSubcriptions(name: .account, query: { query in query.ownerID.in(ids) })
//
//        let _:EcheveriaGame? = await EcheveriaModel.shared.realmManager.addGenericSubcriptions(name: .games, query: { query in query.ownerID.in(ids) })
//
//        let _:EcheveriaGroup? = await EcheveriaModel.shared.realmManager.addGenericSubcriptions(name: .groups, query: { query in query.owner.in(ids) })
//    }
//
//    func disallowLocalUserProfileAccess() async {
//        let _:EcheveriaProfile? = await EcheveriaModel.shared.realmManager.addGenericSubcriptions(name: .account, query: { query in
//            query.ownerID == EcheveriaModel.shared.profile.ownerID
//        })
//
//        let _:EcheveriaProfile? = await EcheveriaModel.shared.realmManager.addGenericSubcriptions(name: .account, query: { query in
//            query.ownerID == EcheveriaModel.shared.profile.ownerID
//        })
//    }
}

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
        EcheveriaModel.updateObject(self) { thawed in thawed.firstName = name }
    }
}

