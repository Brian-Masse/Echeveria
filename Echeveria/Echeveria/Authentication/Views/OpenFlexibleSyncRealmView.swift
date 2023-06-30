//
//  OpenFlexibleSyncRealmView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/14/23.
//

import Foundation
import SwiftUI
import RealmSwift

struct OpenFlexibleSyncRealmView: View {
    
    @State var showingAlert: Bool = false
    @State var title: String = ""
    @State var alertMessage: String = ""
    
    @AsyncOpen(appId: "application-0-qufwt", timeout: 4000) var asyncOpen
    
    struct loadingCase: View {
        let icon: String
        let title: String
        
        var body: some View {
            VStack {
                ResizeableIcon(icon: icon, size: Constants.UIHeaderTextSize)
                UniversalText(title, size: Constants.UISubHeaderTextSize, wrap: true)
            }
        }
    }
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack(alignment: .center) {
                VStack {
                    switch asyncOpen {
                        
                    case .connecting:
                        VStack {
                            loadingCase(icon: "externaldrive.connected.to.line.below", title: "Connecting to Realm")
                            ProgressView()
                                .statusBarHidden(false)
                        }
                    case .waitingForUser:
                        loadingCase(icon: "screwdriver", title: "Failed to log user into database")
                            .onAppear {
                                title = "Failed to login"
                                alertMessage = "The user does not have access to the database, try a different user or another method of signing in."
                                showingAlert = true
                            }
                        
                    case .open(let realm):
                        loadingCase(icon: "shippingbox", title: "Loading Assests")
                            .task {
                                await EcheveriaModel.shared.realmManager.authRealm(realm: realm)
                                await EcheveriaModel.shared.realmManager.checkProfile()
                            }
                        
                    case .progress(let progress):
                        VStack {
                            loadingCase(icon: "server.rack", title: "Downloading Realm from Server")
                            ProgressView(progress)
                        }
                        
                    case .error(let error):
                        loadingCase(icon: "screwdriver", title: "Error Connecting to Realm")
                            .onAppear {
                                title = "Error Connecting to Realm"
                                alertMessage = "\(error)"
                                showingAlert = true
                            }
                    }
                }
                .frame(width: geo.size.width / 3)
                .padding()
                .rectangularBackgorund()
                .shadow(radius: 20)
                .padding()
                .alert(isPresented: $showingAlert) { Alert(
                    title: Text(title),
                    message: Text(alertMessage),
                    dismissButton: .cancel {
                        EcheveriaModel.shared.realmManager.realmLoaded = false
                        EcheveriaModel.shared.realmManager.signedIn = false
                        EcheveriaModel.shared.realmManager.hasProfile = false
                    }   ) }
            }.frame(width: geo.size.width, height: geo.size.height)
            
        }.universalColoredBackground(Colors.main)
    }
}
