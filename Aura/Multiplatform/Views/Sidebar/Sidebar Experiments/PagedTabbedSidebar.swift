//
//  PagedSidebar.swift
//  Aura
//
//  Created by Reyna Myers on 24/5/24.
//

import SwiftUI
import SwiftData
import WebKit
/*
struct PagedTabbedSidebar: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    
    @Binding var selectedTabLocation: String
    
    @EnvironmentObject var variables: ObservableVariables
    
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
        TabView(selection: $selectedSpaceIndex,
                content:  {
            ForEach(0..<spaces.count, id:\.self) { space in
                //Sidebar(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, showSettings: $showSettings, geo: geo)
                Sidebar(selectedTabLocation: $selectedTabLocation, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, showSettings: $showSettings, geo: geo)
                    .tag(space.description)
                    .environmentObject(variables)
            }
        })
#if !os(macOS)
        .toolbarBackground(.clear, for: .tabBar)
        #endif
        .ignoresSafeArea()
        .padding(.trailing, hideSidebar ? 0: 10)
        .padding(showBorder ? 0: 15)
        .padding(.top, showBorder ? 0: 10)
        .frame(width: hideSidebar ? 0: 300)
        .offset(x: hideSidebar ? -320: 0)
        
    }
}*/
