//
//  TournamentBracketView.swift
//  SimplyTourney
//
//  Created by Marc Chern on 15/11/23.
//

import SwiftUI
import SwiftData

struct TournamentBracketView: View {
  let bracket: TournamentBracket = getFullTestTournamentBracket();
//  let bracket: TournamentBracket = getInitialTestTournamentBracket();


    var body: some View {
      Text(bracket.name)
      ScrollView(.horizontal) {
        LazyHStack {
          ForEach(bracket.rounds) {  round in
            VStack {
              Text(round.name.rawValue)
              ForEach(round.matches) {
                match in
                MatchView(match: match)
                  .padding(20.0)
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


struct MatchPlayerView: View {
  let player: TournamentPlayer?
  var score: Int?
  var isWinner: Bool? = false
  var body: some View {
    ZStack {
      Capsule()
        .fill(.gray.opacity(0.5))
      HStack {
        if let player = player {
          Text(player.name)
            .padding(.leading, 20.0)
            .padding(.vertical, 5.0)
          Spacer()
          Divider()
            .bold()
            .overlay(.black)
          if let score = score {

            Text("\(score)".padding(toLength: 4, withPad: " ", startingAt: 0))
              .padding(.trailing, 20.0)
              .monospaced()
              .fontWeight(isWinner == true ? .bold : .regular)
          } else {
            Text("")
          }
        } else {
          Text("-")
        }

      }
    }
    .opacity(isWinner == true ? 1.0 : 0.3)
    .frame(height: 40.0)
  }
}

struct UpdateScoreButton: View {
  var body: some View {
    Button (action: {

    }, label: {
      Image(systemName: "plus.diamond.fill")
    })
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
    VStack(spacing: 3.0) {
      switch match.state {
      case .Empty, .NotReady:
        MatchPlayerView(player: match.firstPlayer)
        MatchPlayerView(player: match.secondPlayer)
      case .Ready:
        HStack {
          VStack {
            MatchPlayerView(player: match.firstPlayer)
            MatchPlayerView(player: match.secondPlayer)
          }
          UpdateScoreButton()
        }
      case .Complete:
        MatchPlayerView(
          player: match.firstPlayer,
          score: match.firstPlayerScore,
          isWinner: isFirstPlayerWinner
        )
        MatchPlayerView(
          player: match.secondPlayer,
          score: match.secondPlayerScore,
          isWinner: isSecondPlayerWinner
        )
      }
    }
    .frame(width: 250.0)
  }
}



func getTestTournamentPlayers() -> [TournamentPlayer] {
  return [
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
}

func getFullTestTournamentBracket() -> TournamentBracket {
  let players = getTestTournamentPlayers();
  let bracket = TournamentBracket(
    name: "My Full Tournament",
    size: .Sixteen,
    players:  players
  )

  for round in bracket.rounds {
    for match in round.matches {
      match.firstPlayerScore = Int.random(in: 0...100)
      var nextScore = Int.random(in: 0...100)
      if (match.firstPlayerScore == nextScore) {
        nextScore += 1
      }
      match.secondPlayerScore = nextScore
    }
  }


  return bracket
}

func getInitialTestTournamentBracket() -> TournamentBracket {
  let players = getTestTournamentPlayers();

  return TournamentBracket(
    name: "My Initial Tournament",
    size: .Sixteen,
    players:  players
  )
}

#Preview {
  TournamentBracketView()
}
