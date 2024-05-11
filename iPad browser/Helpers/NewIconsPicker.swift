//
//  NewIconsPicker.swift
//  Aura
//
//  Created by Caedmon Myers on 9/5/24.
//

import SwiftUI
import SwiftData

struct NewIconsPicker: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    @Binding var currentIcon: String
    
    @State var currentHoverIcon = ""
    
    @ObservedObject var navigationState: NavigationState
    @ObservedObject var pinnedNavigationState: NavigationState
    @ObservedObject var favoritesNavigationState: NavigationState
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = true
    
    @Binding var selectedSpaceIndex: Int
    var body: some View {
        ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem(), GridItem(), GridItem(), GridItem(), GridItem(), GridItem(), GridItem(), GridItem(), GridItem()]) {
                    ForEach(sfIconOptions, id:\.self) { icon in
                        Button {
                            currentIcon = icon
                            print("Icon: \(icon)")
                            print("Current Icon: \(currentIcon)")
                        } label: {
                            ZStack {
                                Color(.white)
                                    .opacity(currentIcon == icon ? 1.0: currentHoverIcon == icon ? 0.5: 0.0)
                                
                                Image(systemName: icon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(currentIcon == icon ? Color.black: Color.white)
                                    .opacity(currentHoverIcon == icon ? 1.0: 0.7)
                                
                            }.frame(width: 40, height: 40).cornerRadius(7)
                                .hoverEffect(.lift)
                                .hoverEffectDisabled(!hoverEffectsAbsorbCursor)
                                .onHover(perform: { hovering in
                                    if hovering {
                                        currentHoverIcon = icon
                                    }
                                    else {
                                        currentHoverIcon = ""
                                    }
                                })
                        }
                        
                    }
                }
            
        }.scrollIndicators(.hidden)
    }
    
    func saveSpaceData() {
            let savingTodayTabs = navigationState.webViews.compactMap { $0.url?.absoluteString }
            let savingPinnedTabs = pinnedNavigationState.webViews.compactMap { $0.url?.absoluteString }
            let savingFavoriteTabs = favoritesNavigationState.webViews.compactMap { $0.url?.absoluteString }
            
            if !spaces.isEmpty {
                spaces[selectedSpaceIndex].tabUrls = savingTodayTabs
            }
            else {
                modelContext.insert(SpaceStorage(spaceIndex: spaces.count, spaceName: "Untitled", spaceIcon: "circle.fill", favoritesUrls: [], pinnedUrls: [], tabUrls: savingTodayTabs))
            }
            
            do {
                try modelContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
}




