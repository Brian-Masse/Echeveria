//
//  User.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import RealmSwift


class EcheveriaUser: Object, Identifiable {
    
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
        EcheveriaModel.writeToRealm {
            guard let thawedSelf = self.thaw() else {
                print("failed to thaw object: \(self.ownerID), \(self)")
                return
            }
            thawedSelf.firstName = name
        }
    }
}

