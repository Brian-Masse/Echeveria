//
//  File.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import RealmSwift

class EcheveriaGroup: Object, Identifiable {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    
//    This is a list of the ownerIDs of the EcheveriaProfiles
//    TODO: This should probabaly be another form of identification, so that you don't have another users data downloaded on your device
    @Persisted var members: List<String> = List()
    @Persisted var owner: String
//    This is the person who created the group
    
    @Persisted var name: String = ""
    @Persisted var icon: String = ""
    
//    @Persisted var games: List<EcheveriaGame> = List()
    
    var id: String { self._id.stringValue }
    
    convenience init( name: String, icon: String ) {
        self.init()
        self.name = name
        self.icon = icon
    }
    
    static func getGroupObject(from _id: ObjectId) -> EcheveriaGroup? {
        let results: Results<EcheveriaGroup> = EcheveriaModel.retrieveObject { query in
            query._id == _id
        }
        guard let group = results.first else { print( "No group exists with the given id: \(_id)" ); return nil }
        return group
    }
    
    func addGame(_ gameID: String) {
//        guard let game = EcheveriaGame.getGameObject(from: gameID) else {return}
//        EcheveriaModel.updateObject(self) { thawed in
//            thawed.games.append(game)
//        }
    }
    
    func addToRealm() {
        let id = EcheveriaModel.shared.profile.ownerID
        self.owner = id
        self.members.append( id )
        
        EcheveriaModel.addObject(self)
    }
    
    func updateInformation(name: String, icon: String) {
        EcheveriaModel.updateObject(self) { thawed in
            thawed.name = name
            thawed.icon = icon
        }
    }
    
    func hasMember(_ memberID: String) -> Bool {
        return self.members.contains { id in
            id == memberID
        }
    }
    
    func addMember(_ memberID: String) {
        EcheveriaModel.updateObject(self) { thawed in
            thawed.members.append(memberID)
        }
        if let profile = EcheveriaProfile.getProfileObject(from: memberID) { profile.joinGroup(self._id) }
        
    }
    
    func removeMember(_ memberID: String) {
        EcheveriaModel.updateObject(self) { thawed in
            guard let int = thawed.members.firstIndex(of: memberID) else { print("Target user is not a member of this group and cannot be deleted"); return }
            thawed.members.remove(at: int)
        }
        if let profile = EcheveriaProfile.getProfileObject(from: memberID) { profile.leaveGroup(self) }
    }
    
//    When a user is viewing a group, it needs to be able to temporarily pull their information
//    This inclues all the profiles that the group might have, as well as all the game data associated with it
//    TODO: I'm not sure this is the best way to do this, it might be long to load hundreds of things at once
//    there should be a limit to how muhc it pulls at once
    func provideLocalUserAccess() async {
        let _:EcheveriaProfile? = await EcheveriaModel.shared.realmManager.addGenericSubcriptions(name: .account, query: { query in query.ownerID.in(self.members) })
        
        let _:EcheveriaGame? = await EcheveriaModel.shared.realmManager.addGenericSubcriptions(name: .games, query: { query in query.groupID == self._id })
    }
    
    func disallowLocalUserAccess() async {
        let _:EcheveriaProfile? = await EcheveriaModel.shared.realmManager.addGenericSubcriptions(name: .account, query: { query in
            query.ownerID == EcheveriaModel.shared.profile.ownerID
        })
        
        let _:EcheveriaGame? = await EcheveriaModel.shared.realmManager.addGenericSubcriptions(name: .account, query: { query in
            query.ownerID == EcheveriaModel.shared.profile.ownerID
        })
    }
    
    static func searchForGroup(_ name: String, profile: EcheveriaProfile) async {
        let _:EcheveriaGroup? = await EcheveriaModel.shared.realmManager.addGenericSubcriptions(name: .groups) { query in
            query.name == name || query.members.contains(profile.ownerID)
        }
    }
    
    static func resetSearch(profile: EcheveriaProfile) async {
        let _:EcheveriaGroup? = await EcheveriaModel.shared.realmManager.addGenericSubcriptions(name: .groups) { query in
            query.members.contains(profile.ownerID)
        }
    }
    
}
