//
//  UI Universals.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import SwiftUI

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

//MARK: Buttons
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
    let icon:   String
    let action: ()->Void
    
    var body: some View {
        Image(systemName: icon)
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

struct AsynCircularButton: View {
    let icon: String
    let action: () async -> Void
    
    @State var running: Bool = false
    
    var body: some View {
        ZStack {
            CircularButton(icon: icon, action: { running = true })
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

//MARK: UniversalText
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
//            .fixedSize()
            .lineLimit(3)
            .font(Font.custom("Helvetica", size: size) )
            .bold(bold)
    }
}

//MARK: ResizeableIcon
struct ResizeableIcon: View {
    let icon: String
    let size: CGFloat
    
    var body: some View {
        Image(systemName: icon)
            .resizable()
            .frame(width: size, height: size)
    }
    
}


//MARK: AsyncLoader
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
                ProgressView() .task {
                        await block()
                        loading = false
                    }
            } else { content }
        }.onBecomingVisible { loading = true }
    }
}
