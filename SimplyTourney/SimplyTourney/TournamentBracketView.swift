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
      ForEach(Array(orderedRounds.enumerated()), id: \.element) { roundIndex, round in
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
                  Spacer()
                  if roundIndex > orderedRounds.startIndex {
                    Image(systemName: "arrow.left")
                  }
                  Text(round.name.rawValue)
                    .font(.title2)
                  if roundIndex < orderedRounds.endIndex-1 {
                    Image(systemName: "arrow.right")
                  }
                  Spacer()
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
    .navigationBarTitleDisplayMode(.inline)

    .background(LinearGradient(gradient: Gradient(colors: [.blue, Color(red:0.4627, green:0.8392, blue:1.0)]), startPoint: .top, endPoint: .bottom))
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
  let offWhite: Color = Color(red: 0.93, green: 0.96, blue: 1)

  var body: some View {
    ZStack {
      Capsule()
        .fill(offWhite.opacity(0.7))
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
  @State var firstScore: Int = 0
  @State var secondScore: Int = 0
  let offWhite: Color = Color(red: 0.93, green: 0.96, blue: 1)
  let validScoreRange = 0...999

  var hasValidScores: Bool {
      guard firstScore != secondScore else {
        return false
      }
      return validScoreRange.contains(firstScore) && validScoreRange.contains(secondScore)
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
          .foregroundColor(.black.opacity(0.65))
          .imageScale(.large)
          .offset(x: -5.0)
      }
    })
    .popover(isPresented: $isUpdating, attachmentAnchor: .point(.trailing), arrowEdge: .top) {
      VStack {
        HStack {
          Image(systemName: "person.fill")
          Text(match.firstPlayer?.name ?? "Player 1")
          Spacer()
          TextField("Score", value: $firstScore, formatter: NumberFormatter())
            .keyboardType(.numberPad)
            .monospaced()
            .frame(width: 50)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .fixedSize(horizontal: true, vertical: false)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .onChange(of: firstScore) {
              guard validScoreRange.contains(firstScore) else {
                if firstScore > validScoreRange.upperBound {
                  firstScore = validScoreRange.upperBound
                } else if firstScore < validScoreRange.lowerBound {
                  firstScore = validScoreRange.lowerBound
                } else {
                  firstScore = 0
                }
                return
              }
            }
        }

        HStack {
          Image(systemName: "person.fill")
          Text(match.secondPlayer?.name ?? "Player 2")
          Spacer()
          TextField("Score", value: $secondScore, formatter: NumberFormatter())
            .keyboardType(.numberPad)
            .monospaced()
            .frame(width: 50)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .fixedSize(horizontal: true, vertical: false)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .onChange(of: secondScore) {
              guard validScoreRange.contains(secondScore) else {
                if secondScore > validScoreRange.upperBound {
                  secondScore = validScoreRange.upperBound
                } else if secondScore < validScoreRange.lowerBound {
                  secondScore = validScoreRange.lowerBound
                } else {
                  secondScore = 0
                }
                return
              }
            }
        }

        HStack {
          Button(action: {
            match.firstPlayerScore = firstScore
            match.secondPlayerScore = secondScore
            isUpdating = false
            bracket.sync()
          }, label: {
            Text("Update")
              .padding(12.0)
              .foregroundStyle(.white)
              .background(RoundedRectangle(cornerRadius: 20).fill(Color.green.opacity(0.9)))
          })
//          .buttonStyle(.borderedProminent)
//          .buttonBorderShape(.capsule)
//          .accentColor(.green)
//          .background(RoundedRectangle(cornerRadius: 20).fill(Color.green))
          .disabled(!hasValidScores)
          .opacity(hasValidScores ? 1.0 : 0.6)
//          .foregroundStyle(.white)
//          .accentColor(.green)
          Button(action: {
            isUpdating = false
          }, label: {
            Text("Cancel")
              .padding(12.0)
              .foregroundStyle(.white)
              .background(RoundedRectangle(cornerRadius: 20).fill(Color.red.opacity(0.9)))
          })
//          .buttonStyle(.bordered)
//          .buttonBorderShape(.capsule)
//          .background(RoundedRectangle(cornerRadius: 20).fill(Color.red))
        }
      }
      .padding()
      .background(offWhite)
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
