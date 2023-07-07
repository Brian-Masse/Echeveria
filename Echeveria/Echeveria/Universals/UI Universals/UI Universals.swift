//
//  UI Universals.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import SwiftUI
import Charts

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

//MARK: List View
struct ListView<C: Collection, T: Identifiable, Content: View>: View where C.Element == T  {
    let title: String
    
    let collection: C
    let geo: GeometryProxy
    
    let query: (T) -> Bool
    
    @ViewBuilder var contentBuilder: (T) -> Content

    var body: some View {
        
        let filtered = collection.filter { obj in query(obj) }
        
        VStack {
            if !filtered.isEmpty {
                if title != "" { HStack {
                    UniversalText(title, size: Constants.UISubHeaderTextSize, true)
                    Spacer()
                } }
                ForEach(filtered, id: \.id) { obj in
                    contentBuilder( obj )
                }
            }
        }
    }
}

//MARK: UniversalText
struct UniversalText: View {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    
    let text: String
    let size: CGFloat
    let bold: Bool
    let wrap: Bool
    let lighter: Bool
    let fixed: Bool
    
    init(_ text: String, size: CGFloat, wrap: Bool = true, lighter: Bool = false, _ bold: Bool = false, fixed: Bool = false) {
        self.text = text
        self.size = size
        self.bold = bold
        self.wrap = wrap
        self.lighter = lighter
        self.fixed = fixed
    }
    
    var body: some View {
        
        Text(text)
            .dynamicTypeSize( ...DynamicTypeSize.accessibility1 )
    
            .lineSpacing(5)
            .minimumScaleFactor(wrap ? 1 : 0.5)
            .lineLimit(wrap ? 5 : 1)
            .font( fixed ? Font.custom("Helvetica", fixedSize: size) : Font.custom("Helvetica", size: size) )
            .bold(bold)
            .opacity(lighter ? 0.8 : 1)
    }
}

//MARK: ResizeableIcon
struct ResizeableIcon: View {
    let icon: String
    let size: CGFloat
    
    var body: some View {
        Image(systemName: icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: size)
    }
}

//MARK: Small Views

struct FilterButton: View {
    var body: some View {
        ShortRoundedButton("filter", icon: "line.3.horizontal.decrease.circle") { }
            .universalTextStyle()
    }
}


//MARK: AsyncLoader
struct AsyncLoader<Content>: View where Content: View {
    @Environment(\.scenePhase) private var scenePhase
    
    @ObservedObject var model = EcheveriaModel.shared
    
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
                    model.triggerReload = false
                    }
            } else if scenePhase != .background && scenePhase != .inactive { content }
        }
        .onBecomingVisible { loading = true }
        .onChange(of: scenePhase) { newValue in
            if newValue == .active { loading = true }
        }
        .onChange(of: model.triggerReload) { newValue in
            if newValue { loading = true }
        }
    }
}

//MARK: Graphs

struct StaticGameChart<T: Hashable, C1: Plottable, C2: Plottable, F: CaseIterable>: View where F: (Identifiable & RawRepresentable), F.AllCases: RandomAccessCollection, F.RawValue: StringProtocol, C1: Hashable {

    let title: String
    let data: [T]
    
    let XAxisTitle: String
    let XAxis: ( T ) -> C1
    
    let YAxisTitle: String
    let YAxis: ( T ) -> C2
    
    let styleTitle: String?
    let Style: (( T ) -> C1)?
    let styleCount: Int
    
    let primaryColor: Color
    
    @Binding var filter: F?
    
    init( title: String, data: [T], primaryColor: Color, XAxisTitle: String, XAxis: @escaping ( T ) -> C1, YAxisTitle: String, YAxis: @escaping ( T ) -> C2, styleTitle: String? = nil, Style: (( T ) -> C1)? = nil, styleCount: Int = 0, filter: Binding<F?>? = Optional<Binding<EcheveriaGame.GameExperience?>>.none) {
        self.title = title
        self.data = data
        self.primaryColor = primaryColor
        
        self.XAxisTitle = XAxisTitle
        self.XAxis = XAxis
        self.YAxisTitle = YAxisTitle
        self.YAxis = YAxis
        self.styleTitle = styleTitle
        self.Style = Style
        self.styleCount = styleCount
        
        self._filter = filter ?? Binding.constant(nil)
    }
    
    @State var dictionary: Dictionary<C1, Color> = Dictionary()
    
    var body: some View {
        ZStack(alignment: .top) {
            if Style == nil {
                Chart {
                    ForEach(data, id: \.self) { data in
                        BarMark(
                            x: .value(XAxisTitle, XAxis( data ) ),
                            y: .value(YAxisTitle, YAxis( data ) )
//                            width: .fixed(10)
                        ).foregroundStyle(primaryColor)
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .aligned) { value in
                        AxisValueLabel {
                            if let str = value.as(String.self) {
                                UniversalText(str, size: Constants.UIDefaultTextSize, fixed: true)
                                    .lineLimit(1)
                                    .padding()
                                    .padding(.trailing, 25)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .rotationEffect(Angle(degrees: 60) )
                                    .offset(x: 14, y: CGFloat( str.count * 2 )  )
                            }
                        }
                    }
                }
                .padding(.bottom, 5)
                .universalChart()
                .onAppear {
                    var dic: Dictionary<C1, Color> = Dictionary()
                    for i in 0..<styleCount  {
                        let key: C1 =  Style!( data[ i ] )
                        dic[key] = Colors.getPallette(from: primaryColor)[ i ]
                    }
                    self.dictionary = dic
                }
            }

            HStack {
                UniversalText(title, size: Constants.UIDefaultTextSize,wrap: false, true)
                Spacer()
            
                if filter != nil {
                    Menu {
                        ForEach(F.allCases) { content in
                            Button(content.rawValue) { filter = content }
                        }
                    } label: { FilterButton() }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
        }
    }
}
