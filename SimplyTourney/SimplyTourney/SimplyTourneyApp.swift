//
//  SimplyTourneyApp.swift
//  SimplyTourney
//
//  Created by Marc Chern on 15/11/23.
//

import SwiftUI

@main
struct SimplyTourneyApp: App {
  var body: some Scene {
    WindowGroup {
      StartingView()
        .modelContainer(for: [
          TournamentBracket.self,
          TournamentRound.self,
          TournamentMatch.self,
        ])
    }
  }
}
