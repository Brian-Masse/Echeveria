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
    
//    TODO: I'm not sure this is the best way to do this, it might be long to load hundreds of things at once
//    there should be a limit to how muhc it pulls at once
    func updatePermissionsForGroupView() async {
        let realmManager = EcheveriaModel.shared.realmManager
        await realmManager.profileQuery.addQuery { query in
            query.ownerID.in( self.members )
        }
        
        await realmManager.gamesQuery.addQuery { query in
            query.groupID == self._id
        }
    }
    
    func updatePermissionsForGameLogger() async {
        let realmManager = EcheveriaModel.shared.realmManager
        await realmManager.profileQuery.addQuery { query in
            query.ownerID.in( self.members )
        }
    }

    static func searchForGroup(_ name: String, profile: EcheveriaProfile) async {
        await EcheveriaModel.shared.realmManager.groupQuery.addQuery(QuerySubKey.groupSearch.rawValue) { query in
            query.name == name || query.members.contains(profile.ownerID)
        }
    }

    static func resetSearch(profile: EcheveriaProfile) async {
        await EcheveriaModel.shared.realmManager.groupQuery.removeQuery(QuerySubKey.groupSearch.rawValue)
    }
    
}
