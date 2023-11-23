//
//  ViewModel.swift
//  SimplyTourney
//
//  Created by Danny on 11/20/23.
//

import Foundation
import SwiftData

//@Model
class ViewModel: ObservableObject {
  var brackets: [TournamentBracket]

  init(brackets: [TournamentBracket]) {
    self.brackets = brackets
  }

  // TODO: this should scaffold out a new TournamentBracket with the initial round, and empty rounds for the following ones
  static func scaffoldBracket(name: String, players: [String], size: TournamentBracketSize) -> TournamentBracket {
      // Get players
      var playerList : [TournamentPlayer]  = []
      for player in players {
          playerList.append(TournamentPlayer(name: player))
      }
      let scaffoldBracket = TournamentBracket(name: name, size: size, players: playerList)
      return scaffoldBracket
  }
}
