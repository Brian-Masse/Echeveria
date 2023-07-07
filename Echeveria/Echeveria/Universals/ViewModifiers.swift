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

private struct UniversalColoredBackground: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    let color: Color
    
    func body(content: Content) -> some View {
        ZStack(alignment: colorScheme == .light ? .top : .bottom) {
            if colorScheme == .light {
                LinearGradient(colors: [color.opacity(0.8), .clear], startPoint: .top, endPoint: .bottom )
                    .frame(maxHeight: 800)
            } else {
                LinearGradient(colors: [color.opacity(0.4), .clear], startPoint: .bottom, endPoint: .top )
                    .frame(maxHeight: 800)
            }
        
            content
        }
        .universalBackground(padding: false)
        .ignoresSafeArea()
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
            .background(.ultraThinMaterial)
        
        
//            .scrollContentBackground(.hidden)
    }
}

private struct UniversalFormSection: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var model = EcheveriaModel.shared
    
    func body(content: Content) -> some View {
        content
            .padding()
            .tint(model.activeColors.last ?? Colors.main)
            .universalTextStyle()
            .rectangularBackgorund()
//            .scrollContentBackground(.hidden)
            .padding(.bottom)
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

private struct ColoredChart: ViewModifier {
    
    @State var dictionary: Dictionary<String, Color> = Dictionary()
    let series: [String]
    let primaryColor: Color
    
    func body(content: Content) -> some View {
        
        content
            .chartForegroundStyleScale { value in dictionary[value] ?? .red }
            .onAppear {
                var dic: Dictionary<String, Color> = Dictionary()
                if series.count == 0 { return }
                for i in 0..<series.count  {
                    let key: String =  series[i]
                    dic[key] =  Colors.getPallette(from: primaryColor)[ i ]
                }
                self.dictionary = dic
            }
    }
}

private struct RectangularBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var model = EcheveriaModel.shared
    
    let rounded: Bool
    let radius: CGFloat?

    private func getRadius() -> CGFloat {
        if let radius = radius { return radius}
        return rounded ? 100 : Constants.UIDefaultCornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(.thinMaterial)
            .foregroundColor(  ( model.activeColors.last ?? Colors.main ).opacity(0.6))
            .foregroundStyle(.ultraThickMaterial)
            .cornerRadius(getRadius())
    }
}

private struct OpaqueRectangularBackground: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(colorScheme == .light ? .white : Colors.darkGrey )
            .cornerRadius(Constants.UIDefaultCornerRadius)
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
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
    
    func universalColoredBackground(_ color: Color) -> some View {
        modifier(UniversalColoredBackground(color: color))
    }
    
    func universalForeground(not reveresed: Bool = false) -> some View {
        modifier(UniversalForeground(reversed: reveresed))
    }
    
    func universalTextStyle() -> some View {
        modifier(UniversalTextStyle())
    }
    
    func rectangularBackgorund(rounded: Bool = false, radius: CGFloat? = nil) -> some View {
        modifier(RectangularBackground(rounded: rounded, radius: radius))
    }
    
    func opaqueRectangularBackground() -> some View {
        modifier(OpaqueRectangularBackground())
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
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
    
    func coloredChart(_ series: [String], color: Color) -> some View {
        modifier( ColoredChart(series: series, primaryColor: color) )
    }
    
    func onBecomingVisible(perform action: @escaping () -> Void) -> some View {
        modifier(BecomingVisible(action: action))
    }
}
