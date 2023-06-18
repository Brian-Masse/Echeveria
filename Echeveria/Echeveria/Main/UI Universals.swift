//
//  UI Universals.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import SwiftUI

class Colors {
    static let lightGrey = Color(red: 0.95, green: 0.95, blue: 0.95)
    
}

struct NamedButton: View {
    enum Direction {
        case horizontal
        case vertical
    }
    
    let alignment: Direction
    let text: String
    let systemImage: String
    let reversed: Bool
    
    init( _ text: String, and systemImage: String, oriented alignment: Direction, reversed: Bool = false ) {
        self.text = text
        self.systemImage = systemImage
        self.alignment = alignment
        self.reversed = reversed
    }
    
    var body: some View {
        ZStack {
            if alignment == .vertical {
                VStack {
                    if reversed { Text(text) }
                    Image(systemName: systemImage)
                    if !reversed { Text(text) }
                }
            }else {
                HStack {
                    if reversed { Image(systemName: systemImage) }
                    Text(text)
                    if !reversed { Image(systemName: systemImage) }
                }
            }
        }
        .padding(5)
        .background(RoundedRectangle(cornerRadius: 5).stroke())
    }
}

struct RoundedButton: View {
    
    let label:  String
    let icon:   String
    let action: ()->Void
    
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: icon)
            Text(label)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 5)
        .background(
            Rectangle()
                .foregroundColor(.blue)
                .cornerRadius(50)
                .onTapGesture { action() }
        )
    }
}

struct LabeledHeader: View {
    
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: icon)
            Text(title)
            Spacer()
        }.padding(.horizontal)
    }
}
