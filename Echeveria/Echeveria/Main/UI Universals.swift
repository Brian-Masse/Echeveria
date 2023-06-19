//
//  UI Universals.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import SwiftUI

//MARK: Classes
class Colors {
    static let lightGrey = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let darkGrey = Color(red: 0.1, green: 0.1, blue: 0.1)
    
    static let tint = Color.blue
}

class UIUniversals {
    static func font( _ size: CGFloat ) -> Font {
        return Font.custom("Helvetica", size: size).bold()
    }
}


//MARK: View Modifiers
struct UniversalBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content.padding(5).background(colorScheme == .light ? Colors.lightGrey : .black)
    }
}

struct UniversalForeground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let reversed: Bool
    func body(content: Content) -> some View {
        if !reversed { return content.foregroundColor(colorScheme == .light ? .white : Colors.darkGrey) }
        return content.foregroundColor(colorScheme == .light ? Colors.darkGrey : .white )
    }
}

struct UniversalForm: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .ignoresSafeArea()
            .tint(Colors.tint)
            .scrollContentBackground(.hidden)
    }
}

struct UniversalFormSection: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content.listRowBackground(colorScheme == .light ? .white : Colors.darkGrey )
    }
}

extension View {
    func universalBackground() -> some View {
        modifier(UniversalBackground())
    }
    
    func universalForeground(not reveresed: Bool = false) -> some View {
        modifier(UniversalForeground(reversed: reveresed))
    }
    
    func universalForm() -> some View {
        modifier(UniversalForm())
    }
    
    func universalFormSection() -> some View {
        modifier(UniversalFormSection())
    }
}


//MARK: Universal Objects
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
        .background(
            ZStack { RoundedRectangle(cornerRadius: 5).stroke() }
        )
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
                .foregroundColor(Colors.tint)
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

struct AsyncLoader: View {
    
    let openningTask: () async -> Void
    let closingTask: () async -> Void
    
    @State var loading: Bool = true
    @State var leaving: Bool = false
    
    var body: some View {
        VStack {
            if loading {
                ProgressView()
                    .task {
                        await openningTask()
                        loading = false
                    }
            }
            if leaving { ProgressView().task { await closingTask() } }
        }.onDisappear { leaving = true }
    }
    
}
