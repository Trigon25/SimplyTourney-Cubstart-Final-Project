//
//  Model.swift
//  SimplyTourney
//
//  Created by Danny on 11/20/23.
//

import Foundation

enum TournamentBracketSize {
  case Sixteen, ThirtyTwo
}

struct TournamentBracket: Identifiable {
  let name: String
  let size: TournamentBracketSize
  let players: [TournamentPlayer]
  let rounds: [TournamentRound]
  var id: String {
      name
  }
  var completed: Bool {
    // TODO: implement is complete logic by looking to be sure all matches in all rounds have a winner
    return false
  }
}

struct TournamentRound: Identifiable {
  let name: String
  let matches: [TournamentMatch]
  var id: String {
    name
  }
}



enum TournamentMatchState {
  case Complete, Ready, Empty, NotReady
  // Complete: there is a first player, second player, both scores, and a winner
  // Ready: there is a first player, second player, no scores, and no winner
  // Empty: there is no first player, no second player, no scores, and no winner
  // NotReady: there is a first player, no second player, no scores, and no winner
  // NotReady: there is a second player, no first player, no scores, and no winner
}

struct TournamentMatch: Identifiable {
    var state: TournamentMatchState {
      if firstPlayer == nil && secondPlayer == nil {
        return .Empty
      }

      if firstPlayer == nil || secondPlayer == nil {
        return .NotReady
      }

      if firstPlayer != nil && secondPlayer != nil {
        if (firstPlayerScore == nil && secondPlayerScore == nil) {
          return .Ready
        }
      }

      return .Complete
    }
    let firstPlayer: TournamentPlayer?
    let secondPlayer: TournamentPlayer?
    let firstPlayerScore: Int?
    let secondPlayerScore: Int?

    var id: String {
      UUID().uuidString
    }

  var winner: TournamentPlayer? {
    if (firstPlayerScore == secondPlayerScore) {
      return nil
    }

    if firstPlayerScore == nil || secondPlayerScore == nil {
      return nil
    }

    return firstPlayerScore! > secondPlayerScore!
    ? firstPlayer : secondPlayer
  }
}

struct TournamentPlayer: Identifiable, Equatable {
  let name: String
  var id: String {
    name
  }
}
