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
    
    static var autoFillGameLogger: AutoFillGameLogger? = nil
    
    @Environment(\.presentationMode) var presentationMode
    
    let editing: Bool
    let gameID: String?
    
    @State var gameType: EcheveriaGame.GameType
    @State var group: String
    @State var date: Date = .now
    
    var players: [String]? {
        guard let group = EcheveriaGroup.getGroupObject(with: group) else { return nil }
        return group.members.map { string in return string }
    }
    
    @State var selectedPlayers: [String]
    @State var selectedWinners: [String]
    @State var gameExperieince: EcheveriaGame.GameExperience
    @State var gameComments: String
    
    @State var gameValues: Dictionary<String, String>
    
    @State var showingAlert: Bool = false
    
    @ObservedResults(EcheveriaGroup.self, where: { group in group.members.contains( EcheveriaModel.shared.profile.ownerID ) }) var groups
    
    private func refreshGroup() {
        selectedPlayers = []
    }
    
    private func checkCompletion() -> Bool {
        !gameType.rawValue.strip().isEmpty && !group.isEmpty && selectedPlayers.count != 0 && selectedWinners.count != 0
    }
    
    private func ArrayToRealmList<T>(_ array: [T]) -> RealmSwift.List<T> {
        let list: RealmSwift.List<T> = RealmSwift.List()
        list.append(objectsIn: array)
        return list
    }
    
    private func submit() {
        if !checkCompletion() { showingAlert = true; return }
        
        if !editing {
            let _ = EcheveriaGame(EcheveriaModel.shared.profile.ownerID,
                                  type: gameType,
                                  group: group,
                                  date: date,
                                  players: ArrayToRealmList(selectedPlayers),
                                  winners: ArrayToRealmList(selectedWinners),
                                  experience: gameExperieince,
                                  comments: gameComments,
                                  gameData: gameValues)
            
        } else {
            if let game = EcheveriaGame.getGameObject(from: gameID ?? "") {
                game.update(type: gameType,
                             group: group,
                             date: game.date,
                             players: ArrayToRealmList(selectedPlayers),
                             winners: ArrayToRealmList(selectedWinners),
                             experience: gameExperieince,
                             comments: gameComments,
                             gameData: gameValues)
            }
        }
        
        GameLoggerView.autoFillGameLogger = AutoFillGameLogger(gameType: gameType,
                                                               gameExperience: gameExperieince,
                                                               groupID: group,
                                                               players: selectedPlayers,
                                                               winners: selectedWinners,
                                                               gameData: gameValues)
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private func autoFill() {
        self.gameType           = GameLoggerView.autoFillGameLogger!.gameType
        self.gameExperieince    = GameLoggerView.autoFillGameLogger!.gameExperience
        self.group              = GameLoggerView.autoFillGameLogger!.groupID
        self.selectedPlayers    = GameLoggerView.autoFillGameLogger!.players
        self.selectedWinners    = GameLoggerView.autoFillGameLogger!.winners
        self.gameValues         = GameLoggerView.autoFillGameLogger!.gameData
    }
    
    var body: some View {
        
        let groupIDs: [String] = groups.map { group in group._id.stringValue }
        
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    
                    UniversalText(editing ? "Edit Game" : "Log Game", size: Constants.UITitleTextSize, true)
                        .padding(.bottom)
                    
                    ScrollView(.vertical) {
                        
                        if GameLoggerView.autoFillGameLogger != nil {
                            RoundedButton(label: "Autofill from last log", icon: "arrowshape.bounce.right") { autoFill() }
                                .padding(.bottom, 5)
                        }
                        
                        TransparentForm("Basic Information") {
                            BasicPicker(title: "Game Type", noSeletion: "No Selection", sources: EcheveriaGame.GameType.allCases, selection: $gameType) { gameType in
                                Text(gameType.rawValue)
                            }
                            
                            BasicPicker(title: "Group", noSeletion: "No Group", sources: groupIDs, selection: $group) { groupID in
                                if let group = EcheveriaGroup.getGroupObject(with: groupID) { Text(group.name) }
                            }
                            
                            DatePicker(selection: $date) {
                                UniversalText("Date", size: Constants.UIDefaultTextSize, lighter: true)
                            }
                        }
                        
                        if group != "" {
                            AsyncLoader {
                                if let group = EcheveriaGroup.getGroupObject(with: self.group) { await group.updatePermissionsForGameLogger() }
                            } content: {
                                TransparentForm("Game Information") {
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
                                    
                                    HStack {
                                        TextField("Comments", text: $gameComments)
//                                            .frame(width: geo.size.width - 50 )
//                                            .fixedSize(horizontal: true, vertical: false)
                                        Spacer()
                                    }
                                }
                                
                                switch gameType {
                                case .smash:        Smash.InputForm(values: $gameValues, players: selectedPlayers)
                                case .magic:        Magic.InputForm(values: $gameValues, players: selectedPlayers)
                                case .spikeBall:    LawnGame.InputForm(values: $gameValues, players: selectedPlayers)
                                case .bags:         LawnGame.InputForm(values: $gameValues, players: selectedPlayers)
                                default: EmptyView()
                                }
                            }
                            .padding(.bottom, 65)
                            .onChange(of: group) { _ in refreshGroup() }
                        }
                    }
                }
            
                
                RoundedButton(label: "Submit", icon: "checkmark.seal") { submit() }
                    .padding()
                    .shadow(radius: 5)
            }
        }
        .padding()
        .universalColoredBackground( Colors.tint )
        .alert(isPresented: $showingAlert) {
            Alert(title: Text( "Form Incomplete" ).bold(true), message: Text( "Please check that you selected a group, game type, players, and a winner." ))
        }
        .onTapGesture { self.hideKeyboard() }
    }   
}

struct AutoFillGameLogger {
    
    let gameType: EcheveriaGame.GameType
    let gameExperience: EcheveriaGame.GameExperience
    
    let groupID: String
    let players: [String]
    let winners: [String]
    
    let gameData: Dictionary<String, String>
    
}
