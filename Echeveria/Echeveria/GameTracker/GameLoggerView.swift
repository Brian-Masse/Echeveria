//
//  GameLoggerView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/19/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct GameLoggerView: View  {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var gameType: EcheveriaGame.GameType? = nil
    @State var group: EcheveriaGroup? = nil
    @State var date: Date = .now
    @State var loadingPermission: Bool = true
    
    var players: [String]? {
        guard let group = self.group else { return nil }
        return group.members.map { string in return string }
    }
    
    @State var selectedPlayers: [String] = []
    @State var selectedWinners: [String] = []
    @State var gameExperieince: EcheveriaGame.GameExperience? = .good
    @State var gameComments: String = ""
    
    @ObservedResults(EcheveriaGroup.self) var groups
    
    private func refreshGroup() {
        selectedPlayers = []
        loadingPermission = true
    }
    
    private func checkCompletion() -> Bool {
        if (gameExperieince != nil && group != nil && gameType != nil) {
            return true
        }
        return false
    }
    
    private func ArrayToRealmList<T>(_ array: [T]) -> RealmSwift.List<T> {
        let list: RealmSwift.List<T> = RealmSwift.List()
        list.append(objectsIn: array)
        return list
    }
    
    var body: some View {
        
        VStack {
            Form {
                Section("Basic Information") {
                    
                    BasicPicker(title: "Game Type", noSeletion: "No Selection", sources: EcheveriaGame.GameType.allCases, selection: $gameType) { gameType in
                        Text(gameType.rawValue)
                    }
                    
                    BasicPicker(title: "Group", noSeletion: "No Group", sources: groups, selection: $group) { group in
                        Text(group.name)
                    }
                    DatePicker(selection: $date) {
                        Text("Date")
                    }
                    
                }.universalFormSection()
                
                if group != nil {
                    if loadingPermission {
                        AsyncLoader { await group!.provideLocalUserAccess()
                            loadingPermission = false
                        } closingTask: { await group!.disallowLocalUserAccess() }
                    }
                    
                    Section("Game Information") {
                        MultiPicker(title: "Players", selectedSources: $selectedPlayers, sources: players!) { playerID in
                            if let profile = EcheveriaProfile.getProfileObject(from: playerID) { return profile.firstName }; return nil
                        } sourceName: { playerID in
                            if let profile = EcheveriaProfile.getProfileObject(from: playerID) { return ("\(profile.firstName) \(profile.lastName)") }; return nil
                        }
                    
                        MultiPicker(title: "Winners", selectedSources: $selectedWinners, sources: players!) { playerID in
                            if let profile = EcheveriaProfile.getProfileObject(from: playerID) { return profile.firstName }; return nil
                        } sourceName: { playerID in
                            if let profile = EcheveriaProfile.getProfileObject(from: playerID) { return ("\(profile.firstName) \(profile.lastName)") }; return nil
                        }
                        
                        BasicPicker(title: "Game Experience", noSeletion: "None", sources: EcheveriaGame.GameExperience.allCases, selection: $gameExperieince) { content in
                            Text(content.rawValue)
                        }
                        
                        TextField("Comments", text: $gameComments)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .onChange(of: group) { _ in refreshGroup() }
                    .universalFormSection()
                }
            }.universalForm()
            
            RoundedButton(label: "Submit", icon: "checkmark.seal") {
                if !checkCompletion() { return }
                
                let _ = EcheveriaGame(EcheveriaModel.shared.profile.ownerID,
                                         type: gameType!,
                                         group: group!,
                                         date: date,
                                         players: ArrayToRealmList(selectedPlayers),
                                         winners: ArrayToRealmList(selectedWinners),
                                         experience: gameExperieince!,
                                         comments: gameComments )
                presentationMode.wrappedValue.dismiss()
            }
            
        }.universalBackground()
    }
    
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
            var returning = ""
            for id in selectedSources {
                if let str = previewName(id) { returning += str }
            }
            return returning
        }
        
        var body: some View {
            HStack {
                Text(title)
                Spacer()
                Menu {
                    ForEach(sources, id: \.self) { source in
                        Button {
                            toggleSource(source)
                        } label: {
                            let name = sourceName(source)
                            if selectedSources.contains(where: { id in id == source }) { Image(systemName: "checkmark") }
                            Text( name == nil ? "?" : name! ).tag(source)
                        }
                    }
                } label: {
                    Text( retrieveSelectionPreview() ).universalTextStyle()
                    Image(systemName: "chevron.up.chevron.down").universalTextStyle()

                }
                .menuActionDismissBehavior(.disabled)
            }
        }
    }

    struct BasicPicker<ListType:RandomAccessCollection, Content: View>: View where ListType.Element: (Hashable & Identifiable)  {
        
        let title: String
        let noSeletion: String
        let sources: ListType
        
        @Binding var selection: ListType.Element?
        
        @ViewBuilder var contentBuilder: (ListType.Element) -> Content

        var body: some View {

            Picker(selection: $selection) {
                Text(noSeletion).tag(ListType.Element?.none)
                ForEach( sources, id: \.id) { source in
                    contentBuilder( source ).tag(ListType.Element?.some(source))
                }
            } label: { Text(title) }
        }
    }
}
