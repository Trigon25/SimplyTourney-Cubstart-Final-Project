//
//  StartingView.swift
//  SimplyTourney
//
//  Created by Marc Chern on 15/11/23.
//

import SwiftUI
import SwiftData

struct StartingView: View {
//  @Query(filter: #Predicate<TournamentBracket> { bracket in !bracket.completed }) var inProgressBrackets: [TournamentBracket]
//  @Query(filter: #Predicate<TournamentBracket> { bracket in bracket.completed }) var completedBrackets: [TournamentBracket]
  @Query var inProgressBrackets: [TournamentBracket]
  @Query var completedBrackets: [TournamentBracket]

    var body: some View {
        VStack {
            NavigationStack {
                VStack {
                    Text("Simply**Tourney**").font(.largeTitle).padding(.top, 50)
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
//                    .padding(.bottom, 100)
                  ForEach(inProgressBrackets) { bracket in
                    NavigationLink {
                      TournamentBracketView(bracket: bracket)
                    } label: {
                      Text("**\(bracket.name)**").font(.title)
                    }
                    .foregroundColor(.white)
                    .frame(width: 320, height: 50)
                    .background(RoundedRectangle(cornerRadius:25))
//                    .padding(.bottom, 300)
                  }
                  Divider()
                  ForEach(completedBrackets) { bracket in
                    NavigationLink {
                      TournamentBracketView(bracket: bracket)
                    } label: {
                      Text("__\(bracket.name)__").font(.title)
                    }
                    .foregroundColor(.gray)
                    .frame(width: 320, height: 50)
                    .background(RoundedRectangle(cornerRadius:25))
                    .padding(.bottom, 300)
                  }
//                    NavigationLink {
//                        TournamentBracketView()
//                    } label: {
//                        Text("**Frogger Tourney**").font(.title)
//                    }

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
    .modelContainer(for: [
      TournamentBracket.self,
      TournamentRound.self,
      TournamentMatch.self,
    ])
}
