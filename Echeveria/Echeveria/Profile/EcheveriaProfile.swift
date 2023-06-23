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
    @Persisted var icon: String = ""
    
    @Persisted var createdDate: Date = .now
    
    @Persisted var groups: List<EcheveriaGroup> = List()
    @Persisted var friends: List<String> = List()
    
    var loaded: Bool = false
    
    convenience init(ownerID: String, firstName: String, lastName: String, userName: String, icon: String) {
        self.init()
        self.ownerID = ownerID
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
        self.icon = icon
    }
    
//    MARK: Conveinience Functions
    static func getProfileObject(from ownerID: String) -> EcheveriaProfile? {
        let results: Results<EcheveriaProfile> = EcheveriaModel.retrieveObject { query in
            query.ownerID == ownerID
        }
        guard let profile = results.first else { print( "No profile exists with the given id: \(ownerID)" ); return nil }
        
        return profile   
    }
    
    static func getName(from ownerID: String) -> String {
        let result = EcheveriaProfile.getProfileObject(from: ownerID)!
        return result.firstName
    }
    
//        A collection of all the groupIDs of each group you are a part of
    func getGroupIDs(_ groups: [EcheveriaGroup]? = nil) -> [ObjectId] {
        if let passedGroups = groups { return passedGroups.reduce([]) { partialResult, group in partialResult + [group._id] } }
        return self.groups.reduce([]) { partialResult, group in partialResult + [group._id] }
    }
    
//    MARK: Class Methods
    func updateInformation( firstName: String, lastName: String, userName: String, icon: String ) {
        EcheveriaModel.updateObject(self) { thawed in
            thawed.firstName = firstName
            thawed.lastName = lastName
            thawed.userName = userName
            thawed.icon = icon
        }
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
    
//    MARK: Permissions
    func updatePermissions(groups: [EcheveriaGroup], id: String) async {
        
        if loaded { return }
        let realmManager = EcheveriaModel.shared.realmManager
        
//        A collection of every member of every gropu that you are a part of
        let totalMembers: [String] = groups.reduce([]) { partialResult, group in partialResult + group.members }
        let totalGroupIDs = self.getGroupIDs(groups)
    
        await realmManager.profileQuery.addQuery(id + QuerySubKey.account.rawValue) { query in
            query.ownerID.in(totalMembers)
        }
//        Add all of this user's groups
        await realmManager.groupQuery.addQuery(id + QuerySubKey.groups.rawValue) { query in
            query.owner == self.ownerID
        }
        
//        Get every game that is in any group you're in, and that has you as a player
        await realmManager.gamesQuery.addQuery(id + QuerySubKey.games.rawValue) { query in
            query.groupID.in(totalGroupIDs) && query.players.contains( self.ownerID )
        }
        
        loaded = true
    }
    
    func closePermission(ownerID: String) async {
//        TODO: This should technically also clear all the profiles except this active one, but I don't feel like coding that rn, and its not essential :)
        
        let realmManager = EcheveriaModel.shared.realmManager
        await realmManager.profileQuery.removeQuery(ownerID)
        await realmManager.groupQuery.removeQuery(ownerID)
        await realmManager.gamesQuery.removeQuery(ownerID)
        
        loaded = false
    }
    
    func getAllowedGames(from games: Results<EcheveriaGame>) -> [EcheveriaGame] {
        Array(games.filter { game in
            self.getGroupIDs().contains { id in
                id == game.groupID
            }
        })
    }
    
//    MARK: Graphing Helper Functions
    struct WinDataPoint {
        let winCount: Int
        let totalCount: Int
        let game: EcheveriaGame.GameType
    }
    
    func getWins(in date: Date, games: [EcheveriaGame]) -> [WinDataPoint] {
        
        var data: [ WinDataPoint ] = []
        
        for content in EcheveriaGame.GameType.allCases {
            let counts = games.countAllThatSatisfy { game in game.type == content.rawValue } subQuery: { game in game.winners.contains(where: {str in str == self.ownerID }) }
            data.append( .init(winCount: counts.1, totalCount: counts.0, game: content) )
        }
        return data 
    }
}

extension Collection {
    func countAllThatSatisfy( mainQuery: (Self.Element) -> Bool, subQuery: ((Self.Element) -> Bool)? = nil ) -> (Int,Int) {
        var mainCounter = 0
        var subCounter = 0
        for element in self {
            if mainQuery(element) {
                mainCounter += 1
                if subQuery != nil {
                    if subQuery!(element) { subCounter += 1 }
                }
            }
        }
        return (mainCounter, subCounter)
    }
    
    func returnFirst( _ number: Int ) -> [ Self.Element ] {
        var returning: [Self.Element] = []
        if self.count == 0 { return returning }
        for i in 0..<Swift.min(self.count, number) {
            returning.append( self[i as! Self.Index] )
        }
        return returning
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

