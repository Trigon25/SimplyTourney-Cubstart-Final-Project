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
  let timestamp: Date = Date.now
  @Attribute(.unique) let name: String
  let size: TournamentBracketSize
  let players: [TournamentPlayer]
  let rounds: [TournamentRound]
  var completed: Bool = false

  var id: String {
      name
  }

  init(name: String, size: TournamentBracketSize, players: [TournamentPlayer], rounds: [TournamentRound]) {
    self.name = name
    self.size = size
    self.players = players
    self.rounds = rounds
  }

  init(name: String, size: TournamentBracketSize, players: [TournamentPlayer]) {
    self.name = name
    self.size = size
    self.players = players
    self.rounds = TournamentBracket.createRounds(size: size, players: players)
  }
  init(name: String, size: Int, players: [String]) {
    let bracketSize = size == 16
      ? TournamentBracketSize.Sixteen
      : TournamentBracketSize.ThirtyTwo
    let playerList = players.map({ TournamentPlayer(name: $0) })
    self.name = name
    self.size = bracketSize
    self.players = playerList
    self.rounds = TournamentBracket.createRounds(size: bracketSize, players: playerList)
  }
  
  func sync() {
    rounds.forEach({ $0.sync() })
    completed = rounds.allSatisfy({ $0.completed })

    var roundPool = rounds.sorted(by: { $0.timestamp < $1.timestamp })
    while !roundPool.isEmpty {
      let currentRound = roundPool.removeFirst()
      if let nextRound = roundPool.first {
        var currentRoundWinnerPool = currentRound.matches.sorted(by: { $0.timestamp < $1.timestamp }).map({ $0.winner ?? nil })
        for match in nextRound.matches.sorted(by: { $0.timestamp < $1.timestamp }){
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
  let timestamp: Date = Date.now
  let matches: [TournamentMatch]
  var completed: Bool = false

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

  func sync() {
    matches.forEach({ $0.sync() })

    completed = matches.allSatisfy({ $0.winner != nil })
  }

  init(matches: [TournamentMatch]) {
    self.matches = matches
  }
}


enum TournamentMatchState: String, Codable {
  case Complete = "complete"
  case Ready = "ready"
  case Empty = "empty"
  // Complete: there is a first player, second player, both scores, and a winner
  // Ready: there is a first player, second player, no scores, and no winner
  // Empty: there is no first player or no second player, no scores, and no winner
}

@Model
class TournamentMatch: Identifiable {
  let timestamp: Date = Date.now
  var firstPlayer: TournamentPlayer?
  var secondPlayer: TournamentPlayer?
  var winner: TournamentPlayer?
  var firstPlayerScore: Int?
  var secondPlayerScore: Int?

  var id: String {
    UUID().uuidString
  }

  var state: TournamentMatchState {
    if let _ = firstPlayer, let _ = secondPlayer {
      if let _ = firstPlayerScore, let _ = secondPlayerScore {
        return .Complete
      } else {
        return .Ready
      }
    } else {
      return .Empty
    }

  }

  func sync() {
    if let firstPlayer, let secondPlayer, let firstPlayerScore, let secondPlayerScore {
      
      guard firstPlayerScore != secondPlayerScore else {
        winner = nil
        return
      }

      winner = firstPlayerScore > secondPlayerScore 
        ? firstPlayer
        : secondPlayer
    } else {
      winner = nil
    }
  }

  init(firstPlayer: TournamentPlayer?, secondPlayer: TournamentPlayer?, firstPlayerScore: Int?, secondPlayerScore: Int?) {
    self.firstPlayer = firstPlayer
    self.secondPlayer = secondPlayer
    self.firstPlayerScore = firstPlayerScore
    self.secondPlayerScore = secondPlayerScore
  }

  init(firstPlayer: TournamentPlayer?, secondPlayer: TournamentPlayer?) {
    self.firstPlayer = firstPlayer
    self.secondPlayer = secondPlayer
    self.firstPlayerScore = nil
    self.secondPlayerScore = nil
  }

  init() {
    self.firstPlayer = nil
    self.secondPlayer = nil
    self.firstPlayerScore = nil
    self.secondPlayerScore = nil
  }
}

@Model
class TournamentPlayer: Identifiable, Equatable {
  let timestamp: Date = Date.now
  let name: String

  static func == (lhs: TournamentPlayer, rhs: TournamentPlayer) -> Bool {
    return lhs.name == rhs.name
  }
  
  var id: String {
    name
  }

  init(name: String) {
    self.name = name
  }
}
