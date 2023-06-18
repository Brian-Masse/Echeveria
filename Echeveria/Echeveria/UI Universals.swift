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
    
    enum Orientation {
        case horizontal
        case vertical
    }
    
    let orientation: Orientation
    let text: String
    let icon: String
    let action: () -> Void
    
    init( text: String, icon: String, orientation: Orientation = .horizontal,  action: @escaping ()->Void = {} ) {
        self.orientation = orientation
        self.text = text
        self.icon = icon
        self.action = action
    }

    var body: some View {
        ZStack {
            if orientation == .vertical {
                VStack {
                    Text(text)
                    Image(systemName: icon)
                }
            }
            if orientation == .horizontal {
                HStack {
                    Image(systemName: icon)
                    Text(text)
                }
            }
        }
        .padding()
        .background(
            Rectangle()
                .foregroundColor(.clear)
                .cornerRadius(10)
        )
        .onTapGesture { self.action() }
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
        }.padding(.bottom)
    }
}
