//
//  Model.swift
//  SimplyTourney
//
//  Created by Danny on 11/20/23.
//

import Foundation
import SwiftData

enum TournamentRoundName: String, Codable {
  case SixteenthFinals = "16th-finals"
  case EigthFinals = "Eigth-finals"
  case QuarterFinals = "Quarterfinals"
  case SemiFinals = "Semifinals"
  case Finals = "Finals"
  case Unknown = "Round"
}

enum TournamentBracketSize: Int, Codable {
  case Sixteen = 16
  case ThirtyTwo = 32
}

@Model
class TournamentBracket: Identifiable {
  let timestamp: Date
  @Attribute(.unique) let name: String
  let size: TournamentBracketSize
  let players: [TournamentPlayer]
  let rounds: [TournamentRound]
//  var orderedRounds: [TournamentRound] {
//    rounds.sorted(by: {$0.timestamp < $1.timestamp})
//  }

  var id: String {
      name
  }
  var completed: Bool {
    return rounds.allSatisfy({ $0.completed })
  }
  init(name: String, size: TournamentBracketSize, players: [TournamentPlayer], rounds: [TournamentRound]) {
    self.timestamp = .now
    self.name = name
    self.size = size
    self.players = players
    self.rounds = rounds
  }

  init(name: String, size: TournamentBracketSize, players: [TournamentPlayer]) {
    self.timestamp = .now
    self.name = name
    self.size = size
    self.players = players
    self.rounds = TournamentBracket.createRounds(size: size, players: players)
  }
  init(name: String, size: Int, players: [String]) {
    self.timestamp = .now
    let bracketSize = size == 16 
      ? TournamentBracketSize.Sixteen
      : TournamentBracketSize.ThirtyTwo
    let playerList = players.map({ TournamentPlayer(name: $0) })
    self.name = name
    self.size = bracketSize
    self.players = playerList
    self.rounds = TournamentBracket.createRounds(size: bracketSize, players: playerList)
  }

  func syncRounds() {
//    var roundPool = orderedRounds.map({ $0 })
    var roundPool = rounds.map({ $0 })
    while !roundPool.isEmpty {
      let currentRound = roundPool.removeFirst()
      if let nextRound = roundPool.first {
        var currentRoundWinnerPool = currentRound.matches.map({ $0.winner })
        for match in nextRound.matches {
          let firstPlayer = currentRoundWinnerPool.removeFirst()
          let secondPlayer = currentRoundWinnerPool.removeFirst()
          match.firstPlayer = firstPlayer
          match.secondPlayer = secondPlayer
        }

      }

    }
  }

  private static func createRounds(size: TournamentBracketSize, players: [TournamentPlayer]) -> [TournamentRound] {
    var rounds: [TournamentRound] = []
    var playerPool = players.shuffled();
    var initialMatches: [TournamentMatch] = []
    while !playerPool.isEmpty {
      let firstPlayer = playerPool.removeFirst()
      let secondPlayer = playerPool.removeFirst()

      let match = TournamentMatch(
        firstPlayer: firstPlayer,
        secondPlayer: secondPlayer
      )
      initialMatches.append(match)
    }
    
    rounds.append(TournamentRound(matches: initialMatches))

    var counter = initialMatches.count
    repeat {
      counter /= 2
      let matches = (0..<counter).map({ _ in TournamentMatch() })
      rounds.append(TournamentRound(matches: matches))
    } while(counter > 1)
    return rounds;
  }
}

@Model
class TournamentRound: Identifiable {
  let timestamp: Date
  let matches: [TournamentMatch]
//  var orderedMatches: [TournamentMatch] {
//    matches.sorted(by: {$0.timestamp < $1.timestamp})
//  }
  var name: TournamentRoundName {
    switch(matches.count) {
    case 16:
        .SixteenthFinals
    case 8:
        .EigthFinals
    case 4:
        .QuarterFinals
    case 2:
        .SemiFinals
    case 1:
        .Finals
    default:
        .Unknown
    }
  }

  var id: String {
    name.rawValue
  }

  var completed: Bool {
    return matches.allSatisfy({ $0.winner != nil })
  }


  init(matches: [TournamentMatch]) {
    self.timestamp = .now
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

@Model
class TournamentMatch: Identifiable {
  let timestamp: Date
  var firstPlayer: TournamentPlayer?
  var secondPlayer: TournamentPlayer?
  var firstPlayerScore: Int?
  var secondPlayerScore: Int?

  var id: String {
    UUID().uuidString
  }

  var state: TournamentMatchState {
    if firstPlayer == nil && secondPlayer == nil {
      return .Empty
    }

    if firstPlayer == nil || secondPlayer == nil {
      return .NotReady
    }

    if (firstPlayerScore == nil || secondPlayerScore == nil) {
      return .Ready
    }

    return .Complete
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
    self.timestamp = .now
    self.firstPlayer = firstPlayer
    self.secondPlayer = secondPlayer
    self.firstPlayerScore = firstPlayerScore
    self.secondPlayerScore = secondPlayerScore
  }

  init(firstPlayer: TournamentPlayer?, secondPlayer: TournamentPlayer?) {
    self.timestamp = .now
    self.firstPlayer = firstPlayer
    self.secondPlayer = secondPlayer
    self.firstPlayerScore = nil
    self.secondPlayerScore = nil
  }

  init() {
    self.timestamp = .now
    self.firstPlayer = nil
    self.secondPlayer = nil
    self.firstPlayerScore = nil
    self.secondPlayerScore = nil
  }
}

@Model
class TournamentPlayer: Identifiable, Equatable {
  let timestamp: Date
//  @Attribute(.unique) let name: String
  let name: String

  static func == (lhs: TournamentPlayer, rhs: TournamentPlayer) -> Bool {
    return lhs.name == rhs.name
  }
  
  var id: String {
    name
  }

  init(name: String) {
    self.timestamp = .now
    self.name = name
  }
}
