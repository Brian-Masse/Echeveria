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
        case other  = "other"
        case smash  = "smash"
        case magic  = "magic"
        
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
    
//    MARK: Permissions
    func updatePermissions(id: String ) async {
        let realmManager = EcheveriaModel.shared.realmManager
        await realmManager.profileQuery.addQuery(id + QuerySubKey.games.rawValue) { query in
            query.ownerID.in( self.players )
        }
        
        await realmManager.gameDataNodesQuery.removeAllNonBaseQueries()
        await realmManager.gameDataNodesQuery.addQuery { query in
            query.ownerID == self._id.stringValue
        }
    }
    
    func closePermissions(id: String) async {
        let realmManager = EcheveriaModel.shared.realmManager
        
        await realmManager.gamesQuery.removeQuery(id + QuerySubKey.games.rawValue)
        await realmManager.gameDataNodesQuery.removeAllNonBaseQueries()
        
    }
    
    
//    MARK: Convenience Functions
    static func getGameObject(from id: String) -> EcheveriaGame? {
        let results: Results<EcheveriaGame> = EcheveriaModel.retrieveObject { query in
            query.ownerID == id
        }
        guard let game = results.first else { print( "No game exists with the given id: \(id)" ); return nil }
        return game
    }
    
    static func sort(_ games: [EcheveriaGame]) -> [EcheveriaGame] {
        games.sorted { game1, game2 in game2.date > game1.date }
    }
    
    static func getGameColor( _ game: String ) -> Color {
        if game == GameType.smash.rawValue { return .red }
        if game == GameType.magic.rawValue { return .blue }
        if game == GameType.other.rawValue { return Colors.forestGreen }
        return .gray
    }
    
//    MARK: Class Methods
    
    subscript (key: String) -> String {
        gameData.first { node in node.key == key }?.data ?? "No entry"
        
    }
    
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
