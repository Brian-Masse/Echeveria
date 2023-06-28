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
    @Persisted var favoriteGroups: List<String> = List()
    
    @Persisted var friendRequests: List<String> = List()
    @Persisted var friendRequestDates: List<Date> = List()
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
    
    func checkFriend( _ profileID: String ) -> Bool {
        self.friends.contains(where: { string in string == profileID })
    }
    
    func hasBeenRequested(by profileID: String) -> Bool {
        self.friendRequests.contains(where: { string in string == profileID })
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
        
//        A collection of every member of every gropu that you are a part of
        var totalMembers: [String] = groups.reduce([]) { partialResult, group in partialResult + group.members }
        totalMembers.append(contentsOf: friendRequests)
        totalMembers.append(contentsOf: friends)
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
        await realmManager.profileQuery.removeQuery(ownerID + QuerySubKey.account.rawValue)
        await realmManager.groupQuery.removeQuery(ownerID + QuerySubKey.groups.rawValue)
        await realmManager.gamesQuery.removeQuery(ownerID + QuerySubKey.games.rawValue)
        
        loaded = false
    }
    
    func getAllowedGames(from games: Results<EcheveriaGame>) -> [EcheveriaGame] {
        return Array(games.filter { game in
            self.getGroupIDs().contains { id in
                id == game.groupID
            }
        })
    }
    
    func getAllowedGroups(from groups: Results<EcheveriaGroup>) -> [EcheveriaGroup] {
        Array(groups.filter { group in
            group.members.contains { strID in
                strID == self.ownerID
            }
        })
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
            let counts = games.countAllThatSatisfy { game in game.type == content.rawValue } subQuery: { game in game.winners.contains(where: {str in str == self.ownerID }) }
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
