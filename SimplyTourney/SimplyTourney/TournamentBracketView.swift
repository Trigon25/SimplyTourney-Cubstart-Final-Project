//
//  TournamentBracketView.swift
//  SimplyTourney
//
//  Created by Marc Chern on 15/11/23.
//

import SwiftUI
import SwiftData

struct TournamentBracketView: View {
//  let bracket: TournamentBracket = getFullTestTournamentBracket();
    let bracket: TournamentBracket = getInitialTestTournamentBracket();

  var body: some View {
    TabView {
      ForEach(bracket.rounds) { round in
          GeometryReader {
            geo in
            ScrollView(.vertical, showsIndicators: false) {
              VStack {
                if round.name == bracket.rounds.last?.name {
                  Image(systemName: "trophy.fill")
                    .foregroundStyle(.linearGradient(colors: [.orange, .yellow], startPoint: .bottomLeading, endPoint: .topTrailing))
                    .imageScale(.large)
                }
                HStack {
                  Text(round.name.rawValue)
                    .font(.title2)
                  Image(systemName: round.completed ? "checkmark" : "hourglass.tophalf.filled")
                }
                ForEach(round.matches) {
                  match in
                  MatchView(match: match)
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
  @ViewBuilder let content: Content
  @State private var isUpdating: Bool = false
  @State var firstScore: Int = 0
  @State var secondScore: Int = 0

  var body: some View {
    Button (action: {
      self.isUpdating = true
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
            self.isUpdating = false
            self.firstScore = 0
            self.secondScore = 0
          }, label: {
            Text("Cancel")
          })
          .buttonStyle(.bordered)
          Button(action: {
            self.isUpdating = false
            self.firstScore = 0
            self.secondScore = 0
          }, label: {
            Text("Update")
          })
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
          UpdateScoreButton {
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
        nextScore += Int.random(in: 1...5)
      }
      match.secondPlayerScore = nextScore
    }
    bracket.syncRounds()
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
