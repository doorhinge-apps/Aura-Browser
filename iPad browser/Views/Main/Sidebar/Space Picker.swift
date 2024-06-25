//
//  Space Picker.swift
//  Aura
//
//  Created by Caedmon Myers on 24/5/24.
//

import SwiftUI
import SwiftData

struct SpacePicker: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    
    @ObservedObject var navigationState: NavigationState
    @ObservedObject var pinnedNavigationState: NavigationState
    @ObservedObject var favoritesNavigationState: NavigationState
    
    @Binding var currentSpace: String
    @Binding var selectedSpaceIndex: Int
    
    @State var hoverSpace = ""
    
    @AppStorage("textColorHex") var textHex = "ffffff"
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = true
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0..<(spaces.count), id:\.self) { space in
                    Button {
                        currentSpace = String(spaces[space].spaceName)
                        
                        selectedSpaceIndex = space
                        
                        Task {
                            await navigationState.webViews.removeAll()
                            await pinnedNavigationState.webViews.removeAll()
                            await favoritesNavigationState.webViews.removeAll()
                        }
                        
                        Task {
                            await navigationState.selectedWebView = nil
                            await navigationState.currentURL = nil
                            
                            await pinnedNavigationState.selectedWebView = nil
                            await pinnedNavigationState.currentURL = nil
                            
                            await favoritesNavigationState.selectedWebView = nil
                            await favoritesNavigationState.currentURL = nil
                        }
                        
                        Task {
                            for addSpace in spaces {
                                if addSpace.spaceName == currentSpace {
                                    for tab in addSpace.tabUrls {
                                        await navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: tab) ?? URL(string: "https://figma.com")!))
                                    }
                                    for tab in addSpace.pinnedUrls {
                                        await pinnedNavigationState.createNewWebView(withRequest: URLRequest(url: URL(string: tab) ?? URL(string: "https://thebrowser.company")!))
                                    }
                                    for tab in addSpace.favoritesUrls {
                                        await favoritesNavigationState.createNewWebView(withRequest: URLRequest(url: URL(string: tab) ?? URL(string: "https://arc.net")!))
                                    }
                                }
                            }
                        }
                        
                        Task {
                            await navigationState.selectedWebView = nil
                            await pinnedNavigationState.selectedWebView = nil
                            await favoritesNavigationState.selectedWebView = nil
                        }
                        
                    } label: {
                        ZStack {
#if !os(visionOS)
                            Color(.white)
                                .opacity(selectedSpaceIndex == space ? 1.0: hoverSpace == spaces[space].spaceName ? 0.5: 0.0)
                            #endif
                            
                            Image(systemName: String(spaces[space].spaceIcon))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
#if !os(visionOS)
                                .foregroundStyle(selectedSpaceIndex == space ? Color.black: Color(hex: textHex))
                            #else
                                .foregroundStyle(Color.white)
                            #endif
                                .opacity(selectedSpaceIndex == space ? 1.0: hoverSpace == spaces[space].spaceName ? 1.0: 0.5)
                            
                        }.frame(width: 40, height: 40).cornerRadius(7)
                            .buttonStyle(.plain)
#if !os(visionOS)
                            .hoverEffect(.lift)
                            .hoverEffectDisabled(!hoverEffectsAbsorbCursor)
                        #endif
                            .help(spaces[space].spaceName/*.dropLast(5)*/)
                            .onHover(perform: { hovering in
                                if hovering {
                                    if space <= spaces.count - 1 {
                                        hoverSpace = spaces[space].spaceName
                                    }
                                    print("Space: \(space)")
                                    print("Spaces Count: \(spaces.count)")
                                    print("Selected Space Index: \(selectedSpaceIndex)")
                                }
                                else {
                                    hoverSpace = ""
                                }
                            })
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
            }.padding(.horizontal, 10)
        }.scrollIndicators(.hidden)
            .frame(height: 45)
    }
}
