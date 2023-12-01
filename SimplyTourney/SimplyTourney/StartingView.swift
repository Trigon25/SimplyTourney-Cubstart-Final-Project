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

                  ForEach(completedBrackets) { bracket in
                    NavigationLink {
                      TournamentBracketView(bracket: bracket)
                    } label: {
                      Text("__\(bracket.name)__").font(.title)
                    }
                    .foregroundColor(.gray)
                    .frame(width: 320, height: 50)
                    .background(RoundedRectangle(cornerRadius:25))
//                    .padding(.bottom, 300)
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


func getTestTournamentPlayers(size: Int) -> [String] {
  var result: [String] = []
  for i in 1...size {
    result.append("player \(i)")
  }
  return result
}

func getRandomTestTournamentBracket(isComplete: Bool? = nil) -> TournamentBracket {
  let shouldFill = isComplete ?? Bool.random()
  let sizes = [16, 32]
  let size = sizes.randomElement()
  let games = ["Poker", "⁨Kickball", "FIFA", "Catan", "Uno", "Darts", "Smash Bros", "MTG", "Pokémon"]
  let kinds = ["Tournament", "Tourney", "League", "Party", "Fun", "Bracket"];
  let game = games.randomElement()!
  let kind = kinds.randomElement()!
  let name = "\(game) \(kind)"
  let players = getTestTournamentPlayers(size: size!);
  let bracket = TournamentBracket(
    name: name,
    size: size!,
    players: players
  )

  if(!shouldFill) {
    return bracket
  }

//  for round in bracket.orderedRounds {
  for round in bracket.rounds {
//    for match in round.orderedMatches {
    for match in round.matches {
      match.firstPlayerScore = Int.random(in: 0...100)
      var nextScore = Int.random(in: 0...100)
      if (match.firstPlayerScore == nextScore) {
        nextScore += Int.random(in: 1...5)
      }
      match.secondPlayerScore = nextScore
    }
    bracket.syncRounds()
  }

  return bracket
}


//#if DEBUG
//@MainActor
//let previewContainer: ModelContainer = {
//  do {
//    let container = try ModelContainer(
//      for: TournamentBracket.self,
//      TournamentRound.self,
//      TournamentMatch.self,
//      TournamentPlayer.self,
//      configurations: ModelConfiguration(isStoredInMemoryOnly: true)
//    )
//
////    for _ in 1...3 {
////      container.mainContext.insert(getRandomTestTournamentBracket())
////    }
//
//    return container
//  } catch {
//    fatalError("Failed to create preview container")
//  }
//}()
//#endif

#Preview {
  StartingView()
    .modelContainer(for: [
      TournamentBracket.self,
      TournamentRound.self,
      TournamentMatch.self,
      TournamentPlayer.self
    ])
}

#Preview("Randomly Pre-populated Brackets") {
  do {

    let container = try ModelContainer(
      for: TournamentBracket.self,
      TournamentRound.self,
      TournamentMatch.self,
      TournamentPlayer.self,
      configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    for _ in 1...3 {
      container.mainContext.insert(getRandomTestTournamentBracket())
    }

    return StartingView()
      .modelContainer(container)
  } catch {
    fatalError("Fail")
  }
}
