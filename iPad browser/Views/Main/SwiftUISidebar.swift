//
//  SwiftUITabBar.swift
//  Aura
//
//  Created by Caedmon Myers on 23/6/24.
//

import SwiftUI
import SwiftData

struct SwiftUITabBar: View {
    @StateObject var variables = ObservableVariables()
    @State var webView = WebViewSidebarAdaptable()
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    var body: some View {
        if #available(iOS 18.0, *) {
            TabView {
                ForEach(variables.pinnedNavigationState.webViews, id: \.self) { tab in
                    //PinnedTab(reloadTitles: $reloadTitles, tab: tab, hoverTab: $hoverTab, faviconLoadingStyle: $faviconLoadingStyle, searchInSidebar: $searchInSidebar, hoverCloseTab: $hoverCloseTab, selectedTabLocation: $selectedTabLocation, draggedTab: $draggedTab, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState)
                    Tab(tab.title ?? "Error Loading Tab", image: "") {
                        webView
                            .onAppear() {
                                webView.loadURL(urlString: tab.url?.absoluteString ?? "https://arc.net")
                            }
                    }
                }
            }.tabViewStyle(.sidebarAdaptable)
                .onAppear() {
                    if UserDefaults.standard.integer(forKey: "savedSelectedSpaceIndex") > spaces.count - 1 {
                        variables.selectedSpaceIndex = 0
                    }
                    else {
                        variables.selectedSpaceIndex = UserDefaults.standard.integer(forKey: "savedSelectedSpaceIndex")
                    }
                    
                    if variables.selectedSpaceIndex < spaces.count {
                        if !spaces[variables.selectedSpaceIndex].startHex.isEmpty && !spaces[variables.selectedSpaceIndex].endHex.isEmpty {
                            variables.startHex = spaces[variables.selectedSpaceIndex].startHex
                            variables.endHex = spaces[variables.selectedSpaceIndex].startHex
                            
                            variables.startColor = Color(hex: spaces[variables.selectedSpaceIndex].startHex)
                            variables.endColor = Color(hex: spaces[variables.selectedSpaceIndex].endHex)
                        }
                    }
                    
                    for space in spaces {
                        if space.spaceName == variables.currentSpace {
                            for tab in space.tabUrls {
                                variables.navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: tab) ?? URL(string: "https://figma.com")!))
                            }
                            for tab in space.pinnedUrls {
                                variables.pinnedNavigationState.createNewWebView(withRequest: URLRequest(url: URL(string: tab) ?? URL(string: "https://thebrowser.company")!))
                            }
                            for tab in space.favoritesUrls {
                                variables.favoritesNavigationState.createNewWebView(withRequest: URLRequest(url: URL(string: tab) ?? URL(string: "https://arc.net")!))
                            }
                        }
                    }
                    variables.navigationState.selectedWebView = nil
                    variables.pinnedNavigationState.selectedWebView = nil
                    variables.favoritesNavigationState.selectedWebView = nil
                    
                    variables.navigationStateArray = Array(repeating: NavigationState(), count: spaces.count)
                    variables.pinnedNavigationStateArray = Array(repeating: NavigationState(), count: spaces.count)
                    variables.favoritesNavigationStateArray = Array(repeating: NavigationState(), count: spaces.count)

//                    for spaceIndex in 0..<spaces.count {
//                        for tab in spaces[spaceIndex].tabUrls {
//                            variables.navigationStateArray[spaceIndex].createNewWebView(withRequest: URLRequest(url: URL(string: tab) ?? URL(string: "https://figma.com")!))
//                        }
//                        for tab in spaces[spaceIndex].pinnedUrls {
//                            variables.pinnedNavigationStateArray[spaceIndex].createNewWebView(withRequest: URLRequest(url: URL(string: tab) ?? URL(string: "https://thebrowser.company")!))
//                        }
//                        for tab in spaces[spaceIndex].favoritesUrls {
//                            variables.favoritesNavigationStateArray[spaceIndex].createNewWebView(withRequest: URLRequest(url: URL(string: tab) ?? URL(string: "https://arc.net")!))
//                        }
//                        variables.navigationStateArray[spaceIndex].selectedWebView = nil
//                        variables.pinnedNavigationStateArray[spaceIndex].selectedWebView = nil
//                        variables.favoritesNavigationStateArray[spaceIndex].selectedWebView = nil
//                    }
                    
                    variables.initialLoadDone = true
                }
        }
        else {
            ContentView()
        }
    }
}

#Preview {
    SwiftUITabBar()
}
