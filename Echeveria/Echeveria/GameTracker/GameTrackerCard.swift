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
    
    @Persisted var players: List<String> = List()
    @Persisted var winners: List<String> = List()
    @Persisted var experieince: String = GameExperience.good.rawValue
    @Persisted var comments: String = ""
    
    convenience init( _ ownerID: String, type: GameType, group: EcheveriaGroup, players: List<String>, winners: List<String>, experience: GameExperience, comments: String ) {
        self.init()
        
        self.ownerID = ownerID
        
        self.typeEnum = type
        self.groupID = group._id
        
        self.players = players
        self.winners = winners
        self.experienceEnum = experience
        self.comments = comments
        
        self.registerSelf()
    }
    
    func registerSelf() {
        EcheveriaModel.addObject(self)
    }
    
    static func getGameObject(from id: String) -> EcheveriaGame? {
        let results: Results<EcheveriaGame> = EcheveriaModel.retrieveObject { query in
            query.ownerID == id
        }
        guard let game = results.first else { print( "No game exists with the given id: \(id)" ); return nil }
        return game
    }
    
}

