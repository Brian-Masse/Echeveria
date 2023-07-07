//
//  GameTrackerCard.swift
//  Echeveria
//
//  Created by Brian Masse on 6/19/23.
//

import Foundation
import RealmSwift
import SwiftUI

class GameDataNode: Object, Identifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
//    This is the user that ultimatley owns this piece of data
    @Persisted var ownerID: String = ""
//    This is the id of the game object this piece of data belongs to
    @Persisted var gameOwnerID: String = ""
    
    @Persisted var key: String = ""
    @Persisted var data: String = ""
    
    convenience init(ownerID: String, gameOwnerID: String, key: String, data: String) {
        self.init()
        self.ownerID = ownerID
        self.gameOwnerID = gameOwnerID
        self.key = key
        self.data = data
    }
}

class EcheveriaGame: Object, Identifiable {
    
    enum GameExperience: String, CaseIterable, Identifiable {
        case outstanding  = "outstanding"
        case good  = "good"
        case fine  = "fine"
        case bad  = "bad"
        case bullshit = "bullshit"
        
        var id: String { self.rawValue }
    }
    
    enum GameType: String, CaseIterable, Identifiable {
        case smash  = "Smash"
        case magic  = "Magic"
        case spikeBall = "Spikeball"
        case bags = "Bags"
        case other  = "Other"
        
        var id: String { self.rawValue }
    }
    
    var typeEnum: GameType {
        get { GameType(rawValue: type)! }
        set { type = newValue.rawValue }
    }
    
    var experienceEnum: GameExperience {
        get { GameExperience(rawValue: type)! }
        set { experieince = newValue.rawValue }
    }
    
    static let emptyGameDataNodeTitle: String = "No entry"
    
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var ownerID: String = ""

    @Persisted var type: String = GameType.other.rawValue
    @Persisted var groupID: ObjectId = ObjectId()
    @Persisted var date: Date = .now
    
    @Persisted var players: RealmSwift.List<String> = List()
    @Persisted var winners: RealmSwift.List<String> = List()
    @Persisted var experieince: String = GameExperience.good.rawValue
    @Persisted var comments: String = ""
    
    @Persisted var gameData: RealmSwift.List<GameDataNode> = List()
    
    convenience init( _ ownerID: String, type: GameType, group: String, date: Date, players: RealmSwift.List<String>, winners: RealmSwift.List<String>, experience: GameExperience, comments: String, gameData: Dictionary<String, String> ) {
        self.init()
        self.ownerID = ownerID
        
        self.typeEnum = type
        self.groupID = try! ObjectId(string: group)
        self.date = date
        
        self.players = players
        self.winners = winners
        self.experienceEnum = experience
        self.comments = comments
        
        let gameDataArry: [GameDataNode] = gameData.map { (key: String, value: String) in
            let node = GameDataNode(ownerID: self.ownerID, gameOwnerID: self._id.stringValue, key: key, data: value)
            EcheveriaModel.addObject( node )
            return node
        }
        self.gameData.append(objectsIn: gameDataArry)
        
        EcheveriaModel.addObject(self)
    }
    
    func update( type: GameType, group: String, date: Date, players: RealmSwift.List<String>, winners: RealmSwift.List<String>, experience: GameExperience, comments: String, gameData: Dictionary<String, String>  ) {
        
        let gameDataArry: [GameDataNode] = gameData.map { (key: String, value: String) in
            let node = GameDataNode(ownerID: self.ownerID, gameOwnerID: self._id.stringValue, key: key, data: value)
            EcheveriaModel.addObject( node )
            return node
        }
        
        EcheveriaModel.updateObject(self) { thawed in
            thawed.typeEnum = type
            thawed.groupID = try! ObjectId(string: group)
            thawed.date = date
            
            thawed.players = players
            thawed.winners = winners
            thawed.experienceEnum = experience
            thawed.comments = comments
            
            thawed.gameData.append(objectsIn: gameDataArry)
        }
    }
    
//    MARK: Permissions
    func updatePermissions(id: String ) async {
        let realmManager = EcheveriaModel.shared.realmManager
        await realmManager.profileQuery.addQuery(id + QuerySubKey.games.rawValue) { query in
            query.ownerID.in( self.players )
        }
        
        await realmManager.gameDataNodesQuery.removeAllNonBaseQueries()
        await realmManager.gameDataNodesQuery.addQuery { query in
            query.ownerID == self.ownerID
        }
    }
    
    func closePermissions(id: String) async {
        let realmManager = EcheveriaModel.shared.realmManager
        
        await realmManager.gamesQuery.removeQuery(id + QuerySubKey.games.rawValue)
        await realmManager.gameDataNodesQuery.removeAllNonBaseQueries()
        
    }
    
    
//    MARK: Convenience Functions
    static func getGameObject(from id: String) -> EcheveriaGame? {
        let objID = try! ObjectId(string: id)
        let results: Results<EcheveriaGame> = EcheveriaModel.retrieveObject { query in
            query._id == objID
        }
        guard let game = results.first else { print( "No game exists with the given id: \(id)" ); return nil }
        return game
    }
    
    static func sort(_ games: [EcheveriaGame]) -> [EcheveriaGame] {
        games.sorted { game1, game2 in game2.date > game1.date }
    }
    
    func getColor( ) -> Color {
        if let winnerID = winners.first {
            if let profile = EcheveriaProfile.getProfileObject(from: winnerID) {
                return profile.getColor()
            }
        }
        return .gray
    }
    
    
    subscript (key: String) -> String {
        gameData.first { node in node.key == key }?.data ?? EcheveriaGame.emptyGameDataNodeTitle
    }
    
//    This is used when you recieve a specific list of nodes (for instance a games specifc node data) and want to search for a piece of data by key
//    It is not a general purpose accessor for getting a data node
//    Echeveria has a similar method intended to get the gameDataNodes that represent user preferences
    static func getNodeData( from key: String, in values: [ GameDataNode ]) -> String {
        values.first { node in node.key == key }?.data ?? EcheveriaGame.emptyGameDataNodeTitle
    }
    
//    These functions are for editing taking the stored properties and converting them into those recievable by the loggerView for editing the game
    func getType() -> GameType {
        GameType.allCases.first { type in
            type.rawValue.strip() == self.type.strip()
        } ?? .smash
    }
    
    func getExperience() -> GameExperience {
        GameExperience.allCases.first { type in
            type.rawValue.strip() == self.type.strip()
        } ?? .good
    }
    
    func getGameDataAsDictionary() -> Dictionary<String, String> {
        var dic = Dictionary<String, String>.init()
        for node in gameData {
            dic[ node.key ] = node.data
        }
        return dic
    }
    
//    Not sure why, but for some reason, to avoid the UI losing a valid reference of a game and dismissing all current views, its safer to instead pass around
//    game IDs and retrieve the game object only when its neccessary
//    This function takes a list of real references, converts them into strings and then returns
    static func reduceIntoStrings(from list: [EcheveriaGame]) -> [String] {
        list.map { game in game._id.stringValue }
    }
    
    
//    MARK: Class Methods
    
    func getWinners() -> String {
        if self.winners.count == 1 { return EcheveriaProfile.getName(from: self.winners.first!)  }
        var str = ""
        for i in self.winners.indices {
            if i == winners.count - 1 { str += ", and \(EcheveriaProfile.getName(from: self.winners[i]))" }
            else { str += "\(EcheveriaProfile.getName(from: self.winners[i])), " }
        }
        return str
    }
    
    func isWinner(_ id: String) -> Bool {
        self.winners.contains { str in
            str == id
        }
    }
    
//    when filtering by Winners, this will go throuhg all the cards stored in the realm, compile all the winners and format it into a list to filter by
    static func getListOfWinners() -> [String] {
        var winners: [String] = []
        let results: Results<EcheveriaGame> = EcheveriaModel.retrieveObject()
        
        for result in results {
            for winner in result.winners {
                if !winners.contains(where: { string in string == winner} ) { winners.append(winner) }
            }
        }
        
        return winners
    }
}
