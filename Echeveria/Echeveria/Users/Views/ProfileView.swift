//
//  ProfileView.swift
//  Echeveria
//
//  Created by Brian Masse on 6/17/23.
//

import Foundation
import SwiftUI


struct ProfileView: View {
    
    @ObservedObject var profile: EcheveriaUser
    
    let largeFont = Font.custom("Helvetica", size: 30)
    
    var body: some View {
        

        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Image(systemName: "person.crop.square")
                Text("Profile Page")
                Spacer()
                
            }.padding(.bottom)
            
            HStack {
                Image(systemName: "globe.americas")
                    .resizable()
                    .frame(width: 60, height: 60)
                
                VStack {
                    Text(profile.firstName).bold(true).font(largeFont)
                    Text(profile.lastName).bold(true).font(largeFont)
                }
            }
            
            .padding(.bottom)

        
            
            Text("Number of Cards: ").bold(true).font(.custom("Helvetica", size: 20))
            Text("\( profile.getNumCards() )")
            
            Spacer()
        }.padding()
        
    }
}
