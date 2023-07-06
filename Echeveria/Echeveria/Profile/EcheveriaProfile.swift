//
//  User.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import RealmSwift
import SwiftUI

class EcheveriaProfile: Object, Identifiable {
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var ownerID: String = ""
    
    @Persisted var firstName: String = ""
    @Persisted var lastName: String = ""
    @Persisted var userName: String = ""
    @Persisted var icon: String = ""
    
    @Persisted var r: Double = 0
    @Persisted var g: Double = 0
    @Persisted var b: Double = 0
    
    @Persisted var createdDate: Date = .now
    
    @Persisted var gamePreferences: RealmSwift.List<GameDataNode> = List()
    
    @Persisted var groups: RealmSwift.List<EcheveriaGroup> = RealmSwift.List()
    @Persisted var favoriteGroups: RealmSwift.List<String> = RealmSwift.List()
    @Persisted var favoriteGames: RealmSwift.List<String> = RealmSwift.List()
    
    @Persisted var friendRequests: RealmSwift.List<String> = RealmSwift.List()
    @Persisted var friendRequestDates: RealmSwift.List<Date> = RealmSwift.List()
    @Persisted var friends: RealmSwift.List<String> = RealmSwift.List()
    
    var loaded: Bool = false
    
    convenience init(ownerID: String, firstName: String, lastName: String, userName: String, icon: String, color: Color) {
        self.init()
        self.ownerID = ownerID
        self.firstName = firstName
        self.lastName = lastName
        self.userName = userName
        self.icon = icon
        
        let components = color.components
        self.r = components.red
        self.g = components.green
        self.b = components.blue
        
        self.loaded = false
        
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
    
    func checkFriend( _ profileID: String ) -> Bool {
        self.friends.contains(where: { string in string == profileID })
    }
    
    func hasBeenRequested(by profileID: String) -> Bool {
        self.friendRequests.contains(where: { string in string == profileID })
    }
    
//        A collection of all the groupIDs of each group you are a part of
    func getGroupIDs(_ groups: [EcheveriaGroup]? = nil) -> [ObjectId] {
        DispatchQueue.main.sync {
            if let passedGroups = groups { return passedGroups.reduce([]) { partialResult, group in partialResult + [group._id] } }
            return self.groups.reduce([]) { partialResult, group in partialResult + [group._id] }
        }
    }
    
    func getColor() -> Color {
        Color(red: r, green: g, blue: b)
    }
    
    func getFavoriteGames(from allGames: Results<EcheveriaGame>) -> [EcheveriaGame] {
        Array(allGames.filter { game in self.favoriteGames.contains { str in game._id.stringValue == str } })
    }
    
    func createPreferencesDictionary() -> Dictionary<String, String> {
        var dic: Dictionary<String, String> = Dictionary()
        for node in gamePreferences {
            dic[ node.key ] = node.data
        }
        return dic
    }
    
    func getGameDataNode(_ key: String) -> GameDataNode? {
        return gamePreferences.first { node in
            node.key == key
        }
        
    }
    
//    MARK: Class Methods
    func updateInformation( firstName: String, lastName: String, userName: String, icon: String, color: Color, preferences: Dictionary<String, String>) {
        EcheveriaModel.updateObject(self) { thawed in
            thawed.firstName = firstName
            thawed.lastName = lastName
            thawed.userName = userName
            thawed.icon = icon
        
            let components = color.components
            thawed.r = components.red
            thawed.g = components.green
            thawed.b = components.blue
            
            var gamePreferences: [GameDataNode] = []
            for pair in preferences {
                if let node = thawed.gamePreferences.first(where: { node in node.key == pair.key }) {
                    node.data = pair.value
                } else { gamePreferences.append( GameDataNode(ownerID: thawed.ownerID, gameOwnerID: "", key: pair.key, data: pair.value) ) }
            }
            thawed.gamePreferences.append(objectsIn: gamePreferences)
            
            thawed.loaded = false
            EcheveriaModel.shared.triggerReload = true
        }
    }
    
    //    MARK: Group Functions
    func joinGroup(_ groupID: ObjectId) {
        guard let group = EcheveriaGroup.getGroupObject(from: groupID) else { return }
        EcheveriaModel.updateObject(self) { thawed in
            if thawed.groups.contains(group) { return }
            thawed.groups.append(group)
        }
    }
    
    func leaveGroup(_ group: EcheveriaGroup) {
        EcheveriaModel.updateObject(self) { thawed in
            if let groupIndex = thawed.groups.firstIndex(of: group) { thawed.groups.remove(at: groupIndex) }
            
            unfavoriteGroup(group)
            
//            for gameID in thawed.favoriteGames {
//                if let game = EcheveriaGame.getGameObject(from: gameID) {
//                    if game.groupID.stringValue == group._id.stringValue { unfavoriteGame(game) }
//                }
//            }
        }
    }

    func favoriteGroup( _ group: EcheveriaGroup ) {
        if self.favoriteGroups.contains(where: { str in str == group._id.stringValue }) { return }
        EcheveriaModel.updateObject(self) { thawed in
            thawed.favoriteGroups.append( group._id.stringValue )
        }
    }
    
    func unfavoriteGroup( _ group: EcheveriaGroup ) {
        EcheveriaModel.updateObject(self) { thawed in
            if let index = thawed.favoriteGroups.firstIndex(of: group._id.stringValue) {
                thawed.favoriteGroups.remove(at: index)
            }
        }
    }
    
    func favoriteGame( _ game: EcheveriaGame ) {
        if self.favoriteGames.contains(where: { str in str == game._id.stringValue }) { return }
        EcheveriaModel.updateObject(self) { thawed in
            thawed.favoriteGames.append( game._id.stringValue )
        }
    }
    
    func unfavoriteGame( _ game: EcheveriaGame ) {
        EcheveriaModel.updateObject(self) { thawed in
            if let index = thawed.favoriteGames.firstIndex(of: game._id.stringValue) {
                thawed.favoriteGames.remove(at: index)
            }
        }
    }
    
//    MARK: Friend Functions
    private func addFriendRequest( _ requestingID: String ) {
        
        if self.friendRequests.contains(where: { str in str == requestingID }) { return }
        
        EcheveriaModel.updateObject(self) { thawed in
            thawed.friendRequests.append( requestingID )
            thawed.friendRequestDates.append(.now)
        }
    }
    
    func requestFriend(_ requestedFriend: EcheveriaProfile ) {
        requestedFriend.addFriendRequest( self.ownerID )
    }
    
    func acceptFriend( _ acceptedProfileID: String, index: Int ) {
        
        if index >= self.friendRequests.count { return }
        let id = self.friendRequests[index]
        if id != acceptedProfileID { return }
        
        self.removeFriendRequest(acceptedProfileID)
        
        if let profile = EcheveriaProfile.getProfileObject(from: acceptedProfileID) {
            EcheveriaModel.updateObject(self) { thawed in
                thawed.friends.append( acceptedProfileID )
            }
            
            profile.addFriend( self.ownerID )            
        }
    }
    
    private func addFriend(_ profileID: String) {
//        if they also requested to follow you, delete that request
        self.removeFriendRequest(profileID)
        
        EcheveriaModel.updateObject(self) { thawed in
            thawed.friends.append( profileID )
        }
    }
    
    private func removeFriendRequest( _ id: String ) {
        if let index = self.friendRequests.firstIndex(of: id) {
            EcheveriaModel.updateObject(self) { thawed in
                thawed.friendRequests.remove(at: index)
                thawed.friendRequestDates.remove(at: index)
            }
        }
    }
    
    func removeFriend( _ id: String, first: Bool = true ) {
        if let index = self.friends.firstIndex(of: id) {
            EcheveriaModel.updateObject(self) { thawed in
                thawed.friends.remove(at: index)
            }
        }
        if first {
            if let profile = EcheveriaProfile.getProfileObject(from: id) {
                profile.removeFriend( self.ownerID, first: false )
            }
        }
    }
    
//    MARK: Permissions
    func updatePermissions(groups: [EcheveriaGroup], friendRequests: [String], friends: [String], id: String) async {
        
        if loaded { return }
        let realmManager = EcheveriaModel.shared.realmManager
        
//        A collection of every member of every group that you are a part of
        var totalMembers: [String] = groups.reduce([id]) { partialResult, group in partialResult + group.members }
        
        totalMembers.append(contentsOf: friendRequests)
        totalMembers.append(contentsOf: friends)
        let totalGroupIDs = self.getGroupIDs(groups)
    
        await realmManager.profileQuery.addQuery(id + QuerySubKey.account.rawValue) { query in
            query.ownerID.in(totalMembers)
        }
//        Add all of this user's groups
        await realmManager.groupQuery.addQuery(id + QuerySubKey.groups.rawValue) { query in
            query.members.contains(id)
        }
        
//        Get every game that is in any group you're in, and that has you as a player
        await realmManager.gamesQuery.addQuery(id + QuerySubKey.games.rawValue) { query in
            query.groupID.in(totalGroupIDs) && query.players.contains( self.ownerID )
        }
        
        DispatchQueue.main.sync { loaded = true }
    }
    
    func closePermission(ownerID: String) async {
//        TODO: This should technically also clear all the profiles except this active one, but I don't feel like coding that rn, and its not essential :)
        
        DispatchQueue.main.sync {
            loaded = false
            EcheveriaModel.shared.removeActiveColor()
        }
        
        if ownerID != EcheveriaModel.shared.activeID {
            let realmManager = EcheveriaModel.shared.realmManager
            await realmManager.profileQuery.removeQuery(ownerID + QuerySubKey.account.rawValue)
            await realmManager.groupQuery.removeQuery(ownerID + QuerySubKey.groups.rawValue)
            await realmManager.gamesQuery.removeQuery(ownerID + QuerySubKey.games.rawValue)
        }
    }
    
    func refreshGamePermissions(id: String, groups: [EcheveriaGroup]) async {
        
        let realmManager = EcheveriaModel.shared.realmManager
        let totalGroupIDs = self.getGroupIDs(groups)
        let queryKey = id + QuerySubKey.games.rawValue
        
//        create a temp subscription
        await realmManager.gamesQuery.addQuery("temp") { query in
            query.groupID.in(totalGroupIDs) && query.players.contains( self.ownerID )
        }
        await realmManager.gamesQuery.removeQuery(queryKey)
        
//        create the real subscription
        await realmManager.gamesQuery.addQuery(queryKey) { query in
            query.groupID.in(totalGroupIDs) && query.players.contains( self.ownerID )
        }
        await realmManager.gamesQuery.removeQuery("temp")
        
    }
    
    func getAllowedGames(from games: Results<EcheveriaGame>) -> [EcheveriaGame] {
        Array(games.where { game in game.players.contains( self.ownerID ) })
    }
    
    func getAllowedGroups(from groups: Results<EcheveriaGroup>) -> [EcheveriaGroup] {
        Array(groups.filter { group in group.members.contains { str in str == self.ownerID } })
    }
    
//    MARK: Graphing Helper Functions
    struct WinDataPoint: Hashable {
        let winCount: Int
        let totalCount: Int
        let game: EcheveriaGame.GameType
    }
    
    func getWins(in date: Date, games: [EcheveriaGame]) -> [WinDataPoint] {
        
        var data: [ WinDataPoint ] = []
        
        for content in EcheveriaGame.GameType.allCases {
            let counts = games.countAllThatSatisfy { game in game.type.strip() == content.rawValue.strip() } subQuery: {
                game in game.winners.contains(where: {str in str.strip() == self.ownerID.strip() })
            }
            data.append( .init(winCount: counts.1, totalCount: counts.0, game: content) )
        }
        return data 
    }
    
    struct WinStreakDataPoint: Hashable {
        let streak: Int
        let type: String
        let date: Date
    }
    
    func getWinStreakData( games: [EcheveriaGame], profileID: String, byType: Bool = true ) -> [WinStreakDataPoint] {
        
        var data: [WinStreakDataPoint] = []
        var dic: Dictionary<String, Int> = Dictionary()
        let sorted = EcheveriaGame.sort(games)
        
        for type in EcheveriaGame.GameType.allCases { dic[type.rawValue] = 0 }
    
        for game in sorted {
            
            if game.winners.contains(where: { str in str == profileID })  {
                dic[byType ? game.type : "-"]! += 1
            } else { dic[byType ? game.type : "-"] = 0 }
            
            for type in EcheveriaGame.GameType.allCases {
                data.append(.init(streak: dic[byType ? type.rawValue : "-"]!, type: type.rawValue, date: game.date))
            }
        }
        return data
    }
    
    func getLongestWinStreak(from games: [EcheveriaGame], profileID: String) -> Int {
        
        let winStreakData = getWinStreakData(games: games, profileID: profileID, byType: false)
        
        var streak: Int = 0
//        var startDate: Date = .now
//        var endDate: Date = .now
        
        for data in winStreakData {
            streak = max(streak, data.streak)
        }
        return streak
    }
}
