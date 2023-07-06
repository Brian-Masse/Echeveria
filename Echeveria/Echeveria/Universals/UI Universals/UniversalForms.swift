//
//  UniversalForms.swift
//  Echeveria
//
//  Created by Brian Masse on 7/3/23.
//

import Foundation
import SwiftUI
import SymbolPicker

//MARK: Basic

struct FormHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            UniversalText( title.uppercased(), size: Constants.UIDefaultTextSize, lighter: true )
            Spacer()
        }.padding(.leading, 5)
    }
}

struct TransparentForm<C: View>: View {
    
    let title: String
    let content: C
    
    init( _ title: String, @ViewBuilder contentBuilder: () -> C ) {
        self.title = title
        self.content = contentBuilder()
    }
    
    var body: some View {
        VStack {
            FormHeader(title: title)
            VStack(alignment: .leading, spacing: Constants.UIFormSpacing) {
                content
            }.universalFormSection()
        }
    }
}

//MARK: Icon Picker

struct IconPicker: View {
    
    @Binding var icon: String
    @State var showingPicker: Bool = false
    
    var body: some View {
        HStack {
            UniversalText("Icon", size: Constants.UIDefaultTextSize)
            Image(systemName: icon)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .onTapGesture { showingPicker = true }
        .sheet(isPresented: $showingPicker) { SymbolPicker(symbol: $icon) }
    }
    
}

//MARK: Color Picker
struct ColorPickerOption: View {
    
    let color: Color
    @Binding var selectedColor: Color
    
    let size: CGFloat = 20
    
    var body: some View {
        
        if color == selectedColor {
            Circle()
                .foregroundColor(color)
                .onTapGesture { selectedColor = color }
                .frame(width: size, height: size)
                .padding(7)
                .rectangularBackgorund()
        } else {
            Circle()
                .foregroundColor(color)
                .frame(width: size, height: size)
                .padding(7)
                .onTapGesture { selectedColor = color }
        }
    }
}

struct UniqueColorPicker: View {
    
    @Binding var selectedColor: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            UniversalText("Accent Color", size: Constants.UIDefaultTextSize)
            HStack {
                Spacer()
                ColorPickerOption(color: .red, selectedColor: $selectedColor )
                Spacer()
                ColorPickerOption(color: .blue, selectedColor: $selectedColor )
                Spacer()
                ColorPickerOption(color: Colors.forestGreen, selectedColor: $selectedColor )
                Spacer()
            }
            ColorPicker(selection: $selectedColor, supportsOpacity: false) {
                UniversalText("All Colors", size: Constants.UIDefaultTextSize)
            }
        }
    }
}


//MARK: Pickers
struct MultiPicker<ListType:Collection>: View where ListType:RangeReplaceableCollection,
                                                        ListType.Element: (Hashable),
                                                        ListType.Indices: RandomAccessCollection,
                                                        ListType.Index: Hashable {
    
    let title: String
    
    @Binding var selectedSources: ListType
    
    let sources: ListType
    let previewName: (ListType.Element) -> String?
    let sourceName: (ListType.Element) -> String?
    
    private func toggleSource(_ id: ListType.Element) {
        if let index = selectedSources.firstIndex(of: id) {
            selectedSources.remove(at: index)
        }
        else { selectedSources.append(id) }
    }
    
    private func retrieveSelectionPreview() -> String {
        if selectedSources.isEmpty { return "None" }
        if selectedSources.count == sources.count { return "All" }
        return selectedSources.reduce("") { partialResult, str in
            if partialResult == "" { return sourceName( str ) ?? "" }
            return partialResult + ", \(sourceName(str) ?? "")"
        }
    }
    
    var body: some View {
        HStack {
            UniversalText(title, size: Constants.UIDefaultTextSize, lighter: true)
            Spacer()
            Menu {
                ForEach(sources.indices, id: \.self) { i in
                    Button {
                        toggleSource(sources[i])
                    } label: {
                        let name = sourceName(sources[i])
                        if selectedSources.contains(where: { id in id == sources[i] }) { Image(systemName: "checkmark") }
                        Text( name == nil ? "?" : name! ).tag(name)
                    }
                }
            } label: {
                Text( retrieveSelectionPreview())
                ResizeableIcon(icon: "chevron.up.chevron.down", size: Constants.UIDefaultTextSize)
            }
            .foregroundColor(Colors.tint)
            .menuActionDismissBehavior(.disabled)
        }.padding(.vertical, 3)
    }
}

struct BasicPicker<ListType:RandomAccessCollection, Content: View>: View where ListType.Element: (Hashable & Identifiable)  {
    
    let title: String
    let noSeletion: String
    let sources: ListType
    
    @Binding var selection: ListType.Element
    
    @ViewBuilder var contentBuilder: (ListType.Element) -> Content

    var body: some View {

        HStack {
            UniversalText(title, size: Constants.UIDefaultTextSize, lighter: true)
            Spacer()
            Picker(selection: $selection) {
                Text(noSeletion).tag("")
                ForEach( sources, id: \.id) { source in
                    contentBuilder( source ).tag(source)
                }
            } label: { Text("") }
        }
    }
}
