//
//  Model.swift
//  SimplyTourney
//
//  Created by Danny on 11/20/23.
//

import Foundation

struct TournamentBracket: Identifiable {
  let name: String
  let players: [TournamentPlayer]
  let rounds: [TournamentRound]
  var id: String {
      name
  }
}

struct TournamentRound: Identifiable {
  let name: String
  let matches: [TournamentMatch]
  var id: String {
    name
  }
}

struct TournamentMatch: Identifiable {
    let firstPlayer: TournamentPlayer
    let secondPlayer: TournamentPlayer
    let firstPlayerScore: Int
    let secondPlayerScore: Int

    var id: String {
      firstPlayer.name + secondPlayer.name
    }

  var winner: TournamentPlayer {
    if (firstPlayerScore == secondPlayerScore) {
      // Need to handle draw condition
      return TournamentPlayer(name: "Draw")
    }

    return firstPlayerScore > secondPlayerScore
    ? firstPlayer : secondPlayer
  }
}

struct TournamentPlayer: Identifiable, Equatable {
  let name: String
  var id: String {
    name
  }
}
