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
    @State private var offsets: [UUID: CGSize] = [:]
    @State private var tilts: [UUID: Double] = [:]
    @State private var zIndexes: [UUID: Double] = [:]
    
    @EnvironmentObject var variables: ObservableVariables
    @StateObject var settings = SettingsVariables()
    
    @State var selectedTabsSection: TabLocations = .tabs
    
    init(selectedSpaceIndex: Binding<Int>) {
        self._selectedSpaceIndex = selectedSpaceIndex
        self._tabs = State(initialValue: [])
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ScrollView {
                    VStack {
                        LazyVGrid(columns: [GridItem(spacing: 5), GridItem(spacing: 5)], content: {
                            ForEach(tabs, id: \.id) { tab in
                                let offset = offsets[tab.id, default: .zero]
                                NavigationLink(destination: {
                                    if #available(iOS 18.0, visionOS 2.0, *) {
                                        WebsiteView(url: tab.url, parentGeo: geo)
#if !os(macOS)
                                            .navigationTransition(.zoom(sourceID: tab.id, in: namespace))
#endif
                                    }
                                    else {
                                        WebsiteView(url: tab.url, parentGeo: geo)
                                    }
                                }, label: {
                                    if #available(iOS 18.0, visionOS 2.0, *) {
                                        WebPreview(url: tab.url, geo: geo)
#if !os(macOS)
                                            .matchedTransitionSource(id: tab.id, in: namespace)
#endif
                                            .rotationEffect(Angle(degrees: tilts[tab.id, default: 0.0]))
                                            .offset(x: offset.width)
                                            .gesture(
                                                DragGesture()
                                                    .onChanged { gesture in
                                                        handleDragChange(gesture, for: tab.id)
                                                    }
                                                    .onEnded { gesture in
                                                        handleDragEnd(gesture, for: tab.id)
                                                    }
                                            )
                                    } else {
                                        WebPreview(url: tab.url, geo: geo)
                                            .rotationEffect(Angle(degrees: tilts[tab.id, default: 0.0]))
                                            .offset(x: offset.width)
                                            .gesture(
                                                DragGesture()
                                                    .onChanged { gesture in
                                                        handleDragChange(gesture, for: tab.id)
                                                    }
                                                    .onEnded { gesture in
                                                        handleDragEnd(gesture, for: tab.id)
                                                    }
                                            )
                                    }
                                })
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
                                .frame(width: selectedTabsSection == .favorites ? 20: 15)
                                .opacity(selectedTabsSection == .favorites ? 1.0: 0.5)
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
                                .frame(width: selectedTabsSection == .pinned ? 20: 15)
                                .opacity(selectedTabsSection == .pinned ? 1.0: 0.5)
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
                                .frame(width: selectedTabsSection == .tabs ? 20: 15)
                                .opacity(selectedTabsSection == .tabs ? 1.0: 0.5)
                                .foregroundStyle(Color(hex: "4D4D4D"))
                        })
                        .padding(.vertical, 5)
                    }
                    .frame(width: 30, height: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 50)
                            .fill(.regularMaterial)
                    )
                }.padding(2)
                
                VStack {
                    Spacer()
                    spaceSelector
                }
            }
        }
        .onAppear {
            updateTabs()
        }
    }
    
    private func tabView(for tab: (id: UUID, url: String), geo: GeometryProxy) -> some View {
        let offset = offsets[tab.id, default: .zero]
        
        return NavigationLink(destination: WebsiteView(url: tab.url, parentGeo: geo)) {
            WebPreview(url: tab.url, geo: geo)
                .rotationEffect(Angle(degrees: tilts[tab.id, default: 0.0]))
                .offset(x: offset.width)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            handleDragChange(gesture, for: tab.id)
                        }
                        .onEnded { gesture in
                            handleDragEnd(gesture, for: tab.id)
                        }
                )
        }
        .zIndex(zIndexes[tab.id, default: 0])
    }
    
    private var spaceSelector: some View {
        HStack {
            ForEach(spaces.indices, id: \.self) { index in
                Button(action: {
                    selectedSpaceIndex = index
                    updateTabs()
                }) {
                    Image(systemName: spaces[index].spaceIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(selectedSpaceIndex == index ? .blue : .gray)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(15)
        .padding(.bottom)
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
        tabs = spaces[selectedSpaceIndex].tabUrls.map { (id: UUID(), url: $0) }
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
    @State var url: String
    @State private var webTitle: String = ""
    
    @StateObject var settings = SettingsVariables()
    
    var geo: GeometryProxy
    
    @State var faviconSize = CGFloat(20)
    var body: some View {
        VStack {
#if !os(macOS)
            ZStack {
                WebViewMobile(urlString: url, title: $webTitle)
                    .frame(width: geo.size.width - 50, height: 400)
                    .scaleEffect(0.5)
                    .disabled(true)
                
                Color.white.opacity(0.0001)
                
            }.frame(width: geo.size.width / 2 - 25, height: 200)
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
                        // Success
                        // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                    }
                    .indicator(.activity) // Activity Indicator
                    .transition(.fade(duration: 0.5)) // Fade Transition with duration
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
        }
    }
}
