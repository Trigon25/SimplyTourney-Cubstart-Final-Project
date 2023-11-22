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
    
    @State private var newTournament: String = ""
    @State private var bracketSize = 16
    @State private var playerList: [String] = []
    @State private var newPlayerName: String = ""
    
    @State private var showingAlert = false
    @State private var bracketSizeAlert = false
    var body: some View {
        VStack {
            Text("Create New Tournament")
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .padding()
                .frame(width: UIScreen.main.bounds.width, height: 100)
                .background(UnevenRoundedRectangle(cornerRadii: .init(bottomLeading: 15.0, bottomTrailing: 15.0)).fill(Color.blue.opacity(0.65)))
            
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
            
            Text("Player List:  \(playerList.count)")
                .foregroundStyle(.white)
                .padding()
                .frame(width: UIScreen.main.bounds.width)
                .background(Rectangle().fill(.blue.opacity(0.65)))

            List{
                ForEach(playerList, id: \.self) { player in
                    Text(player).font(.system(size: 16.0))
                }.onDelete(perform: delete)
            }
            .modifier(EmptyDataModifier(
                items: playerList,
                placeholder: Text("No players")
                    .foregroundStyle(.gray.opacity(0.5))
                    .padding()
            ))
            
            HStack {
                Button{
                    if playerList.count == bracketSize {
                        // TODO: append the new bracket to swiftdata; current problem is that swiftdata models are not set up, might need to change the way we set up the model file for us to be able to query it.
                        let newBracket = ViewModel.scaffoldBracket(name: newTournament, players: playerList, size: bracketSize == 16 ? .Sixteen : .ThirtyTwo)
                        
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
                    Text("Discard")
                        .foregroundStyle(.white)
                        .padding()
                        .frame(width: 100, height: 50)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.red.opacity(0.9)))
                }
            }
            
            Spacer()
        }

    }
    
    
    func delete(at offsets: IndexSet) {
        playerList.remove(atOffsets: offsets)
    }
}


struct EmptyDataModifier<Placeholder: View>: ViewModifier {
    let items: [Any]
    let placeholder: Placeholder

    @ViewBuilder
    func body(content: Content) -> some View {
        if !items.isEmpty {
            content
        } else {
            placeholder
        }
    }
}


#Preview {
    CreateNewTourneyBracketView()
}
