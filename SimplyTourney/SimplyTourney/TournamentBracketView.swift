//
//  TournamentBracketView.swift
//  SimplyTourney
//
//  Created by Marc Chern on 15/11/23.
//

import SwiftUI
import SwiftData

struct TournamentBracketView: View {
  @Environment(\.modelContext) private var modelContext
  @Bindable var bracket: TournamentBracket
  var orderedRounds: [TournamentRound] {
    bracket.rounds.sorted(by: {$0.timestamp < $1.timestamp})
  }

  var body: some View {
    TabView {
//      ForEach(bracket.orderedRounds) { round in
      ForEach(orderedRounds) { round in
          GeometryReader {
            geo in
            ScrollView(.vertical, showsIndicators: false) {
              VStack {
//                if round.name == bracket.orderedRounds.last?.name {
                if round.name == orderedRounds.last?.name {
                  Image(systemName: "trophy.fill")
                    .foregroundStyle(.linearGradient(colors: [.orange, .yellow], startPoint: .bottomLeading, endPoint: .topTrailing))
                    .imageScale(.large)
                }
                HStack {
                  Text(round.name.rawValue)
                    .font(.title2)
                  Image(systemName: round.completed ? "checkmark" : "hourglass.tophalf.filled")
                }
//                ForEach(round.orderedMatches) {
                ForEach(round.matches.sorted(by: {$0.timestamp < $1.timestamp})) {
                  match in
                  MatchView(match: match, bracket: bracket)
                    .padding(30.0)
                }
              }
              .frame(minHeight: geo.size.height)
            }
          }
      }
    }
    .safeAreaPadding(.horizontal, 5)
    .tabViewStyle(.page(indexDisplayMode: .always))
    .navigationTitle(bracket.name)
    .onAppear {
      let blue = UIColor(Color.blue)
      UIPageControl.appearance().currentPageIndicatorTintColor = blue
      UIPageControl.appearance().pageIndicatorTintColor = blue.withAlphaComponent(0.3)

    }
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
        .strokeBorder(lineWidth: isWinner == true ? 2.0 : 0)
      HStack {
        if let player = player {
          Text(player.name)
            .padding(.leading, 20.0)
            .padding(.vertical, 5.0)

          Spacer()
          Divider()
            .bold()
            .frame(width: isWinner == true ? 2.0 : 0.5)
            .overlay(.black)
          if let score = score {

            Text("\(score)".padding(toLength: 3, withPad: " ", startingAt: 0))
              .padding(.trailing, 10.0)
              .monospaced()
              .fontWeight(isWinner == true ? .bold : .regular)
          } else {
            Text("   ")
              .padding(.trailing, 10.0)
              .monospaced()
          }
        } else {
          Image(systemName: "lock.fill")
        }

      }
      .foregroundColor(.black)
    }
    .opacity(isWinner == true || score == nil ? 1.0 : 0.4)
    .frame(height: 40.0)
  }
}

struct UpdateScoreButton<Content: View>: View {
  @Bindable var match: TournamentMatch
  @Bindable var bracket: TournamentBracket
  @ViewBuilder let content: Content
  @State private var isUpdating: Bool = false
  @State var firstScore: Int? = 0
  @State var secondScore: Int? = 0

  var hasValidScores: Bool {
    if let firstScore, let secondScore {
      guard firstScore != secondScore else {
        return false
      }
      let validScores = 0...999
      return validScores.contains(firstScore) && validScores.contains(secondScore)
    } else {
      return false
    }
  }

  var body: some View {
    Button (action: {
      firstScore = 0
      secondScore = 0
      isUpdating = true
    }, label: {
      HStack {
        VStack {
          content
        }
        Image(systemName: "arrow.forward.circle.fill")
          .foregroundColor(.blue.opacity(0.65))
          .imageScale(.large)
          .offset(x: -5.0)
      }
    })
    .popover(isPresented: $isUpdating, attachmentAnchor: .point(.trailing), arrowEdge: .top) {
      VStack {
        HStack {
          Text("player 1")
          TextField("Placeholder", value: $firstScore, formatter: NumberFormatter())
            .keyboardType(.numberPad)
            .monospaced()
        }
        HStack {
          Text("player 2")
          TextField("Placeholder", value: $secondScore, formatter: NumberFormatter())
            .keyboardType(.numberPad)
            .monospaced()
        }

        HStack {
          Button(action: {
            isUpdating = false
          }, label: {
            Text("Cancel")
          })
          .buttonStyle(.bordered)
          Button(action: {
            match.firstPlayerScore = firstScore
            match.secondPlayerScore = secondScore
            isUpdating = false
            bracket.sync()
          }, label: {
            Text("Update")
          }).disabled(!hasValidScores)
        }
        .buttonStyle(.borderedProminent)
      }
      .padding()
      .presentationCompactAdaptation(.popover)
    }
  }
}

struct MatchView: View {
  let match: TournamentMatch
  let bracket: TournamentBracket
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
        UpdateScoreButton(match: match, bracket: bracket) {
            MatchPlayerView(player: match.firstPlayer)
            MatchPlayerView(player: match.secondPlayer)
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
    .frame(width: 280.0)
  }
}




//#Preview {
//  TournamentBracketView(bracket: getFullTestTournamentBracket())
//    .modelContainer(for: [
//      TournamentBracket.self,
//      TournamentRound.self,
//      TournamentMatch.self,
//      TournamentPlayer.self
//    ])
//}
