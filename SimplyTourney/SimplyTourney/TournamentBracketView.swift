//
//  TournamentBracketView.swift
//  SimplyTourney
//
//  Created by Marc Chern on 15/11/23.
//

import SwiftUI

struct TournamentBracketView: View {
  let bracket: TournamentBracket = getTestTournamentBracket();


    var body: some View {
      Text(bracket.name)
      ScrollView(.horizontal) {
        LazyHStack {
          ForEach(bracket.rounds) {  round in
            VStack {
              Text(round.name)
              ForEach(round.matches) {
                match in
                MatchView(match: match)
              }
            }
          }
        }
        .scrollTargetLayout()
      }
      .scrollTargetBehavior(.viewAligned)
      .safeAreaPadding(.horizontal, 40)
    }
}

struct MatchView: View {
  let match: TournamentMatch
  var isFirstPlayerWinner: Bool {
    match.winner == match.firstPlayer
  }
  var isSecondPlayerWinner: Bool {
    match.winner == match.secondPlayer
  }
  var body: some View {
    VStack {
      Text("\(match.firstPlayer.name): \(match.firstPlayerScore)\(isFirstPlayerWinner ? " 🏆":"")")
        .opacity(isFirstPlayerWinner ? 1.0 : 0.6)
        .fontWeight(isFirstPlayerWinner ? .bold : .regular)
      Text("\(match.secondPlayer.name): \(match.secondPlayerScore)\(isSecondPlayerWinner ? " 🏆":"")")
        .opacity(isSecondPlayerWinner ? 1.0 : 0.6)
        .fontWeight(isSecondPlayerWinner ? .bold : .regular)
    }
    .frame(width: 250.0)
    .padding()
    .background(.cyan)
  }
}



func getTestMatches(players: [TournamentPlayer]) -> [TournamentMatch] {
  var playerPool = players.map({ $0 });
  var result: [TournamentMatch] = []
  while !playerPool.isEmpty {
    let firstPlayer = playerPool.removeFirst()
    let secondPlayer = playerPool.removeFirst()
    let firstPlayerScore = Int.random(in: 0...100)
    let secondPlayerScore = Int.random(in: 0...100)
    let match = TournamentMatch(
      firstPlayer: firstPlayer,
      secondPlayer: secondPlayer,
      firstPlayerScore: firstPlayerScore,
      secondPlayerScore: secondPlayerScore
    )
    result.append(match)
  }
  return result
}

func getTestTournamentBracket() -> TournamentBracket {

  let players = [
    TournamentPlayer(name: "player one"),
    TournamentPlayer(name: "player two"),
    TournamentPlayer(name: "player three"),
    TournamentPlayer(name: "player four"),
    TournamentPlayer(name: "player five"),
    TournamentPlayer(name: "player six"),
    TournamentPlayer(name: "player seven"),
    TournamentPlayer(name: "player eight"),
    TournamentPlayer(name: "player nine"),
    TournamentPlayer(name: "player ten"),
    TournamentPlayer(name: "player eleven"),
    TournamentPlayer(name: "player twelve"),
    TournamentPlayer(name: "player thirteen"),
    TournamentPlayer(name: "player fourteen"),
    TournamentPlayer(name: "player fifteen"),
    TournamentPlayer(name: "player sixteen")
  ];

  let eigthsMatches = getTestMatches(players: players.shuffled());
  let quarterFinalsMatches = getTestMatches(players: eigthsMatches.map({ $0.winner! }))
  let semiFinalsMatches = getTestMatches(players: quarterFinalsMatches.map({ $0.winner! }))
  let finalsMatches = getTestMatches(players: semiFinalsMatches.map({ $0.winner }))


  let eigths = TournamentRound(name: "Eighth-finals", matches: eigthsMatches)
  let quarterFinals = TournamentRound(name: "Quarterfinals", matches: quarterFinalsMatches)
  let semiFinals = TournamentRound(name: "Semifinals", matches: semiFinalsMatches)
  let finals = TournamentRound(name: "Finals", matches: finalsMatches)
  let rounds = [eigths, quarterFinals, semiFinals, finals]

  return TournamentBracket(
    name: "My Tournament",
    size: .Sixteen,
    players:  players,
    rounds: rounds
  )
}

#Preview {
  TournamentBracketView()
}
