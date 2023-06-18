//
//  model.swift
//  Echeveria
//
//  Created by Brian Masse on 6/13/23.
//

import Foundation
import RealmSwift
import SwiftUI


//MARK: Model
class EcheveriaModel {
    
    static let shared = EcheveriaModel()
    let realmManager = RealmManager()
    
    private(set) var profile: EcheveriaProfile!
    
    func setProfile(with profile: EcheveriaProfile) {
        self.profile = profile
    }
    
    //MARK: Convience Functions
    static func writeToRealm(_ block: () -> Void ) {
        do { try EcheveriaModel.shared.realmManager.realm.write { block() }}
        catch { print(error.localizedDescription) }
    }
    
    static func updateObject<T: Object>(_ object: T, _ block: (T) -> Void, needsThawing: Bool = true) {
        EcheveriaModel.writeToRealm {
            guard let thawed = object.thaw() else {
                print("failed to thaw object: \(object)")
                return
            }
            block(thawed)
        }
        
    }
    
    static func addObject<T:Object>( _ object: T ) {
        self.writeToRealm { EcheveriaModel.shared.realmManager.realm.add(object) }
    }
    
    static func retrieveObject<T:Object>( where query: ( (Query<T>) -> Query<Bool> ) ) -> Results<T> {
        return EcheveriaModel.shared.realmManager.realm.objects(T.self).where(query)
    }
    
    static func deleteObject( _ object: TestObject ) {
        
        let sourceObject = EcheveriaModel.shared.realmManager.realm.objects(TestObject.self).filter { obj in obj._id == object._id }
    
        self.writeToRealm { EcheveriaModel.shared.realmManager.realm.delete(sourceObject) }
    }

    
}
