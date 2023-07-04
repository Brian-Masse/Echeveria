//
//  UniversalForms.swift
//  Echeveria
//
//  Created by Brian Masse on 7/3/23.
//

import Foundation
import SwiftUI

//MARK: BASIC
struct FormButton<C1: View, C2: View>: View {
    
    let leftContent: C1?
    let rightContent: C2?
    
    init( @ViewBuilder c1Builder: () -> C1? = {nil}, @ViewBuilder c2Builder: () -> C2? = {nil} ) {
        self.leftContent = c1Builder()
        self.rightContent = c2Builder()
    }
    
    var body: some View {
        HStack {
            if leftContent != nil { leftContent }
            else { EmptyView() }
            Spacer()
            if rightContent != nil { rightContent }
            else { EmptyView() }
        }
    }
}

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


//MARK: Pickers
struct MultiPicker<ListType:RandomAccessCollection>: View where ListType:RangeReplaceableCollection, ListType.Element: (Hashable) {
    
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
                ForEach(sources, id: \.self) { source in
                    Button {
                        toggleSource(source)
                    } label: {
                        let name = sourceName(source)
                        if selectedSources.contains(where: { id in id == source }) { Image(systemName: "checkmark") }
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
