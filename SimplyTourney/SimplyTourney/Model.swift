//
//  Model.swift
//  SimplyTourney
//
//  Created by Danny on 11/20/23.
//

import Foundation
import SwiftData


enum TournamentBracketSize: Int, Codable {
  case Sixteen = 16
  case ThirtyTwo = 32
}

//@Model
class TournamentBracket: Identifiable {
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
  init(name: String, size: TournamentBracketSize, players: [TournamentPlayer], rounds: [TournamentRound]) {
    self.name = name
    self.size = size
    self.players = players
    self.rounds = rounds
  }
}

//@Model
class TournamentRound: Identifiable {
  let name: String
  let matches: [TournamentMatch]
  var id: String {
    name
  }

  init(name: String, matches: [TournamentMatch]) {
    self.name = name
    self.matches = matches
  }
}


enum TournamentMatchState: String, Codable {
  case Complete = "complete"
  case Ready = "ready"
  case Empty = "empty"
  case NotReady = "not_ready"
  // Complete: there is a first player, second player, both scores, and a winner
  // Ready: there is a first player, second player, no scores, and no winner
  // Empty: there is no first player, no second player, no scores, and no winner
  // NotReady: there is a first player, no second player, no scores, and no winner
  // NotReady: there is a second player, no first player, no scores, and no winner
}

//@Model
class TournamentMatch: Identifiable {
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
    guard let firstPlayer = firstPlayer else {
      return nil
    }
    guard let secondPlayer = secondPlayer else {
      return nil
    }
    guard let firstPlayerScore = firstPlayerScore else {
      return nil
    }
    guard let secondPlayerScore = secondPlayerScore else {
      return nil
    }
    guard firstPlayerScore != secondPlayerScore else {
      return nil
    }

    return firstPlayerScore > secondPlayerScore
    ? firstPlayer : secondPlayer
  }

  init(firstPlayer: TournamentPlayer?, secondPlayer: TournamentPlayer?, firstPlayerScore: Int?, secondPlayerScore: Int?) {
    self.firstPlayer = firstPlayer
    self.secondPlayer = secondPlayer
    self.firstPlayerScore = firstPlayerScore
    self.secondPlayerScore = secondPlayerScore
  }

  // TODO: delete? maybe this is only needed for our current test data methods
  init() {
    self.firstPlayer = nil
    self.secondPlayer = nil
    self.firstPlayerScore = nil
    self.secondPlayerScore = nil
  }
}

//@Model
class TournamentPlayer: Identifiable, Equatable {
  static func == (lhs: TournamentPlayer, rhs: TournamentPlayer) -> Bool {
    return lhs.name == rhs.name
  }
  
  let name: String
  var id: String {
    name
  }

  init(name: String) {
    self.name = name
  }
}
