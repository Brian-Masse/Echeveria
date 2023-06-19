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
    
    
    convenience init( name: String, icon: String ) {
        
        self.init()
        self.name = name
        self.icon = icon
        
    }
    
    func addToRealm() {
        let id = EcheveriaModel.shared.profile.ownerID
        self.owner = id
        self.members.append( id )
        
        EcheveriaModel.addObject(self)
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
    }
    
    func removeMember(_ memberID: String) {
        EcheveriaModel.updateObject(self) { thawed in
            guard let int = thawed.members.firstIndex(of: memberID) else { print("Target user is not a member of this group and cannot be deleted"); return }
            thawed.members.remove(at: int)
        }
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
