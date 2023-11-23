//
//  StartingView.swift
//  SimplyTourney
//
//  Created by Marc Chern on 15/11/23.
//

import SwiftUI

struct StartingView: View {
    var body: some View {
        VStack {
            NavigationStack {
                VStack {
                    Text("Simply**Tourney**").font(.largeTitle).padding(.top, 50)
                    Spacer()
                    NavigationLink {
                        CreateNewTourneyBracketView()
                    } label: {
                        Text("**Create New Tourney**").font(.title)
                    }
                    //title for created tournaments
                    
                    //links to existing tournaments
                    
                    //button to make new one
                    .foregroundColor(.white)
                    .frame(width: 320, height: 50)
                    .background(RoundedRectangle(cornerRadius:25))
                    .padding(.bottom, 100)
                    NavigationLink {
                        TournamentBracketView()
                    } label: {
                        Text("**Frogger Tourney**").font(.title)
                    }
                    .foregroundColor(.white)
                    .frame(width: 320, height: 50)
                    .background(RoundedRectangle(cornerRadius:25))
                    .padding(.bottom, 300)
                    
                }.navigationDestination(for: String.self) { value in
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .background(LinearGradient(gradient: Gradient(colors: [.blue, Color(red:0.4627, green:0.8392, blue:1.0)]), startPoint: .top, endPoint: .bottom))
            }
            
            
        }
        
                
    }
        
}

#Preview {
    StartingView()
}
