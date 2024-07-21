//
// Aura
// Menu Space Picker.swift
//
// Created by Reyna Myers on 21/7/24
//
// Copyright ©2024 DoorHinge Apps.
//


import SwiftUI
import SwiftData

struct MenuSpacePicker: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    
    @Binding var currentSpace: String
    @Binding var selectedSpaceIndex: Int
    
    @EnvironmentObject var variables: ObservableVariables
    
    @EnvironmentObject var manager: WebsiteManager
    
    @State var hoverSpace = ""
    
    @AppStorage("textColorHex") var textHex = "ffffff"
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = true
    
    var body: some View {
        Menu {
            ForEach(0..<(spaces.count), id:\.self) { space in
                Button {
                    currentSpace = String(spaces[space].spaceName)
                    
                    selectedSpaceIndex = space
                    
                } label: {
                    Label(spaces[space].spaceName, systemImage: String(spaces[space].spaceIcon))
                }
                .buttonStyle(.plain)
                .contextMenu(ContextMenu(menuItems: {
                    Button(action: {
                        if selectedSpaceIndex > spaces.count - 2 {
                            selectedSpaceIndex = spaces.count - 2
                            if selectedSpaceIndex < 0 {
                                selectedSpaceIndex = 0
                            }
                        }
                        
                        //spaces.remove(at: space)
                        if spaces.count > 1 {
                            modelContext.delete(spaces[space])
                        }
                        
                        Task {
                            do {
                                try await modelContext.save()
                            }
                            catch {
                                print(error.localizedDescription)
                            }
                        }
                        
                        
                    }, label: {
                        Text("Delete Space")
                    })
                }))
                
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    .fill(Color(.white).opacity(0.0))
                
                Image(systemName: spaces[selectedSpaceIndex].spaceIcon)
                    .foregroundStyle(Color.white)
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .padding(10)
            }
            .frame(width: 50, height: 50)
        }
    }
}
