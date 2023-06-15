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
    
    @Persisted var members: List<String>
    
    @Persisted var groupName: String = "testGroup"
    
    
    
}
