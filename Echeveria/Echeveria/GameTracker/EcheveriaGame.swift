//
//  GameTrackerCard.swift
//  Echeveria
//
//  Created by Brian Masse on 6/19/23.
//

import Foundation
import RealmSwift

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
    
    @Persisted var players: List<String> = List()
    @Persisted var winners: List<String> = List()
    @Persisted var experieince: String = GameExperience.good.rawValue
    @Persisted var comments: String = ""
    
    convenience init( _ ownerID: String, type: GameType, group: EcheveriaGroup, date: Date, players: List<String>, winners: List<String>, experience: GameExperience, comments: String ) {
        self.init()
        
        self.ownerID = ownerID
        
        self.typeEnum = type
        self.groupID = group._id
        self.date = date
        
        self.players = players
        self.winners = winners
        self.experienceEnum = experience
        self.comments = comments
        
        self.registerSelf()
    }
    
    func registerSelf() {
        EcheveriaModel.addObject(self)
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
    
    static func getGameObject(from id: String) -> EcheveriaGame? {
        let results: Results<EcheveriaGame> = EcheveriaModel.retrieveObject { query in
            query.ownerID == id
        }
        guard let game = results.first else { print( "No game exists with the given id: \(id)" ); return nil }
        return game
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

