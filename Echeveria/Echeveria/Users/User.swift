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
    
    convenience init(ownerID: String, firstName: String, lastName: String, userName: String) {
        self.init()
        self.ownerID = ownerID
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
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

