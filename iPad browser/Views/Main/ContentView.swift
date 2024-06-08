//
//  TestingView.swift
//  iPad browser
//
//  Created by Caedmon Myers on 8/9/23.
//

import SwiftUI
import UIKit
import WebKit
import Combine
import FaviconFinder
import SDWebImage
import SDWebImageSwiftUI
import SwiftData




let defaults = UserDefaults.standard


struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    
    @StateObject var variables = ObservableVariables()
    @StateObject var settings = SettingsVariables()
    
    //@Environment(\.colorScheme) var colorScheme
    //@AppStorage("prefferedColorScheme") var prefferedColorScheme = "automatic"
    
    // WebView Handling
//    @ObservedObject var navigationState = NavigationState()
//    @ObservedObject var pinnedNavigationState = NavigationState()
//    @ObservedObject var favoritesNavigationState = NavigationState()
    
//    @State var navigationStateArray = [] as [NavigationState]
//    @State var pinnedNavigationStateArray = [] as [NavigationState]
//    @State var favoritesNavigationStateArray = [] as [NavigationState]
    
    // Storage and Website Loading
    @AppStorage("currentSpace") var currentSpace = "Untitled"
    //@State private var spaces = ["Home", "Space 2"]
    @State private var spaceIcons: [String: String]? = [:]
    
    @State private var reloadTitles = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let rotationTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    // Settings and Sheets
    @State private var hoverTab = WKWebView()
    
    @State private var showSettings = false
    @State private var changeColorSheet = false
    
    @State private var startColor: Color = Color.purple
    @State private var endColor: Color = Color.pink
    @State private var textColor: Color = Color.white
    
    @AppStorage("startColorHex") var startHex = "8A3CEF"
    @AppStorage("endColorHex") var endHex = "84F5FE"
    @AppStorage("textColorHex") var textHex = "ffffff"
    
    //@AppStorage("swipingSpaces") var swipingSpaces = true
    
    @State private var presentIcons = false
    
    // Hover Effects
    @State private var hoverTinySpace = false
    
    @State private var hoverSidebarButton = false
    @State private var hoverPaintbrush = false
    @State private var hoverReloadButton = false
    @State private var hoverForwardButton = false
    @State private var hoverBackwardButton = false
    @State private var hoverNewTab = false
    @State private var settingsButtonHover = false
    @State private var hoverNewTabSection = false
    
    @State private var hoverSpaceIndex = 1000
    @State private var hoverSpace = ""
    
    @State private var hoverSidebarSearchField = false
    
    @State private var hoverCloseTab = WKWebView()
    
    @State private var spaceIconHover = false
    
    // Animations and Gestures
    @State private var reloadRotation = 0
    @State private var draggedTab: WKWebView?
    
    // Selection States
    @State private var tabBarShown = false
    @State private var commandBarShown = false
    
    @State private var changingIcon = ""
    //@State private var hideSidebar = false
    @AppStorage("hideSidebar") var hideSidebar = false
    
    @State private var searchInSidebar = ""
    @State private var newTabSearch = ""
    @State private var newTabSaveSearch = ""
    
    @State private var currentTabNum = 0
    
    @State private var selectedIndex: Int? = 0
    
    @FocusState private var focusedField: FocusedField?
    
    @AppStorage("selectedSpaceIndex") var selectedSpaceIndex = 0
    //@State var selectedSpaceIndex = 0
    
    @State var loadingAnimationToggle = false
    @State var offset = 0.0
    @State var loadingRotation = 0
    
    
    //@AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = true
    //@AppStorage("favoritesStyle") var favoritesStyle = false
    //@AppStorage("faviconLoadingStyle") var faviconLoadingStyle = false
    
    //@AppStorage("sidebarLeft") var sidebarLeft = true
    
    //@AppStorage("showBorder") var showBorder = true
    
    @State private var inspectCode = ""
    
    enum FocusedField {
        case commandBar, tabBar, none
    }
    @State private var selectedTabLocation = "tabs"
    
    // Other Stuff
    @State private var screenWidth = UIScreen.main.bounds.width
    
    @State private var hoveringSidebar = false
    @State private var tapSidebarShown = false
    
    @State var commandBarCollapseHeightAnimation = false
    @State var commandBarSearchSubmitted = false
    @State var commandBarSearchSubmitted2 = false
    
    @State var auraTab = ""
    
    @State var initialLoadDone = false
    
    @State var scrollLimiter = false
    
    @State private var scrollPosition: CGPoint = .zero
    @State private var horizontalScrollPosition: CGPoint = .zero
    
    @State private var navigationOffset: CGFloat = 0
    @State var navigationArrowColor = false
    @State var arrowImpactOnce = false
    var body: some View {
        GeometryReader { geo in
            if spaces.count > 0 {
                ZStack {
                    ZStack {
                        if selectedSpaceIndex < spaces.count && (!spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty) {
                            //if !spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty {
                                LinearGradient(colors: [Color(hex: spaces[selectedSpaceIndex].startHex), Color(hex: spaces[selectedSpaceIndex].endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                            //}
                        }
                        else {
                            LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                        }
                        
                        if variables.prefferedColorScheme == "dark" || (variables.prefferedColorScheme == "automatic" && colorScheme == .dark) {
                            Color.black.opacity(0.5)
                        }
                        
                        HStack(spacing: 0) {
                            if settings.sidebarLeft {
                                if settings.showBorder {
                                    ThreeDots(hoverTinySpace: $hoverTinySpace, hideSidebar: $hideSidebar)
                                        .disabled(true)
                                }
                                
                                //if swipingSpaces {
                                PagedSidebar(selectedTabLocation: $selectedTabLocation, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, showSettings: $showSettings, geo: geo)
                                    .environmentObject(variables)
                                //}
                                /*else {
                                    Sidebar(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, showSettings: $showSettings, geo: geo)
                                    
                                        .animation(.easeOut).frame(width: hideSidebar ? 0: 300).offset(x: hideSidebar ? -320: 0).padding(.trailing, hideSidebar ? 0: 10)
                                        .padding(showBorder ? 0: 15)
                                        .padding(.top, showBorder ? 0: 10)
                                }*/
                            }
                            GeometryReader { webGeo in
                                ZStack {
                                    Color.white
                                        .opacity(0.4)
                                        .cornerRadius(10)
                                    
                                    
                                    //MARK: - WebView
                                    if selectedTabLocation == "favoriteTabs" {
                                        WebView(navigationState: variables.favoritesNavigationState)
                                            .cornerRadius(10)
                                        
                                        loadingIndicators(for: variables.favoritesNavigationState.selectedWebView?.isLoading)
                                    }
                                    if selectedTabLocation == "tabs" {
                                        WebView(navigationState: variables.navigationState)
                                            .cornerRadius(10)
                                        
                                        
                                        loadingIndicators(for: variables.navigationState.selectedWebView?.isLoading)
                                    }
                                    if selectedTabLocation == "pinnedTabs" {
                                        WebView(navigationState: variables.pinnedNavigationState)
                                            .cornerRadius(10)
                                        
                                        loadingIndicators(for: variables.pinnedNavigationState.selectedWebView?.isLoading)
                                    }
                                    
                                    if (selectedTabLocation == "favoriteTabs" && variables.favoritesNavigationState.selectedWebView != nil) ||
                                               (selectedTabLocation == "pinnedTabs" && variables.pinnedNavigationState.selectedWebView != nil) ||
                                               (selectedTabLocation == "tabs" && variables.navigationState.selectedWebView != nil) {
                                                HStack(alignment: .center, spacing: 0) {
                                                    navigationButton(imageName: "arrow.left", action: goBack)
                                                        .padding(.trailing, 30)
                                                    
                                                    Spacer()
                                                        .frame(width: webGeo.size.width)
                                                    
                                                    navigationButton(imageName: "arrow.right", action: goForward)
                                                        .padding(.leading, 30)
                                                    
                                                }
                                                .frame(width: webGeo.size.width)
                                                .offset(x: navigationOffset)
                                            }
                                    
                                    if auraTab == "dashboard" && selectedTabLocation == "" {
                                        Dashboard(startHexSpace: spaces[selectedSpaceIndex].startHex, endHexSpace: spaces[selectedSpaceIndex].endHex)
                                            .cornerRadius(10)
                                            .clipped()
                                    }
                                    
                                    Spacer()
                                        .frame(width: 20)
                                    
                                    HStack {
                                        Button {
                                            Task {
                                                await hideSidebar.toggle()
                                            }
                                            
                                            withAnimation {
                                                if !hideSidebar {
                                                    if selectedTabLocation == "tabs" {
                                                        Task {
                                                            await variables.navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                                        }
                                                    }
                                                    else if selectedTabLocation == "pinnedTabs" {
                                                        Task {
                                                            await variables.pinnedNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                                        }
                                                    }
                                                    else if selectedTabLocation == "favoriteTabs" {
                                                        Task {
                                                            await variables.favoritesNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                                        }
                                                    }
                                                } else {
                                                    if selectedTabLocation == "tabs" {
                                                        Task {
                                                            await variables.navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-340, height: geo.size.height))
                                                        }
                                                    }
                                                    else if selectedTabLocation == "pinnedTabs" {
                                                        Task {
                                                            await variables.pinnedNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-340, height: geo.size.height))
                                                        }
                                                    }
                                                    else if selectedTabLocation == "favoriteTabs" {
                                                        Task {
                                                            await variables.favoritesNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-340, height: geo.size.height))
                                                        }
                                                    }
                                                }
                                            }
                                        } label: {
                                            
                                        }.keyboardShortcut("s", modifiers: .command)
                                        
                                        Button {
                                            if selectedTabLocation == "tabs" {
                                                variables.navigationState.selectedWebView?.goBack()
                                            }
                                            else if selectedTabLocation == "pinnedTabs" {
                                                variables.pinnedNavigationState.selectedWebView?.goBack()
                                            }
                                            else if selectedTabLocation == "favoriteTabs" {
                                                variables.favoritesNavigationState.selectedWebView?.goBack()
                                            }
                                        } label: {
                                            
                                        }.keyboardShortcut("[", modifiers: .command)
                                        
                                        Button {
                                            if selectedTabLocation == "tabs" {
                                                variables.navigationState.selectedWebView?.goForward()
                                            }
                                            else if selectedTabLocation == "pinnedTabs" {
                                                variables.pinnedNavigationState.selectedWebView?.goForward()
                                            }
                                            else if selectedTabLocation == "favoriteTabs" {
                                                variables.favoritesNavigationState.selectedWebView?.goForward()
                                            }
                                        } label: {
                                            
                                        }.keyboardShortcut("]", modifiers: .command)
                                        
                                        Button {
                                            reloadRotation += 360
                                            
                                            if selectedTabLocation == "tabs" {
                                                variables.navigationState.selectedWebView?.reload()
                                                variables.navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                                
                                                variables.navigationState.selectedWebView = variables.navigationState.selectedWebView
                                                //navigationState.currentURL = navigationState.currentURL
                                                
                                                if let unwrappedURL = variables.navigationState.currentURL {
                                                    searchInSidebar = unwrappedURL.absoluteString
                                                }
                                            }
                                            else if selectedTabLocation == "pinnedTabs" {
                                                variables.pinnedNavigationState.selectedWebView?.reload()
                                                variables.pinnedNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                                
                                                variables.pinnedNavigationState.selectedWebView = variables.pinnedNavigationState.selectedWebView
                                                
                                                if let unwrappedURL = variables.pinnedNavigationState.currentURL {
                                                    searchInSidebar = unwrappedURL.absoluteString
                                                }
                                            }
                                            else if selectedTabLocation == "favoriteTabs" {
                                                variables.favoritesNavigationState.selectedWebView?.reload()
                                                variables.favoritesNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                                
                                                variables.favoritesNavigationState.selectedWebView = variables.favoritesNavigationState.selectedWebView
                                                
                                                if let unwrappedURL = variables.favoritesNavigationState.currentURL {
                                                    searchInSidebar = unwrappedURL.absoluteString
                                                }
                                            }
                                        } label: {
                                            
                                        }.keyboardShortcut("r", modifiers: .command)
                                        
                                        
                                        Button {
                                            if (variables.navigationState.selectedWebView == nil) && (variables.pinnedNavigationState.selectedWebView == nil) && (variables.favoritesNavigationState.selectedWebView == nil) {
                                                tabBarShown = true
                                                commandBarShown = false
                                                print("Showing Tab Bar")
                                            }
                                            else {
                                                if selectedTabLocation == "pinnedTabs" {
                                                    searchInSidebar = unformatURL(url: variables.pinnedNavigationState.selectedWebView?.url?.absoluteString ?? searchInSidebar)
                                                }
                                                else if selectedTabLocation == "favoriteTabs" {
                                                    searchInSidebar = unformatURL(url: variables.favoritesNavigationState.selectedWebView?.url?.absoluteString ?? searchInSidebar)
                                                }else {
                                                    searchInSidebar = unformatURL(url: variables.navigationState.selectedWebView?.url?.absoluteString ?? searchInSidebar)
                                                }
                                                commandBarShown.toggle()
                                                tabBarShown = false
                                                print("Showing Command Bar")
                                            }
                                        } label: {
                                            
                                        }.keyboardShortcut("l", modifiers: .command)
                                        
                                        
                                        Button {
                                            if selectedTabLocation == "favoriteTabs" {
                                                if let index = variables.favoritesNavigationState.webViews.firstIndex(of: variables.favoritesNavigationState.selectedWebView ?? WKWebView()) {
                                                    favoriteRemoveTab(at: index)
                                                }
                                            }
                                            else if selectedTabLocation == "pinnedTabs" {
                                                if let index = variables.pinnedNavigationState.webViews.firstIndex(of: variables.pinnedNavigationState.selectedWebView ?? WKWebView()) {
                                                    pinnedRemoveTab(at: index)
                                                }
                                            }
                                            else if selectedTabLocation == "tabs" {
                                                if let index = variables.navigationState.webViews.firstIndex(of: variables.navigationState.selectedWebView ?? WKWebView()) {
                                                    removeTab(at: index)
                                                }
                                            }
                                        } label: {
                                            
                                        }.keyboardShortcut("w", modifiers: .command)
                                        
                                        
                                        Button {
                                            tabBarShown.toggle()
                                            commandBarShown = false
                                        } label: {
                                            
                                        }.keyboardShortcut("t", modifiers: .command)


                                    }
                                    /*
                                    TrackpadScrollView(
                                        onScroll: { offset in
                                            let newOffset = -offset
                                            if abs(newOffset) <= 150 {
                                                navigationOffset = newOffset
                                            } else {
                                                navigationOffset = newOffset > 0 ? 150 : -150
                                            }
                                            if abs(newOffset) > 100 {
                                                withAnimation(.linear(duration: 0.3)) {
                                                    navigationArrowColor = true
                                                }
                                            } else {
                                                withAnimation(.linear(duration: 0.3)) {
                                                    navigationArrowColor = false
                                                }
                                            }
                                        },
                                        onScrollEnd: {
                                            if navigationOffset >= 100 {
                                                goBack()
                                            } else if navigationOffset < -100 {
                                                goForward()
                                            }
                                            
                                            withAnimation(.linear(duration: 0.25)) {
                                                navigationOffset = 0
                                                navigationArrowColor = false
                                            }
                                        }
                                    )
                                    .frame(width: webGeo.size.width, height: webGeo.size.height)*/
                                }
                                .highPriorityGesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let startLocation = value.startLocation.x
                                            let width = webGeo.size.width
                                            
                                            if startLocation < 100 || startLocation > (width - 100) {
                                                let newOffset = value.translation.width
                                                if abs(newOffset) <= 150 {
                                                    navigationOffset = newOffset
                                                } else {
                                                    navigationOffset = newOffset > 0 ? 150 : -150
                                                }
                                                if abs(newOffset) > 100 {
                                                    if !arrowImpactOnce {
                                                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                                        arrowImpactOnce = true
                                                    }
                                                    
                                                    withAnimation(.linear(duration: 0.3)) {
                                                        navigationArrowColor = true
                                                    }
                                                } else {
                                                    if arrowImpactOnce {
                                                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                                        arrowImpactOnce = false
                                                    }
                                                    withAnimation(.linear(duration: 0.3)) {
                                                        navigationArrowColor = false
                                                    }
                                                }
                                            }
                                        }
                                        .onEnded { value in
                                            arrowImpactOnce = false
                                            let startLocation = value.startLocation.x
                                            let width = webGeo.size.width
                                            
                                            if startLocation < 150 || startLocation > (width - 150) {
                                                if navigationOffset >= 100 {
                                                    goBack()
                                                } else if navigationOffset < -100 {
                                                    goForward()
                                                }
                                                
                                                withAnimation(.linear(duration: 0.25)) {
                                                    navigationOffset = 0
                                                    navigationArrowColor = false
                                                }
                                            }
                                        }
                                )
                                //.animation(.default)
                            }
                            .cornerRadius(10)
                            .clipped()
                            .padding(settings.sidebarLeft ? .trailing: .leading, settings.showBorder ? 12: 0)
                            
                            if !settings.sidebarLeft {
                                if settings.showBorder {
                                    ThreeDots(hoverTinySpace: $hoverTinySpace, hideSidebar: $hideSidebar)
                                        .disabled(true)
                                }
                                
                                
//                                Sidebar(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, showSettings: $showSettings, geo: geo)
//                                
//                                    .animation(.easeOut).frame(width: hideSidebar ? 0: 300).offset(x: hideSidebar ? 320: 0).padding(.leading, hideSidebar ? 0: 10)
//                                    .padding(showBorder ? 0: 15)
//                                    .padding(.top, showBorder ? 0: 10)
                                PagedSidebar(selectedTabLocation: $selectedTabLocation, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, showSettings: $showSettings, geo: geo)
                                    .environmentObject(variables)
                            }
                        }
                        .padding(.trailing, settings.showBorder ? 10: 0)
                        .padding(.vertical, settings.showBorder ? 25: 0)
                        .onAppear {
                            if let savedStartColor = getColor(forKey: "startColorHex") {
                                startColor = savedStartColor
                            }
                            if let savedEndColor = getColor(forKey: "endColorHex") {
                                endColor = savedEndColor
                            }
                            if let savedTextColor = getColor(forKey: "textColorHex") {
                                textColor = savedTextColor
                            }
                            
                            spaceIcons = UserDefaults.standard.dictionary(forKey: "spaceIcons") as? [String: String]
                        }
                        
                        if hideSidebar {
                            HStack {
                                if !settings.sidebarLeft {
                                    Spacer()
                                }
                                
                                ZStack {
                                    Color.white.opacity(0.00001)
                                        .frame(width: 35)
                                        .onTapGesture {
                                            tapSidebarShown = true
                                            
                                        }
                                    
                                    HStack {
//                                        PagedSidebar(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, showSettings: $showSettings, geo: geo)
                                        VStack {
                                            ToolbarButtonsView(selectedTabLocation: $selectedTabLocation, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, geo: geo).frame(height: 40)
                                                .padding([.top, .horizontal], 5)
                                            
                                            Sidebar(selectedTabLocation: $selectedTabLocation, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, showSettings: $showSettings, geo: geo)
                                                .environmentObject(variables)
                                            
                                            HStack {
                                                Button {
                                                    showSettings.toggle()
                                                } label: {
                                                    ZStack {
                                                        Color(.white)
                                                            .opacity(settingsButtonHover ? 0.5: 0.0)
                                                        
                                                        Image(systemName: "gearshape")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 20, height: 20)
                                                            .foregroundStyle(textColor)
                                                            .opacity(settingsButtonHover ? 1.0: 0.5)
                                                        
                                                    }.frame(width: 40, height: 40).cornerRadius(7)
                                                        .hoverEffect(.lift)
                                                        .hoverEffectDisabled(!settings.hoverEffectsAbsorbCursor)
                                                        .onHover(perform: { hovering in
                                                            if hovering {
                                                                settingsButtonHover = true
                                                            }
                                                            else {
                                                                settingsButtonHover = false
                                                            }
                                                        })
                                                }
                                                .sheet(isPresented: $showSettings) {
                                                    Settings(presentSheet: $showSettings, startHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].startHex: startHex, endHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].endHex: endHex)
                                                }
                                                Spacer()
                                                
                                                SpacePicker(navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, currentSpace: $currentSpace, selectedSpaceIndex: $selectedSpaceIndex)
                                                
                                                Button(action: {
                                                    modelContext.insert(SpaceStorage(spaceIndex: spaces.count, spaceName: "Untitled \(spaces.count)", spaceIcon: "scribble.variable", favoritesUrls: [], pinnedUrls: [], tabUrls: []))
                                                }, label: {
                                                    ZStack {
                                                        Color(.white)
                                                            .opacity(hoverSpace == "veryLongTextForHoveringOnPlusSignSoIDontHaveToUseAnotherVariable" ? 0.5: 0.0)
                                                        
                                                        Image(systemName: "plus")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 20, height: 20)
                                                            .foregroundStyle(textColor)
                                                            .opacity(hoverSpace == "veryLongTextForHoveringOnPlusSignSoIDontHaveToUseAnotherVariable" ? 1.0: 0.5)
                                                        
                                                    }.frame(width: 40, height: 40).cornerRadius(7)
                                                        .hoverEffect(.lift)
                                                        .hoverEffectDisabled(!settings.hoverEffectsAbsorbCursor)
                                                        .onHover(perform: { hovering in
                                                            if hovering {
                                                                hoverSpace = "veryLongTextForHoveringOnPlusSignSoIDontHaveToUseAnotherVariable"
                                                            }
                                                            else {
                                                                hoverSpace = ""
                                                            }
                                                        })
                                                })
                                            }
                                        }
                                            .padding(15)
                                            .frame(width: 300)
                                            .background(content: {
                                                if settings.sidebarLeft {
                                                    LinearGradient(colors: [startColor, Color(hex: averageHexColor(hex1: startHex, hex2: endHex))], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                        .opacity(1.0)
                                                    if selectedSpaceIndex < spaces.count {
                                                        if !spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty {
                                                            LinearGradient(colors: [Color(hex: spaces[selectedSpaceIndex].startHex), Color(hex: averageHexColor(hex1: spaces[selectedSpaceIndex].startHex, hex2: spaces[selectedSpaceIndex].endHex))], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                        }
                                                    }
                                                } else {
                                                    LinearGradient(colors: [Color(hex: averageHexColor(hex1: startHex, hex2: endHex)), endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                        .opacity(1.0)
                                                    if selectedSpaceIndex < spaces.count {
                                                        if !spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty {
                                                            LinearGradient(colors: [Color(hex: averageHexColor(hex1: spaces[selectedSpaceIndex].startHex, hex2: spaces[selectedSpaceIndex].endHex)), Color(hex: spaces[selectedSpaceIndex].endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                        }
                                                    }
                                                }
                                                if variables.prefferedColorScheme == "dark" || (variables.prefferedColorScheme == "automatic" && colorScheme == .dark) {
                                                    Color.black.opacity(0.5)
                                                }
                                            })
                                            .cornerRadius(10)
                                            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 0)
                                        
                                        Spacer()
                                    }.padding(40)
                                        .padding(.leading, 30)
                                        .frame(width: hoveringSidebar || tapSidebarShown ? 350: 0)
                                        .offset(x: hoveringSidebar || tapSidebarShown ? 0: settings.sidebarLeft ? -350: 300)
                                        .clipped()
                                    
                                }.onHover(perform: { hovering in
                                    if hovering {
                                        hoveringSidebar = true
                                    }
                                    else {
                                        hoveringSidebar = false
                                    }
                                })
                                
                                if settings.sidebarLeft {
                                    Spacer()
                                }
                            }.animation(.default)
                        }
                    }.onTapGesture {
                        if tabBarShown || commandBarShown {
                            tabBarShown = false
                            commandBarShown = false
                        }
                        tapSidebarShown = false
                    }
                    
                    //MARK: - Tabbar
                    if tabBarShown {
                        CommandBar(commandBarText: $newTabSearch, searchSubmitted: $commandBarSearchSubmitted, collapseHeightAnimation: $commandBarCollapseHeightAnimation)
                            .onChange(of: commandBarSearchSubmitted) { thing in
                                
                                if !newTabSearch.starts(with: "aura://") {
                                    auraTab = ""
                                    variables.navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: formatURL(from: newTabSearch))!))
                                }
                                else {
                                    if newTabSearch.contains("dashboard") {
                                        variables.navigationState.selectedWebView = nil
                                        variables.pinnedNavigationState.selectedWebView = nil
                                        variables.favoritesNavigationState.selectedWebView = nil
                                        
                                        auraTab = "dashboard"
                                        selectedTabLocation = ""
                                    }
                                    if newTabSearch.contains("settings") {
                                        showSettings = true
                                    }
                                }
                                
                                tabBarShown = false
                                commandBarSearchSubmitted = false
                                newTabSearch = ""
                                
                                print("Saving Tabs")
                                
                                saveSpaceData()
                            }
                    }
                    
                    //MARK: - Command Bar
                    else if commandBarShown {
                        CommandBar(commandBarText: $searchInSidebar, searchSubmitted: $commandBarSearchSubmitted2, collapseHeightAnimation: $commandBarCollapseHeightAnimation)
                            .onChange(of: variables.navigationState.currentURL, {
                                if let unwrappedURL = variables.navigationState.currentURL {
                                    searchInSidebar = unwrappedURL.absoluteString
                                }
                                print("Changing searchInSidebar - 1")
                            })
                            .onChange(of: variables.pinnedNavigationState.currentURL, {
                                if let unwrappedURL = variables.pinnedNavigationState.currentURL {
                                    searchInSidebar = unwrappedURL.absoluteString
                                }
                                print("Changing searchInSidebar - 2")
                            })
                            .onChange(of: variables.favoritesNavigationState.currentURL, {
                                if let unwrappedURL = variables.favoritesNavigationState.currentURL {
                                    searchInSidebar = unwrappedURL.absoluteString
                                }
                                print("Changing searchInSidebar - 3")
                            })
                            .onChange(of: commandBarSearchSubmitted2) { thing in
                                
                                    //variables.navigationState.currentURL = URL(string: formatURL(from: newTabSearch))!
                                    //variables.navigationState.selectedWebView?.load(URLRequest(url: URL(formatURL(from: newTabSearch))!))
                                Task {
                                    await searchInSidebar = formatURL(from: searchInSidebar)
                                    if let url = URL(string: searchInSidebar) {
                                        // Create a URLRequest object
                                        let request = URLRequest(url: url)
                                        
                                        if selectedTabLocation == "tabs" {
                                            await variables.navigationState.selectedWebView?.load(request)
                                        }
                                        if selectedTabLocation == "pinnedTabs" {
                                            await variables.pinnedNavigationState.selectedWebView?.load(request)
                                        }
                                        if selectedTabLocation == "favoriteTabs" {
                                            await variables.favoritesNavigationState.selectedWebView?.load(request)
                                        }
                                        
                                        print("Updated URL String")
                                    } else {
                                        print("Invalid URL string")
                                    }
                                    
                                    saveSpaceData()
                                }
                                
                                
                                commandBarShown = false
                                tabBarShown = false
                                commandBarSearchSubmitted2 = false
                                newTabSearch = ""
                            }
                    }
                }
                .onChange(of: selectedSpaceIndex, {
                    if initialLoadDone {
                        variables.navigationState.webViews.removeAll()
                        
                        var reloadAuraTabs = auraTab
                        auraTab = ""
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.00001) {
                            auraTab = reloadAuraTabs
                        }
                        
                        if selectedSpaceIndex < spaces.count {
                            if !spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty {
                                startHex = spaces[selectedSpaceIndex].startHex
                                endHex = spaces[selectedSpaceIndex].startHex
                                
                                startColor = Color(hex: spaces[selectedSpaceIndex].startHex)
                                endColor = Color(hex: spaces[selectedSpaceIndex].endHex)
                            }
                        }
                        
                        UserDefaults.standard.setValue(selectedSpaceIndex, forKey: "savedSelectedSpaceIndex")
                    }
                })
                .onChange(of: variables.navigationState.webViews, {
                    saveSpaceData()
                    print("Saving navigationState")
                })
                .onChange(of: variables.pinnedNavigationState.webViews, {
                    saveSpaceData()
                    print("Saving pinnedNavigationState")
                })
                .onChange(of: variables.favoritesNavigationState.webViews, {
                    saveSpaceData()
                    print("Saving favoritesNavigationState")
                })
                .onAppear() {
                    if UserDefaults.standard.integer(forKey: "savedSelectedSpaceIndex") > spaces.count - 1 {
                        selectedSpaceIndex = 0
                    }
                    else {
                        selectedSpaceIndex = UserDefaults.standard.integer(forKey: "savedSelectedSpaceIndex")
                    }
                    
                    if selectedSpaceIndex < spaces.count {
                        if !spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty {
                            startHex = spaces[selectedSpaceIndex].startHex
                            endHex = spaces[selectedSpaceIndex].startHex
                            
                            startColor = Color(hex: spaces[selectedSpaceIndex].startHex)
                            endColor = Color(hex: spaces[selectedSpaceIndex].endHex)
                        }
                    }
                    
                    for space in spaces {
                        if space.spaceName == currentSpace {
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
                    
                    initialLoadDone = true
                }
                
                
                .ignoresSafeArea()
            }
        }.task {
            if spaces.count <= 0 {
                await modelContext.insert(SpaceStorage(spaceIndex: spaces.count, spaceName: "Untitled", spaceIcon: "circle.fill", favoritesUrls: [], pinnedUrls: [], tabUrls: []))
                
//                do {
//                    try await modelContext.save()
//                }
//                catch {
//                    print(error.localizedDescription)
//                }
            }
        }
    }
    
    func saveSpaceData() {
        let savingTodayTabs = variables.navigationState.webViews.compactMap { $0.url?.absoluteString }
        let savingPinnedTabs = variables.pinnedNavigationState.webViews.compactMap { $0.url?.absoluteString }
        let savingFavoriteTabs = variables.favoritesNavigationState.webViews.compactMap { $0.url?.absoluteString }
        
        if !spaces.isEmpty {
            print("Saving Today Tabs: \(savingTodayTabs)")
            spaces[selectedSpaceIndex].tabUrls = savingTodayTabs
            print(spaces[selectedSpaceIndex].tabUrls)
            spaces[selectedSpaceIndex].pinnedUrls = savingPinnedTabs
            spaces[selectedSpaceIndex].favoritesUrls = savingFavoriteTabs
        }
        else {
            modelContext.insert(SpaceStorage(spaceIndex: 0, spaceName: "Untitled", spaceIcon: "circle.fill", favoritesUrls: [], pinnedUrls: [], tabUrls: savingTodayTabs))
        }
        
        Task {
            do {
                try await modelContext.save()
                print("modelContext Saved")
            } catch {
                print(error.localizedDescription)
            }
        }
        
        print(spaces[selectedSpaceIndex].tabUrls)
        
    }
    
    /*func saveToLocalStorage() {
        let urlStringArray = navigationState.webViews.compactMap { $0.url?.absoluteString }
        if let urlsData = try? JSONEncoder().encode(urlStringArray){
            UserDefaults.standard.set(urlsData, forKey: "\(currentSpace)userTabs")
            
        }
        
        let urlStringArray2 = pinnedNavigationState.webViews.compactMap { $0.url?.absoluteString }
        if let urlsData = try? JSONEncoder().encode(urlStringArray2){
            UserDefaults.standard.set(urlsData, forKey: "\(currentSpace)pinnedTabs")
            
        }
        
        let urlStringArray3 = favoritesNavigationState.webViews.compactMap { $0.url?.absoluteString }
        if let urlsData = try? JSONEncoder().encode(urlStringArray3){
            UserDefaults.standard.set(urlsData, forKey: "\(currentSpace)favoriteTabs")
            
        }
    }*/
    
    private func loadingIndicators(for isLoading: Bool?) -> some View {
        Group {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .trim(from: 0.25 + offset, to: 0.5 + offset)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundColor(Color(hex: spaces[selectedSpaceIndex].startHex))
                .opacity(isLoading ?? false ? 1.0 : 0.0)
                .animation(.default, value: isLoading ?? false)
                .blur(radius: 5)
            
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .trim(from: 0.25 + offset, to: 0.5 + offset)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotation(Angle(degrees: 180))
                .foregroundColor(Color(hex: spaces[selectedSpaceIndex].startHex))
                .opacity(isLoading ?? false ? 1.0 : 0.0)
                .animation(.default, value: isLoading ?? false)
                .blur(radius: 5)
                .onReceive(rotationTimer) { _ in
                    handleRotation()
                }
        }
    }
    
    private func navigationButton(imageName: String, action: @escaping () -> Void) -> some View {
        ZStack {
            Circle()
                .fill(navigationArrowColor ? Color(.systemBlue) : Color.gray)
                .shadow(color: Color(.systemBlue), radius: navigationArrowColor ? 10 : 0, x: 0, y: 0)
            
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .padding(12)
                .scaleEffect(navigationArrowColor ? 1.0 : 0.7)
                .foregroundStyle(Color.white)
            
        }.frame(width: 50, height: 50)
        .gesture(TapGesture().onEnded(action))
    }

    private func handleDragChange(_ value: DragGesture.Value) {
        let newOffset = value.translation.width
        if abs(newOffset) <= 150 {
            navigationOffset = newOffset
        } else {
            navigationOffset = newOffset > 0 ? 150 : -150
        }
        if abs(newOffset) > 100 {
            withAnimation(.linear(duration: 0.3)) {
                navigationArrowColor = true
            }
        } else {
            withAnimation(.linear(duration: 0.3)) {
                navigationArrowColor = false
            }
        }
    }

    private func handleDragEnd() {
        if navigationOffset >= 100 {
            goBack()
        } else if navigationOffset < -100 {
            goForward()
        }
        
        withAnimation(.linear(duration: 0.25)) {
            navigationOffset = 0
            navigationArrowColor = false
        }
    }

    private func handleRotation() {
        if offset == 0.5 {
            offset = 0.0
            withAnimation(.linear(duration: 1.5)) {
                offset = 0.5
            }
        } else {
            withAnimation(.linear(duration: 1.5)) {
                offset = 0.5
            }
        }
    }

    private func goBack() {
        if selectedTabLocation == "tabs" {
            variables.navigationState.selectedWebView?.goBack()
        } else if selectedTabLocation == "pinnedTabs" {
            variables.pinnedNavigationState.selectedWebView?.goBack()
        } else if selectedTabLocation == "favoriteTabs" {
            variables.favoritesNavigationState.selectedWebView?.goBack()
        }
    }

    private func goForward() {
        if selectedTabLocation == "tabs" {
            variables.navigationState.selectedWebView?.goForward()
        } else if selectedTabLocation == "pinnedTabs" {
            variables.pinnedNavigationState.selectedWebView?.goForward()
        } else if selectedTabLocation == "favoriteTabs" {
            variables.favoritesNavigationState.selectedWebView?.goForward()
        }
    }
    
    func favoriteRemoveTab(at index: Int) {
        // If the deleted tab is the currently selected one
        if variables.favoritesNavigationState.selectedWebView == variables.favoritesNavigationState.webViews[index] {
            if variables.favoritesNavigationState.webViews.count > 1 { // Check if there's more than one tab
                if index == 0 { // If the first tab is being deleted, select the next one
                    variables.favoritesNavigationState.selectedWebView = variables.favoritesNavigationState.webViews[1]
                } else { // Otherwise, select the previous one
                    variables.favoritesNavigationState.selectedWebView = variables.favoritesNavigationState.webViews[index - 1]
                }
            } else { // If it's the only tab, set the selectedWebView to nil
                variables.favoritesNavigationState.selectedWebView = nil
            }
        }
        
        variables.favoritesNavigationState.webViews.remove(at: index)
        
        saveSpaceData()
    }
    
    func pinnedRemoveTab(at index: Int) {
        // If the deleted tab is the currently selected one
        if variables.pinnedNavigationState.selectedWebView == variables.pinnedNavigationState.webViews[index] {
            if variables.pinnedNavigationState.webViews.count > 1 { // Check if there's more than one tab
                if index == 0 { // If the first tab is being deleted, select the next one
                    variables.pinnedNavigationState.selectedWebView = variables.pinnedNavigationState.webViews[1]
                } else { // Otherwise, select the previous one
                    variables.pinnedNavigationState.selectedWebView = variables.pinnedNavigationState.webViews[index - 1]
                }
            } else { // If it's the only tab, set the selectedWebView to nil
                variables.pinnedNavigationState.selectedWebView = nil
            }
        }
        
        variables.pinnedNavigationState.webViews.remove(at: index)
        
        saveSpaceData()
    }
    
    func removeTab(at index: Int) {
        // If the deleted tab is the currently selected one
        if variables.navigationState.selectedWebView == variables.navigationState.webViews[index] {
            if variables.navigationState.webViews.count > 1 { // Check if there's more than one tab
                if index == 0 { // If the first tab is being deleted, select the next one
                    variables.navigationState.selectedWebView = variables.navigationState.webViews[1]
                } else { // Otherwise, select the previous one
                    variables.navigationState.selectedWebView = variables.navigationState.webViews[index - 1]
                }
            } else { // If it's the only tab, set the selectedWebView to nil
                variables.navigationState.selectedWebView = nil
            }
        }
        
        variables.navigationState.webViews.remove(at: index)
        
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
        saveSpaceData()
    }
}
