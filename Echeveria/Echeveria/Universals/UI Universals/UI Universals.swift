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
    let text: String
    let size: CGFloat
    let bold: Bool
    let wrap: Bool
    let lighter: Bool
    
    init(_ text: String, size: CGFloat, wrap: Bool = true, lighter: Bool = false, _ bold: Bool = false) {
        self.text = text
        self.size = size
        self.bold = bold
        self.wrap = wrap
        self.lighter = lighter
    }
    
    var body: some View {
        
        Text(text)
//            .universalTextStyle()
//            .fixedSize()
            .minimumScaleFactor(wrap ? 1 : 0.5)
            .lineLimit(wrap ? 5 : 1)
            .font(Font.custom("Helvetica", size: size) )
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

//MARK: Graphs

struct TimeBasedChart<T: Hashable, C1: Plottable, C2: Plottable, C3: Plottable>: View where C3: Hashable {
    
    let initialDate: Date
    let title: String
    let content: [T]
    
    let xAxisTitle: String
    let xAxisContent: (T) -> C1
    
    let yAxisTitle: String
    let yAxisContent: (T) -> C2
    
    let styleTitle: String
    let styleContent: (T) -> C3
    let styleCount: Int
    
    let primaryColor: Color
    
    @State var dictionary: Dictionary<C3, Color> = Dictionary()
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            Chart {
                ForEach(content, id: \.self ) { content in
                    LineMark(
                        x: .value(xAxisTitle, xAxisContent(content) ),
                        y: .value(yAxisTitle, yAxisContent(content) )
                    )
                    .foregroundStyle(by: .value(styleTitle, styleContent(content)))
                }
                
            }
            
            .chartXScale(domain: [ initialDate, Date.now.advanced(by: 3600) ])
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)){ value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel( date.formatted(date: .numeric, time: .omitted)  )
                    }
                    
                    AxisGridLine()
                    AxisTick()
                }
            }
            .universalChart()
            .chartForegroundStyleScale { (value: C3) in dictionary[value] ?? .red }
            .onAppear {
                var dic: Dictionary<C3, Color> = Dictionary()
                if content.count == 0 { return }
                for i in 0..<styleCount  {
                    let key: C3 =  styleContent( content[ i ] )
                    dic[key] =  Colors.getPallette(from: primaryColor)[ i ]
                }
                self.dictionary = dic
            }
            
            UniversalText(title, size: Constants.UISubHeaderTextSize, true)
                .padding(.horizontal)
                .padding(.vertical, 7)
        }
    }
}


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
                        )
                    }
                }.universalChart()
            } else {
                Chart {
                    ForEach(data, id: \.self) { data in
                        BarMark(
                            x: .value(XAxisTitle, XAxis( data ) ),
                            y: .value(YAxisTitle, YAxis( data ) )
                        ).foregroundStyle(by: .value(styleTitle!, Style!( data ) ) )
                    }
                }
                .universalChart()
                .chartForegroundStyleScale { (value: C1) in dictionary[value] ?? .red }
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
                UniversalText(title, size: Constants.UIDefaultTextSize, true)
                Spacer()
            
                if filter != nil {
                    Menu {
                        ForEach(F.allCases) { content in
                            Button(content.rawValue) { filter = content }
                        }
                    } label: {
                        ShortRoundedButton("filter", icon: "line.3.horizontal.decrease.circle") { }
                            .universalTextStyle()
                            .padding(.top)
                    }
                }
            }.padding(.horizontal)
                .padding(.vertical, 5)
        }
    }
}
