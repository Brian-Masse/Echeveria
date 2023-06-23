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
        return Font.custom("Helvetica", size: size)
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

struct UniversalTextStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content.foregroundColor(colorScheme == .light ? .black : .white)
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

struct UniversalChart: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .padding()
            .padding(.top, 20)
            .background( Rectangle()
                .cornerRadius(20)
                .universalForeground()
            )
    }
}

private struct BecomingVisible: ViewModifier {
    
    @State var action: (() -> Void)?

    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: VisibleKey.self,
                        // See discussion!
                        value: UIScreen.main.bounds.intersects(proxy.frame(in: .global))
                    )
                    .onPreferenceChange(VisibleKey.self) { isVisible in
                        guard isVisible, let action else { return }
                        action()
//                        action = nil
                    }
            }
        }
    }

    struct VisibleKey: PreferenceKey {
        static var defaultValue: Bool = false
        static func reduce(value: inout Bool, nextValue: () -> Bool) { }
    }
}

extension View {
    func universalBackground() -> some View {
        modifier(UniversalBackground())
    }
    
    func universalForeground(not reveresed: Bool = false) -> some View {
        modifier(UniversalForeground(reversed: reveresed))
    }
    
    func universalTextStyle() -> some View {
        modifier(UniversalTextStyle())
    }
    
    func universalForm() -> some View {
        modifier(UniversalForm())
    }
    
    func universalFormSection() -> some View {
        modifier(UniversalFormSection())
    }
    
    func universalChart() -> some View {
        modifier(UniversalChart())
    }
    
    func onBecomingVisible(perform action: @escaping () -> Void) -> some View {
        modifier(BecomingVisible(action: action))
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

struct CircularButton: View {
    
//    let label:  String
    let icon:   String
    let action: ()->Void
    
    var body: some View {
        HStack {
            Image(systemName: icon)
//            Text(label)
        }
        .padding(5)
        .background(
            Rectangle()
                .foregroundColor(Colors.tint)
                .cornerRadius(50)
                .onTapGesture { action() }
        )
    }
}

struct AsyncRoundedButton: View {
    
    let label: String
    let icon: String
    let action: () async -> Void
    
    @State var running: Bool = false
    
    var body: some View {
        ZStack {
            RoundedButton(label: label, icon: icon, action: { running = true })
            if running {
                ProgressView()
                    .task {
                        await action()
                        running = false
                    }
            }
        }
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

struct UniversalText: View {
 
    let text: String
    let size: CGFloat
    let bold: Bool
    let wrap: Bool
    
    init(_ text: String, size: CGFloat, wrap: Bool = false, _ bold: Bool = false) {
        self.text = text
        self.size = size
        self.bold = bold
        self.wrap = wrap
    }
    
    var body: some View {
        
        Text(text)
            .universalTextStyle()
            .fixedSize()
//            .minimumScaleFactor(0.5)
            .lineLimit(3)
            .font(Font.custom("Helvetica", size: size) )
            .bold(bold)
    }
    
}

struct AsyncLoader<Content>: View where Content: View {
    
    let block: () async -> Void
    let content: Content
    
    @State var loading: Bool = true
    
    init( block: @escaping () async -> Void, @ViewBuilder content: @escaping () -> Content ) {
        self.content = content()
        self.block = block
    }

    var body: some View {
        VStack{
            if loading {
                ProgressView()
                    .task {
                        await block()
                        loading = false
                    }
            } else { content }
        }.onBecomingVisible {
            loading = true
        }
    }
}
