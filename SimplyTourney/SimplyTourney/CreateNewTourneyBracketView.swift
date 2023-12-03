//
//  CreateNewTourneyBracketView.swift
//  SimplyTourney
//
//  Created by Marc Chern on 15/11/23.
//

import SwiftUI
import SwiftData

struct CreateNewTourneyBracketView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext


    @State private var newTournament: String = ""
    @State private var bracketSize = 16
    @State private var playerList: [String] = []
    @State private var newPlayerName: String = ""
    
    @State private var showingAlert = false
    @State private var bracketSizeAlert = false

  let offWhite: Color = Color(red: 0.93, green: 0.96, blue: 1)
    var body: some View {
        VStack {
            Text("Create New Tournament")
//            .fontWeight(.semibold)
            .font(.title2)
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding()
                .frame(width: UIScreen.main.bounds.width, height: 100)
//                .background(UnevenRoundedRectangle(cornerRadii: .init(bottomLeading: 15.0, bottomTrailing: 15.0)).fill(Color.blue.opacity(0.85)))
            
            VStack {
                HStack {
                    Text("Tournament:").frame(width: UIScreen.main.bounds.width/3.5)
                    TextField("New Tournament", text: $newTournament)
                        .font(.system(size: 16.0))
                        .foregroundStyle(.primary)
                }.padding(EdgeInsets(top: 25, leading: 0, bottom: 25, trailing: 0))
                
                HStack {
                    Text("Bracket Size:").frame(width: UIScreen.main.bounds.width/3.5)
                    Picker("Bracket Size", selection: $bracketSize){
                        Text("16").tag(16)
                        Text("32").tag(32)
                    }.pickerStyle(.segmented)
                }.padding(EdgeInsets(top: 25, leading: 0, bottom: 25, trailing: 0))
                
                HStack {
                    Text("Add Player:").frame(width: UIScreen.main.bounds.width/3.5)
                    TextField("New Player", text: $newPlayerName)
                        .font(.system(size: 16.0))
                        .foregroundStyle(.primary)
                        .frame(width: 200)
                    Button {
                        if newPlayerName.isEmpty {
                            showingAlert = true
                        } else {
                            playerList.append(newPlayerName)
                            newPlayerName = ""
                        }
                    } label: {
                        Image(systemName: "plus.app.fill").imageScale(.large)
                    }.alert("Player Name is Empty", isPresented: $showingAlert) {
                        Button("OK", role:.cancel){}
                    }
                    
                }.padding(EdgeInsets(top: 25, leading: 0, bottom: 25, trailing: 0))
            }.padding()
            .background(offWhite)


            Text("Player List:  \(playerList.count)")
                .foregroundStyle(.white)
                .padding()
                .frame(width: UIScreen.main.bounds.width)
                .background(Rectangle().fill(.blue.opacity(0.65)))

            List{
                ForEach(playerList, id: \.self) { player in
                    Text(player).font(.system(size: 16.0))
                    .listRowBackground(offWhite)
                }.onDelete(perform: delete)
            }
            .overlay(Group {
              if playerList.isEmpty {
                Text("No players")
              }
            }
            )
            .scrollContentBackground(.hidden)
//            .background(offWhite.blendMode(.plusDarker))
            .background(Color.clear)

            HStack {
                Button{
                    if playerList.count == bracketSize {
                      let newBracket = TournamentBracket(
                        name: newTournament,
                        size: bracketSize,
                        players: playerList
                      )
                      modelContext.insert(newBracket)

                        newTournament = ""
                        playerList = []
                        bracketSize = 16
                        newPlayerName = ""
                        dismiss()
                    } else {
                        bracketSizeAlert = true
                    }
                } label: {
                    Text("Save")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(width: 100, height: 50)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.green.opacity(0.9)))
                }.alert("Number of players does not correspond to bracket size", isPresented: $bracketSizeAlert) {
                    Button("OK", role:.cancel){}
                }
                
                Button {
                    newTournament = ""
                    playerList = []
                    bracketSize = 16
                    newPlayerName = ""
                    dismiss()
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(width: 100, height: 50)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.red.opacity(0.9)))
                }
            }
            .padding(.top, 10.0)

        }
        .background(LinearGradient(gradient: Gradient(colors: [.blue, Color(red:0.4627, green:0.8392, blue:1.0)]), startPoint: .top, endPoint: .bottom))

    }
    
    
    func delete(at offsets: IndexSet) {
        playerList.remove(atOffsets: offsets)
    }
}



#Preview {
  CreateNewTourneyBracketView()
    .modelContainer(for: [
      TournamentBracket.self,
      TournamentRound.self,
      TournamentMatch.self,
      TournamentPlayer.self
    ])
}
