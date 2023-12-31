//
//  UniversalConstants.swift
//  Echeveria
//
//  Created by Brian Masse on 6/23/23.
//

import Foundation
import SwiftUI
import UIKit

class Colors {
    static var tint: Color { EcheveriaModel.shared.activeColors.last ?? main }
    
    
    static var main: Color { forestGreen }
    static var groupMain: Color { .gray }
    
    static let lightGrey = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let darkGrey = Color(red: 0.1, green: 0.1, blue: 0.1).opacity(0.9)
    static let forestGreen = makeColor(80, 120, 87)
    static let deepPurple = makeColor( 91, 45, 234 )
    static let roseGold =  makeColor( 223, 143, 133 )
    static let orange   =  makeColor(239, 140, 86)
    static let oceanBlue = makeColor( 61, 79, 110 )
    static let beige    = makeColor( 122, 104, 89 )
    static let sunnDelight = makeColor( 196, 188, 126 )
    
    static let colorOptions: [Color] = [ forestGreen, .blue, oceanBlue, deepPurple, roseGold, orange, .red, beige, .gray ]
    
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
        
        return ColorPallette(baseColor: color, [])
    }
    
    private static func makeColor( _ r: CGFloat, _ g: CGFloat, _ b: CGFloat ) -> Color {
        Color(red: r / 255, green: g / 255, blue: b / 255)
    }
    
}

//MARK: ColorPallette
class ColorPallette {
    
    let mainColors: [Color]
    let baseColor: Color
    
    init( baseColor: Color, _ mainColors: [Color]) {
        self.mainColors = mainColors
        self.baseColor = baseColor
    }
    
    private func getColorScheme() -> UIUserInterfaceStyle {
        let viewController = UIViewController()
        return viewController.traitCollection.userInterfaceStyle
    }
    
    subscript(_ index: Int, total: Int) -> Color {
        if index < self.mainColors.count { return mainColors[index] }
        
        let fullRange: CGFloat = 1.5 // This excludes straight blacks and straight whites, which are often hard to read in the UI
        let perc = CGFloat( index ) / CGFloat(total)
        
        let colorPerc = (perc * fullRange) - (fullRange * ( getColorScheme() == .light ? 1.5 : 1) / 3  )
        
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
    static let UIFormSpacing        : CGFloat = 10
    static let UIFullScreenTopPadding: CGFloat = 45
    static let UIHoverButtonBottonPadding: CGFloat = 20
    
    
    static let HourTime: Double = 3600
    static let DayTime: Double = 86400
    
    static let isiOS164: Bool = {
        guard #available(iOS 16.4, *) else { return false }
        return true
    }()
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

extension Array {
    
    mutating func toggleValue( _ value: Self.Element ) where Self.Element: Equatable {
        if let index = self.firstIndex(where: { element in element == value }) {
            self.remove(at: index)
            return
        }
        self.append(value)
    }
}

extension String {
    
    func strip() -> String {
        self
        .lowercased()
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func strip(_ string: String) -> String {
        return string.strip()
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
