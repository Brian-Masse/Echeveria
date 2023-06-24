//
//  ViewModifiers.swift
//  Echeveria
//
//  Created by Brian Masse on 6/23/23.
//

import Foundation
import SwiftUI

//MARK: View Modifiers
private struct UniversalBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    let padding: Bool
    
    func body(content: Content) -> some View {
        content.padding( padding ? 15 : 0 ).background(colorScheme == .light ? Colors.lightGrey : .black)
    }
}

private struct UniversalForeground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    let reversed: Bool
    func body(content: Content) -> some View {
        if !reversed { return content.foregroundColor(colorScheme == .light ? .white : Colors.darkGrey) }
        return content.foregroundColor(colorScheme == .light ? Colors.darkGrey : .white )
    }
}

private struct UniversalTextStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content.foregroundColor(colorScheme == .light ? .black : .white)
    }
}

private struct UniversalForm: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content
            .ignoresSafeArea()
            .tint(Colors.tint)
            .scrollContentBackground(.hidden)
    }
}

private struct UniversalFormSection: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    func body(content: Content) -> some View {
        content.listRowBackground(colorScheme == .light ? .white : Colors.darkGrey )
    }
}

private struct UniversalChart: ViewModifier {
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

private struct RectangularBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background( Rectangle()
                .cornerRadius(Constants.UIDefaultCornerRadius)
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
    func universalBackground(padding: Bool = true) -> some View {
        modifier(UniversalBackground( padding: padding ))
    }
    
    func universalForeground(not reveresed: Bool = false) -> some View {
        modifier(UniversalForeground(reversed: reveresed))
    }
    
    func universalTextStyle() -> some View {
        modifier(UniversalTextStyle())
    }
    
    func rectangularBackgorund() -> some View {
        modifier(RectangularBackground())
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
