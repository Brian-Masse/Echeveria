//
//  model.swift
//  Echeveria
//
//  Created by Brian Masse on 6/13/23.
//

import Foundation
import RealmSwift
import Realm
import SwiftUI

//MARK: Model
class EcheveriaModel: ObservableObject {
    
    static let shared = EcheveriaModel()
    let realmManager = RealmManager()
    
    @Published var triggerReload: Bool = false

    private(set) var profile: EcheveriaProfile!
    @Published private(set) var activeColors: [Color] = []
    
    private(set) var activeID: String!
    
    func setProfile(with profile: EcheveriaProfile) {
        self.profile = profile
        self.activeID = profile.ownerID
        self.activeColors.append(profile.getColor())
    }
    
    func addActiveColor(with color: Color) {
        self.activeColors.append(color)
    }
    
    func setActiveColor(with color: Color) {
        self.activeColors = [color]
    }
    
    func removeActiveColor() {
        if activeColors.count <= 1 { return }
        self.activeColors.removeLast()
    }
    
    //MARK: Convience Functions
    static func writeToRealm(_ block: () -> Void ) {
        do {
            if EcheveriaModel.shared.realmManager.realm.isInWriteTransaction { block() }
            else { try EcheveriaModel.shared.realmManager.realm.write(block) }
            
        } catch { print(error.localizedDescription) }
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
    
    static func retrieveObject<T:Object>( where query: ( (Query<T>) -> Query<Bool> )? = nil ) -> Results<T> {
        if query == nil { return EcheveriaModel.shared.realmManager.realm.objects(T.self) }
        else { return EcheveriaModel.shared.realmManager.realm.objects(T.self).where(query!) }
        
    }
    
    static func deleteObject<T: RealmSwiftObject>( _ object: T, where query: @escaping (Query<T>) -> Query<Bool> ) where T: Identifiable {
        
        let sourceObjects: Results<T> = EcheveriaModel.retrieveObject(where: query)
        
        if let obj = sourceObjects.first {
            self.writeToRealm { EcheveriaModel.shared.realmManager.realm.delete(obj) }
        }
    }

    
}
