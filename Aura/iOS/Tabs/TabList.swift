//
// Aura
// TabList.swift
//
// Created by Reyna Myers on 26/10/24
//
// Copyright ©2024 DoorHinge Apps.
//


import SwiftUI
import SwiftData

struct TabList: View {
    //@Namespace var namespace
    @Environment(\.namespace) var namespace
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject var mobileTabs: MobileTabsModel
    
    @Binding var selectedSpaceIndex: Int
    
    @FocusState.Binding var newTabFocus: Bool
    
    @State var geo: GeometryProxy
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 60)
            
            LazyVGrid(columns: [GridItem(spacing: 5), GridItem(spacing: 5)], content: {
                ForEach(mobileTabs.selectedTabsSection == .tabs ? mobileTabs.tabs: mobileTabs.selectedTabsSection == .pinned ? mobileTabs.pinnedTabs: mobileTabs.favoriteTabs, id: \.id) { tab in
                    let offset = mobileTabs.offsets[tab.id, default: .zero]
                    WebPreview(namespace: namespace, url: tab.url, geo: geo, tab: tab, browseForMeTabs: $mobileTabs.browseForMeTabs)
                        .rotationEffect(Angle(degrees: mobileTabs.tilts[tab.id, default: 0.0]))
                        .offset(x: offset.width)
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.0001))
                                .onTapGesture {
                                    mobileTabs.newTabFromTab = false
                                    
                                    if newTabFocus {
                                        newTabFocus = false
                                    }
                                    else {
                                        withAnimation {
                                            mobileTabs.webURL = tab.url
                                            mobileTabs.selectedTab = tab
                                            mobileTabs.fullScreenWebView = true
                                        }
                                    }
                                }
                        })
                        .gesture(
                            DragGesture(minimumDistance: 50)
                                .onChanged { gesture in
                                    if newTabFocus {
                                        newTabFocus = false
                                    }
                                    else {
                                        handleDragChange(gesture, for: tab.id)
                                    }
                                }
                                .onEnded { gesture in
                                    if newTabFocus {
                                        newTabFocus = false
                                    }
                                    else {
                                        handleDragEnd(gesture, for: tab.id)
                                    }
                                }
                        )
                        .contextMenu(menuItems: {
                            Button(action: {
                                UIPasteboard.general.string = tab.url
                            }, label: {
                                Label("Copy URL", systemImage: "link")
                            })
                            
                            if !mobileTabs.settings.hideBrowseForMe {
                                Button(action: {
                                    if mobileTabs.browseForMeTabs.contains(tab.id.description) {
                                        mobileTabs.browseForMeTabs.removeAll { $0 == tab.id.description }
                                    }
                                    else {
                                        mobileTabs.browseForMeTabs.append(tab.id.description)
                                    }
                                }, label: {
                                    Label(mobileTabs.browseForMeTabs.contains(tab.id.description) ? "Disable Browse for Me": "Browse for Me", systemImage: "face.smiling")
                                })
                            }
                        })
                        .onDrag {
                            self.mobileTabs.draggedTab = tab
                            return NSItemProvider(object: tab.url as NSString)
                        }
                        .onDrop(of: [.text], delegate: AlternateDropViewDelegate(destinationItem: tab, allTabs: mobileTabs.selectedTabsSection == .tabs ? $mobileTabs.tabs: mobileTabs.selectedTabsSection == .pinned ? $mobileTabs.pinnedTabs: $mobileTabs.favoriteTabs, draggedItem: $mobileTabs.draggedTab))
                        .onChange(of: mobileTabs.tabs.map { $0.url }, {
                            saveTabs()
                        })
                        .onChange(of: mobileTabs.pinnedTabs.map { $0.url }, {
                            saveTabs()
                        })
                        .onChange(of: mobileTabs.favoriteTabs.map { $0.url }, {
                            saveTabs()
                        })
                    
                }
            })
            .padding(10)
            
            Spacer()
                .frame(height: 120)
        }
    }
    
    private func handleDragChange(_ gesture: DragGesture.Value, for id: UUID) {
        mobileTabs.offsets[id] = gesture.translation
        mobileTabs.zIndexes[id] = 100
        var tilt = min(Double(abs(gesture.translation.width)) / 20, 15)
        if gesture.translation.width < 0 {
            tilt *= -1
        }
        mobileTabs.tilts[id] = tilt
        
        mobileTabs.closeTabScrollDisabledCounter = abs(Int(gesture.translation.width))
    }
    
    private func handleDragEnd(_ gesture: DragGesture.Value, for id: UUID) {
        mobileTabs.zIndexes[id] = 1
        if abs(gesture.translation.width) > 100 {
            withAnimation {
                if gesture.translation.width < 0 {
                    mobileTabs.offsets[id] = CGSize(width: -500, height: 0)
                } else {
                    mobileTabs.offsets[id] = CGSize(width: 500, height: 0)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        removeItem(id)
                    }
                }
            }
        } else {
            withAnimation {
                mobileTabs.offsets[id] = .zero
                mobileTabs.tilts[id] = 0.0
            }
        }
        
        mobileTabs.closeTabScrollDisabledCounter = 0
    }
    
    private func saveTabs() {
        if UserDefaults.standard.integer(forKey: "savedSelectedSpaceIndex") > spaces.count - 1 {
            selectedSpaceIndex = 0
        }
        
        if spaces.count > selectedSpaceIndex {
            // Extracting URLs from tabs, pinnedTabs, and favoriteTabs arrays
            let extractedTabUrls = mobileTabs.tabs.map { $0.url }
            let extractedPinnedUrls = mobileTabs.pinnedTabs.map { $0.url }
            let extractedFavoriteUrls = mobileTabs.favoriteTabs.map { $0.url }
            
            // Updating the corresponding space with the extracted URLs
            spaces[selectedSpaceIndex].tabUrls = extractedTabUrls
            spaces[selectedSpaceIndex].pinnedUrls = extractedPinnedUrls
            spaces[selectedSpaceIndex].favoritesUrls = extractedFavoriteUrls
        }
    }
    
    private func removeItem(_ id: UUID) {
        mobileTabs.browseForMeTabs.removeAll { $0 == id.description }
        
        switch mobileTabs.selectedTabsSection {
        case .tabs:
            if let index = mobileTabs.tabs.firstIndex(where: { $0.id == id }) {
                mobileTabs.tabs.remove(at: index)
                spaces[selectedSpaceIndex].tabUrls.remove(at: index)
            }
        case .pinned:
            if let index = mobileTabs.pinnedTabs.firstIndex(where: { $0.id == id }) {
                mobileTabs.pinnedTabs.remove(at: index)
                spaces[selectedSpaceIndex].pinnedUrls.remove(at: index)
            }
        case .favorites:
            if let index = mobileTabs.favoriteTabs.firstIndex(where: { $0.id == id }) {
                mobileTabs.favoriteTabs.remove(at: index)
                spaces[selectedSpaceIndex].favoritesUrls.remove(at: index)
            }
        }
        
        withAnimation {
            mobileTabs.offsets.removeValue(forKey: id)
            mobileTabs.tilts.removeValue(forKey: id)
            mobileTabs.zIndexes.removeValue(forKey: id)
        }
    }
}

