//
//  PagedSidebar.swift
//  Aura
//
//  Created by Caedmon Myers on 24/5/24.
//

import SwiftUI
import SwiftData
import WebKit

struct PagedSidebar: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    
    @Binding var selectedTabLocation: String
    
    @ObservedObject var navigationState: NavigationState
    @ObservedObject var pinnedNavigationState: NavigationState
    @ObservedObject var favoritesNavigationState: NavigationState
    @Binding var hideSidebar: Bool
    @Binding var searchInSidebar: String
    @Binding var commandBarShown: Bool
    @Binding var tabBarShown: Bool
    @Binding var startColor: Color
    @Binding var endColor: Color
    @Binding var textColor: Color
    @Binding var hoverSpace: String
    @Binding var showSettings: Bool
    var geo: GeometryProxy
    
    @State var temporaryRenamingString = ""
    @State var isRenaming = false
    
    // Storage and Website Loading
    @AppStorage("currentSpace") var currentSpace = "Untitled"
    //@State private var spaces = ["Home", "Space 2"]
    @State private var spaceIcons: [String: String]? = [:]
    
    @State private var reloadTitles = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Settings and Sheets
    @State private var hoverTab = WKWebView()
    
    //@State private var showSettings = false
    @State private var changeColorSheet = false
    
    @State private var startHex = "ffffff"
    @State private var endHex = "000000"
    
    @State private var presentIcons = false
    
    // Hover Effects
    @State private var hoverSidebarSearchField = false
    
    @State private var hoverCloseTab = WKWebView()
    
    @State private var spaceIconHover = false
    
    @State private var settingsButtonHover = false
    @State private var hoverNewTabSection = false
    
    @State var temporaryRenameSpace = ""
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = true
    @AppStorage("favoritesStyle") var favoritesStyle = false
    @AppStorage("faviconLoadingStyle") var faviconLoadingStyle = false
    
    @AppStorage("selectedSpaceIndex") var selectedSpaceIndex = 0
    
    @State var hoverPaintbrush = false
    
    // Selection States
    @State private var changingIcon = ""
    @State private var draggedTab: WKWebView?
    
    @State var showPaintbrush = false
    
    @State var scrollLimiter = false
    
    @State private var scrollPosition: CGPoint = .zero
    @State private var horizontalScrollPosition: CGPoint = .zero
    
    @AppStorage("showBorder") var showBorder = true
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(0..<spaces.count, id:\.self) { space in
                        VStack {
                        //Sidebar(selectedTabLocation: $selectedTabLocation, navigationState: navigationStateArray.count > space ? navigationStateArray[space]: navigationState, pinnedNavigationState: pinnedNavigationStateArray.count > space ? pinnedNavigationStateArray[space]: pinnedNavigationState, favoritesNavigationState: favoritesNavigationStateArray.count > space ? favoritesNavigationStateArray[space]: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, geo: geo)
                            Sidebar(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, showSettings: $showSettings, geo: geo)
                            .id(space.description)
                            
                            //Text(space.description)
                            //Text(selectedSpaceIndex.description)
                            //Text(horizontalScrollPosition.x.description)
                        }
                            .containerRelativeFrame(.horizontal)
                        //.containerRelativeFrame(.horizontal, count: 5, span: 2, spacing: 10)
                            .animation(.easeOut)
                            .frame(width: hideSidebar ? 0: 300)
                    }
                }.scrollTargetLayout()
                    .onAppear() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            proxy.scrollTo(selectedSpaceIndex.description)
                        }
                    }
                    .onChange(of: selectedSpaceIndex, {
                        proxy.scrollTo(selectedSpaceIndex.description)
                    })
                    .background(GeometryReader { geometry in
                        Color.clear
                            .ignoresSafeArea()
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
                    })
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        self.horizontalScrollPosition.x = value.x - 20
                        
                        if ((Int((abs(horizontalScrollPosition.x)) / 10) * 10) % 300 == 0) && !scrollLimiter {
                            Task {
                                await selectedSpaceIndex = Int(abs(horizontalScrollPosition.x) / 300)
                            }
                            
                            currentSpace = String(spaces[Int(abs(horizontalScrollPosition.x) / 300)].spaceName)
                            
                            selectedSpaceIndex = Int(abs(horizontalScrollPosition.x) / 300)
                            
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
                            
                            scrollLimiter = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                scrollLimiter = false
                            }
                            
                        }
                    }
            }.ignoresSafeArea()
                .padding(.trailing, hideSidebar ? 0: 10)
                .padding(showBorder ? 0: 15)
                .padding(.top, showBorder ? 0: 10)
                .frame(width: hideSidebar ? 0: 300)
                .offset(x: hideSidebar ? -320: 0)
            //.scrollTargetBehavior(.viewAligned)
                .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                .scrollIndicators(.hidden)
        }
    }
}
