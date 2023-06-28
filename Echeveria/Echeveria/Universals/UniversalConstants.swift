//
//  UniversalConstants.swift
//  Echeveria
//
//  Created by Brian Masse on 6/23/23.
//

import Foundation
import SwiftUI

class Colors {
    static let tint = Color.blue
    
    static let lightGrey = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let darkGrey = Color(red: 0.1, green: 0.1, blue: 0.1)
    static let forestGreen = makeColor(80, 120, 87)
    
    static let colorOptions: [Color] = [ .red, forestGreen ]
    
    private static let reds: [Color] = [ .red, makeColor(255, 129, 120), makeColor(161, 47, 47), makeColor(230, 119, 132), makeColor(163, 82, 82)]
    private static let greens: [Color] = [ forestGreen, makeColor(47, 82, 52), makeColor(143, 161, 146), makeColor(189, 178, 128), makeColor(85, 153, 75)]
    private static let blues: [Color] = [ .blue, makeColor(29, 101, 138), .orange, makeColor(167, 207, 242), .green ]
    
    private static let redPallette: ColorPallette = ColorPallette(baseColor: .red, reds)
    private static let greenPallette: ColorPallette = ColorPallette(baseColor: forestGreen, greens)
    private static let bluePallette: ColorPallette = ColorPallette(baseColor: .blue, blues)
    private static let greyPallette: ColorPallette = ColorPallette(baseColor: .gray, [])
    
    static func getPallette(from color: Color ) -> ColorPallette {
        if color == .red { return redPallette }
        if color == forestGreen { return greenPallette }
        if color == .blue { return bluePallette }
        
        return greyPallette
    }
    
    private static func makeColor( _ r: CGFloat, _ g: CGFloat, _ b: CGFloat ) -> Color {
        Color(red: r / 255, green: g / 255, blue: b / 255)
    }
    
}

class ColorPallette {
    
    let mainColors: [Color]
    let baseColor: Color
    
    init( baseColor: Color, _ mainColors: [Color]) {
        self.mainColors = mainColors
        self.baseColor = baseColor
    }
    
    subscript(_ index: Int) -> Color {
        if index < self.mainColors.count { return mainColors[index] }
        let colorPerc = CGFloat.random(in: -1...1)
        
        let dr = abs( colorPerc > 0 ? 1 - baseColor.components.red : baseColor.components.red )
        let r = baseColor.components.red + ( colorPerc * dr )
        
        let dg = abs( colorPerc > 0 ? 1 - baseColor.components.green : baseColor.components.green )
        let g = baseColor.components.green + ( colorPerc * dg )
        
        let db = abs( colorPerc > 0 ? 1 - baseColor.components.blue : baseColor.components.blue )
        let b = baseColor.components.blue + ( colorPerc * db )
        
        return Color( red: r, green: g, blue: b )
    }
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
    
    func returnLast( _ number: Int) -> Self.SubSequence? {
    
        if self.count == 0 { return nil }
        let count = self.count - 1
        let lowerBound = Swift.max(0, count - number)
        
        return self[ (lowerBound as! Self.Index)...(count as! Self.Index) ]
    }
}


//MARK: Color Extension
extension Color {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {

        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            // You can handle the failure here as you want
            return (0, 0, 0, 0)
        }

        return (r, g, b, o)
    }

    var hex: String {
        String(
            format: "#%02x%02x%02x%02x",
            Int(components.red * 255),
            Int(components.green * 255),
            Int(components.blue * 255),
            Int(components.opacity * 255)
        )
    }
}
