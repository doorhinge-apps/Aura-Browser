//
//  TabOverview.swift
//  Aura
//
//  Created by Caedmon Myers on 25/6/24.
//

import SwiftUI
import WebKit
import SDWebImage
import SDWebImageSwiftUI
import SwiftData

struct TabOverview: View {
    @Namespace var namespace
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    @Binding var selectedSpaceIndex: Int
    @Environment(\.modelContext) private var modelContext
    
    @State private var tabs: [(id: UUID, url: String)]
    @State private var pinnedTabs: [(id: UUID, url: String)]
    @State private var favoriteTabs: [(id: UUID, url: String)]
    @State private var offsets: [UUID: CGSize] = [:]
    @State private var tilts: [UUID: Double] = [:]
    @State private var zIndexes: [UUID: Double] = [:]
    
    @State var selectedTab: (id: UUID, url: String)?
    
    @EnvironmentObject var variables: ObservableVariables
    @StateObject var settings = SettingsVariables()
    
    @State var selectedTabsSection: TabLocations = .tabs
    
    @State var fullScreenWebView = false
    
    init(selectedSpaceIndex: Binding<Int>) {
        self._selectedSpaceIndex = selectedSpaceIndex
        self._tabs = State(initialValue: [])
        self._pinnedTabs = State(initialValue: [])
        self._favoriteTabs = State(initialValue: [])
    }
    
    var body: some View {
        GeometryReader { geo in
            
                    ZStack {
                        ScrollView {
                            VStack {
                                LazyVGrid(columns: [GridItem(spacing: 5), GridItem(spacing: 5)], content: {
                                    ForEach(selectedTabsSection == .tabs ? tabs: selectedTabsSection == .pinned ? pinnedTabs: favoriteTabs, id: \.id) { tab in
                                        let offset = offsets[tab.id, default: .zero]
                                        WebPreview(namespace: namespace, url: tab.url, geo: geo, tab: tab)
                                            .rotationEffect(Angle(degrees: tilts[tab.id, default: 0.0]))
                                            .offset(x: offset.width)
                                            .overlay(content: {
                                                RoundedRectangle(cornerRadius: 15)
                                                    .fill(Color.white.opacity(0.0001))
                                                    .onTapGesture {
                                                        withAnimation {
                                                            selectedTab = tab
                                                            fullScreenWebView = true
                                                        }
                                                    }
                                            })
                                            .simultaneousGesture(
                                                DragGesture(minimumDistance: 20)
                                                    .onChanged { gesture in
                                                        handleDragChange(gesture, for: tab.id)
                                                    }
                                                    .onEnded { gesture in
                                                        handleDragEnd(gesture, for: tab.id)
                                                    }
                                            )
                                    }
                                })
                                .padding(10)
                            }
                        }
                        
                        HStack {
                            Spacer()
                            
                            VStack {
                                Button(action: {
                                    withAnimation {
                                        selectedTabsSection = .favorites
                                    }
                                }, label: {
                                    Image(systemName: "star")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: selectedTabsSection == .favorites ? 30: 20)
                                        .opacity(selectedTabsSection == .favorites ? 1.0: 0.4)
                                        .foregroundStyle(Color(hex: "4D4D4D"))
                                })
                                .padding(.vertical, 5)
                                
                                Button(action: {
                                    withAnimation {
                                        selectedTabsSection = .pinned
                                    }
                                }, label: {
                                    Image(systemName: "pin")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: selectedTabsSection == .pinned ? 30: 20)
                                        .opacity(selectedTabsSection == .pinned ? 1.0: 0.4)
                                        .foregroundStyle(Color(hex: "4D4D4D"))
                                })
                                .padding(.vertical, 5)
                                
                                Button(action: {
                                    withAnimation {
                                        selectedTabsSection = .tabs
                                    }
                                }, label: {
                                    Image(systemName: "calendar.day.timeline.left")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: selectedTabsSection == .tabs ? 30: 20)
                                        .opacity(selectedTabsSection == .tabs ? 1.0: 0.4)
                                        .foregroundStyle(Color(hex: "4D4D4D"))
                                })
                                .padding(.vertical, 5)
                            }
                            .frame(width: 50, height: 150)
                            .background(
                                RoundedRectangle(cornerRadius: 50)
                                    .fill(.regularMaterial)
                            )
                            .padding(.trailing, 5)
                        }.padding(2)
                        
                        VStack {
                            Spacer()
                            spaceSelector
                        }
                        
                        if fullScreenWebView {
                            WebsiteView(namespace: namespace, url: selectedTab!.url, parentGeo: geo, fullScreenWebView: $fullScreenWebView, tab: selectedTab!)
                        }
                        
                    }
            
            
        }
        .onAppear {
            updateTabs()
        }
    }
    
    private var spaceSelector: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { proxy in
                    HStack(spacing: 10) {
                        ForEach(spaces.indices, id: \.self) { index in
                            Button(action: {
                                withAnimation {
                                    selectedSpaceIndex = index
                                    updateTabs()
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.regularMaterial)
                                        .frame(width: geometry.size.width - 50, height: 50)
                                    
                                    HStack {
                                        Image(systemName: spaces[index].spaceIcon)
                                        Text(spaces[index].spaceName)
                                    }
                                    .foregroundStyle(Color(hex: "4D4D4D"))
                                    .font(.system(size: 16, weight: .bold))
                                    .opacity(selectedSpaceIndex == index ? 1.0 : 0.4)
                                    .padding(.horizontal, 15)
                                }
                                .frame(width: geometry.size.width / 2, height: 50)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(15)
                                .contentShape(Rectangle())
                                .id(index) // Identify each item by its index
                                .onAppear {
                                    if selectedSpaceIndex == index {
                                        proxy.scrollTo(index, anchor: .center) // Snap to center on appear
                                    }
                                }
                                .onTapGesture {
                                    withAnimation {
                                        selectedSpaceIndex = index
                                        updateTabs()
                                        proxy.scrollTo(index, anchor: .center) // Snap to center on tap
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                }
            }
            .background(Color.white.opacity(0.8))
            .padding(.bottom)
        }.frame(height: 75)
    }

    
    private func handleDragChange(_ gesture: DragGesture.Value, for id: UUID) {
        offsets[id] = gesture.translation
        zIndexes[id] = 100
        var tilt = min(Double(abs(gesture.translation.width)) / 20, 15)
        if gesture.translation.width < 0 {
            tilt *= -1
        }
        tilts[id] = tilt
    }
    
    private func handleDragEnd(_ gesture: DragGesture.Value, for id: UUID) {
        zIndexes[id] = 1
        if abs(gesture.translation.width) > 50 {
            withAnimation {
                if gesture.translation.width < 0 {
                    offsets[id] = CGSize(width: -500, height: 0)
                } else {
                    offsets[id] = CGSize(width: 500, height: 0)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        removeItem(id)
                    }
                }
            }
        } else {
            withAnimation {
                offsets[id] = .zero
                tilts[id] = 0.0
            }
        }
    }
    
    private func updateTabs() {
        var temporaryTabs = spaces[selectedSpaceIndex].tabUrls.map { (id: UUID(), url: $0) }
        tabs = temporaryTabs.reversed()
        pinnedTabs = spaces[selectedSpaceIndex].pinnedUrls.map { (id: UUID(), url: $0) }
        favoriteTabs = spaces[selectedSpaceIndex].favoritesUrls.map { (id: UUID(), url: $0) }
    }
    
    private func removeItem(_ id: UUID) {
        if let index = tabs.firstIndex(where: { $0.id == id }) {
            tabs.remove(at: index)
            spaces[selectedSpaceIndex].tabUrls.remove(at: index)
        }
        offsets.removeValue(forKey: id)
        tilts.removeValue(forKey: id)
        zIndexes.removeValue(forKey: id)
    }
}

struct WebPreview: View {
    let namespace: Namespace.ID
    @State var url: String
    @State private var webTitle: String = ""
    
    @StateObject var settings = SettingsVariables()
    
    var geo: GeometryProxy
    
    @State var faviconSize = CGFloat(20)
    
    @State var tab: (id: UUID, url: String)
    
    var body: some View {
        VStack {
#if !os(macOS)
            ZStack {
                Color.white.opacity(0.0001)
                
                WebViewMobile(urlString: url, title: $webTitle)
                    .frame(width: geo.size.width - 50, height: 400)
                    .disabled(true)
                
            }
            .scaleEffect(0.5)
            .frame(width: geo.size.width / 2 - 25, height: 200) // Small size for tappable area
            .clipped()
            .cornerRadius(15)
            
            HStack {
                if settings.faviconLoadingStyle {
                    WebImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(url)&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: faviconSize, height: faviconSize)
                            .cornerRadius(settings.faviconShape == "square" ? 0: settings.faviconShape == "squircle" ? 5: 100)
                            .padding(.leading, 5)
                        
                    } placeholder: {
                        LoadingAnimations(size: Int(faviconSize), borderWidth: 5.0)
                            .padding(.leading, 5)
                    }
                    .onSuccess { image, data, cacheType in
                        
                    }
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFit()
                    
                } else {
                    AsyncImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(url)&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: faviconSize, height: faviconSize)
                            .cornerRadius(settings.faviconShape == "square" ? 0: settings.faviconShape == "squircle" ? 5: 100)
                            .padding(.leading, 5)
                        
                    } placeholder: {
                        LoadingAnimations(size: Int(faviconSize), borderWidth: 5.0)
                            .padding(.leading, 5)
                    }
                    
                }
                
                Text(webTitle)
                    .foregroundStyle(Color.black)
                    .font(.system(.body, design: .rounded, weight: .regular))
                    .lineLimit(1)
                
                Spacer()
            }
#endif
        }.matchedGeometryEffect(id: tab.id, in: namespace)
    }
}
