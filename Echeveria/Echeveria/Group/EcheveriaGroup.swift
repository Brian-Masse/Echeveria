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
    @Persisted var colorIndex: Int = 0
    
    @Persisted var createdDate: Date = .now
    
    var id: String { self._id.stringValue }
    
    convenience init( name: String, icon: String, description: String, colorIndex: Int ) {
        self.init()
        self.name = name
        self.icon = icon
        self.groupDescription = description
        self.createdDate = .now
        
        self.colorIndex = colorIndex
    }
    
    func updateInformation(name: String, icon: String, description: String, colorIndex: Int) {
        EcheveriaModel.updateObject(self) { thawed in
            thawed.name = name
            thawed.icon = icon
            thawed.groupDescription = description
            thawed.colorIndex = colorIndex
        }
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
    
    static func getGroupObject(from id: String) -> EcheveriaGroup? {
        let objID = try! ObjectId(string: id)
        return getGroupObject(from: objID)
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
        return Colors.colorOptions[self.colorIndex]
        
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
        
        EcheveriaModel.deleteObject( self ) { group in
            group._id == self._id
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
    }
    
    func closePermissions(id: String) async {
        let realmManager = EcheveriaModel.shared.realmManager
        
        await realmManager.profileQuery.removeQuery(id + QuerySubKey.account.rawValue)
        await realmManager.gamesQuery.removeQuery(id + QuerySubKey.games.rawValue)
    }
    
//    MARK: Graphing Helper Functions
    
    struct WinnerHistoryNode: Hashable {
        let winCount: Int
        let date: Date
        let player: EcheveriaProfile
    }
    
    func getWinnerHistory(games: [ EcheveriaGame ]) -> [ WinnerHistoryNode ] {
        var runningCounts: Dictionary<String, Int> = Dictionary()
        var history: [WinnerHistoryNode] = []
        
        for game in games {
            let winners = game.winners
            
            for winner in winners {
                if let _ = runningCounts[ winner ] { runningCounts[ winner ]! += 1 }
                else { runningCounts[ winner ] = 1 }
            }
            
            for memberID in self.members {
                let count = runningCounts[memberID]
                if let player = EcheveriaProfile.getProfileObject(from: memberID) {
                    let node = WinnerHistoryNode(winCount: count == nil ? 0 : count!, date: game.date, player: player)
                    history.append(node)
                }
            }
        }
        return history
    }
    
    struct GameCountHistoryNode: Hashable {
        let count: Int
        let date: Date
        let type: String
    }
    
    func getGameCountHistory(games: [ EcheveriaGame ]) -> [ GameCountHistoryNode ] {
        var runningCounts: Dictionary<String, Int> = Dictionary()
        var history: [GameCountHistoryNode] = []
        
        for game in games {
            
            if let _ = runningCounts[ game.type ] { runningCounts[ game.type ]! += 1 }
            else { runningCounts[ game.type ] = 1 }
            
            for type in EcheveriaGame.GameType.allCases {
                let count = runningCounts[type.rawValue]
                let node = GameCountHistoryNode(count: count == nil ? 0 : count!, date: game.date, type: type.rawValue)
                history.append(node)
            }
        }
        return history
    }
    
    struct GameCountNode: Hashable {
        let count: Int
        let type: String
        let styleData: String
    }
    
    func getGameCount(games: [EcheveriaGame], filterByPlayer: Bool = true) -> [ GameCountNode ] {
        var runningCounts: Dictionary<String, Int> = Dictionary()
        var history: [GameCountNode] = []
        
        for game in games {
            for winner in game.winners {
                if let profile = EcheveriaProfile.getProfileObject(from: winner) {
                    let key = filterByPlayer ? game.type + profile.firstName : game.type + game.experieince
                    if let _ = runningCounts[ key ] { runningCounts[ key ]! += 1 }
                    else { runningCounts[ key ] = 1 }
                }
            }
        }
        
        for type in EcheveriaGame.GameType.allCases {
            if !filterByPlayer {
                for experience in EcheveriaGame.GameExperience.allCases {
                    let count = runningCounts[type.rawValue + experience.rawValue]
                    let node = GameCountNode(count: count == nil ? 0 : count!, type: type.rawValue, styleData: experience.rawValue)
                    history.append(node)
                }
            } else {
                for memberID in self.members {
                    if let profile = EcheveriaProfile.getProfileObject(from: memberID) {
                        let count = runningCounts[type.rawValue + profile.firstName]
                        let node = GameCountNode(count: count == nil ? 0 : count!, type: type.rawValue, styleData: profile.firstName)
                        history.append(node)
                    }
                }
            }
        }
        
        
        return history
    }
}
