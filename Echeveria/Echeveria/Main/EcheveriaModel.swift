//
//  model.swift
//  Echeveria
//
//  Created by Brian Masse on 6/13/23.
//

import Foundation
import RealmSwift
import SwiftUI

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

//MARK: Model
class EcheveriaModel {
    
    static let shared = EcheveriaModel()
    let realmManager = RealmManager()
    
    //MARK: Convience Functions
    static func writeToRealm(_ block: () -> Void ) {
        do { try EcheveriaModel.shared.realmManager.realm.write { block() }}
        catch { print(error.localizedDescription) }
    }
    
    static func addObject( _ object: TestObject ) {
        self.writeToRealm { EcheveriaModel.shared.realmManager.realm.add(object) }
    }
    
    static func deleteObject( _ object: TestObject ) {
        
        let sourceObject = EcheveriaModel.shared.realmManager.realm.objects(TestObject.self).filter { obj in obj._id == object._id }
    
        self.writeToRealm { EcheveriaModel.shared.realmManager.realm.delete(sourceObject) }
    }

    
}
