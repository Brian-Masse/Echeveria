//
//  File.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import RealmSwift
import SwiftUI

class EcheveriaGroup: Object, Identifiable {
    
//    MARK: General
    @Persisted(primaryKey: true) var _id: ObjectId
    
//    This is a list of the ownerIDs of the EcheveriaProfiles
//    TODO: This should probabaly be another form of identification, so that you don't have another users data downloaded on your device
    @Persisted var members: RealmSwift.List<String> = List()
    @Persisted var owner: String
    
    @Persisted var name: String = ""
    @Persisted var icon: String = ""
    @Persisted var groupDescription: String = ""
//    @Persisted var colorIndex: Int = 0
    
    @Persisted var r: Double = 0
    @Persisted var g: Double = 0
    @Persisted var b: Double = 0
    
    @Persisted var createdDate: Date = .now
    
    var id: String { self._id.stringValue }
    
    convenience init( name: String, icon: String, description: String, color: Color ) {
        self.init()
        self.name = name
        self.icon = icon
        self.groupDescription = description
        self.createdDate = .now
        
        self.setColor(color)
        
    }
    
    func updateInformation(name: String, icon: String, description: String, color: Color) {
        EcheveriaModel.updateObject(self) { thawed in
            thawed.name = name
            thawed.icon = icon
            thawed.groupDescription = description
            
            thawed.setColor(color)
        }
        
//        idk even know bro...Im so tired and this color system makes 0 sense. 07/07/2023 2:27:27AM
//        but this is like the last thing that I need to do so I'm done
        EcheveriaModel.shared.removeActiveColor()
        EcheveriaModel.shared.removeActiveColor()
        EcheveriaModel.shared.addActiveColor(with: color)
        EcheveriaModel.shared.addActiveColor(with: color)
    }
    
//    MARK: Convienience Functions
    static func getGroupObject(from _id: ObjectId) -> EcheveriaGroup? {
        let results: Results<EcheveriaGroup> = EcheveriaModel.retrieveObject { query in
            query._id == _id
        }
        guard let group = results.first else {
            print( "No group exists with the given id: \(_id)" ); return nil }
        return group
    }
    
    static func getGroupObject(with id: String) -> EcheveriaGroup? {
        do {
            let objID = try ObjectId(string: id)
            return getGroupObject(from: objID)
        } catch {
            return nil
        }
    }
    
    func hasMember(_ memberID: String) -> Bool {
        return self.members.contains { id in
            id == memberID
        }
    }
    
    static func getGroupName( _ id: ObjectId ) -> String {
        if let group = EcheveriaGroup.getGroupObject(from: id) {
            return group.name
        }
        return "?"
    }
    
    func getColor() -> Color {
        Color(red: self.r, green: self.g, blue: self.b)
    }
    
    func setColor(_ color: Color) {
        let comps = color.components
        self.r = comps.red
        self.g = comps.green
        self.b = comps.blue
    }
    
//    MARK: Class Methods
    func addToRealm() {
        let id = EcheveriaModel.shared.profile.ownerID
        self.owner = id
        self.members.append( id )
        
        EcheveriaModel.addObject(self)
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
    
    func deleteGroup() {
        for member in self.members {
//            TODO: This should probably let all the games assigned to the group know that the group has been deleted
            self.removeMember(member)
        }
        
        EcheveriaModel.deleteObject(  EcheveriaGroup.getGroupObject(from: self._id)!  ) { group in
            group._id.stringValue.strip() == self._id.stringValue.strip()
        }
    }
    
//    MARK: Permissions
//    TODO: I'm not sure this is the best way to do this, it might be long to load hundreds of things at once
//    there should be a limit to how muhc it pulls at once
    func updatePermissionsForGroupView(id: String) async {
        let realmManager = EcheveriaModel.shared.realmManager
        await realmManager.profileQuery.addQuery(id + QuerySubKey.account.rawValue) { query in
            query.ownerID.in( self.members )
        }
        
        await realmManager.gamesQuery.addQuery(id + QuerySubKey.games.rawValue) { query in
            query.groupID == self._id
        }
    }
    
    func updatePermissionsForGameLogger() async {
        let realmManager = EcheveriaModel.shared.realmManager
        await realmManager.profileQuery.addQuery { query in
            query.ownerID.in( self.members )
        }
        await realmManager.gameDataNodesQuery.addQuery { query in
            query.ownerID.in(self.members)
        }
    }
    
    func closePermissions(id: String) async {
        let realmManager = EcheveriaModel.shared.realmManager
        
        await realmManager.profileQuery.removeQuery(id + QuerySubKey.account.rawValue)
        await realmManager.gamesQuery.removeQuery(id + QuerySubKey.games.rawValue)
        await realmManager.gameDataNodesQuery.removeAllNonBaseQueries()
    }
}
