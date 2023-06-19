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
    
    @Persisted var groups: List<EcheveriaGroup> = List()
//    @Persisted var games: List<EcheveriaGame> = List()
    
    convenience init(ownerID: String, firstName: String, lastName: String, userName: String) {
        self.init()
        self.ownerID = ownerID
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
    }
    
    static func getProfileObject(from ownerID: String) -> EcheveriaProfile? {
        let results: Results<EcheveriaProfile> = EcheveriaModel.retrieveObject { query in
            query.ownerID == ownerID
        }
        guard let profile = results.first else { print( "No profile exists with the given id: \(ownerID)" ); return nil }
        return profile   
    }
    
    func getNumCards() -> Int {
        let cards: Results<TestObject> = EcheveriaModel.retrieveObject { query in query.ownerID == self.ownerID }
        return cards.count
    }
    
    func updateInformation( firstName: String, lastName: String, userName: String ) {
        EcheveriaModel.updateObject(self) { thawed in
            thawed.firstName = firstName
            thawed.lastName = lastName
            thawed.userName = userName
        }
    }
    
    func addGame(_ gameID: String) {
//        guard let game = EcheveriaGame.getGameObject(from: gameID) else {return}
//        EcheveriaModel.updateObject(self) { thawed in
//            thawed.games.append(game)
//        }
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
    
//    TODO: This should be better but I am tired and don't care
    func provideLocalUserFullAccess() async {
        let _:EcheveriaProfile? = await EcheveriaModel.shared.realmManager.addGenericSubcriptions(name: .account, query: { query in

            var users: [String] = []
            for group in self.groups {
                users.append(contentsOf: group.members)
            }

            return query.ownerID.in(users)
        })
    }
    
    func disallowLocalUserFullAccess() async {
        let _:EcheveriaProfile? = await EcheveriaModel.shared.realmManager.addGenericSubcriptions(name: .account, query: { query in
            query.ownerID == self.ownerID
        })
    }
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

