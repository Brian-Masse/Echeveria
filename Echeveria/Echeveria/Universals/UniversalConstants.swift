//
//  UniversalConstants.swift
//  Echeveria
//
//  Created by Brian Masse on 6/23/23.
//

import Foundation
import SwiftUI

class Colors {
    static let lightGrey = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let darkGrey = Color(red: 0.1, green: 0.1, blue: 0.1)
    
    static let tint = Color.blue
}

class Constants {
    
    static let UITitleTextSize: CGFloat     = 45
    static let UIHeaderTextSize: CGFloat    = 30
    static let UISubHeaderTextSize: CGFloat = 20
    static let UIDefaultTextSize: CGFloat   = 15
    
    static let UIDefaultCornerRadius: CGFloat = 15
    
}

//MARK: Extensions

extension String: Identifiable {
    public var id: String { self }
}

extension Int: Identifiable {
    public var id: Int { self }
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
    
    func returnLast( _ number: Int) -> Self.SubSequence {
    
        let count = self.count - 1
        let lowerBound = Swift.max(0, count - number)
        
        return self[ (lowerBound as! Self.Index)...(count as! Self.Index) ]
    }
}
