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
import HighlightSwift
import SwiftData




let defaults = UserDefaults.standard


struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query var spaces: [SpaceStorage]
    
    // WebView Handling
    @ObservedObject var navigationState = NavigationState()
    @ObservedObject var pinnedNavigationState = NavigationState()
    @ObservedObject var favoritesNavigationState = NavigationState()
    
    // Storage and Website Loading
    @AppStorage("currentSpace") var currentSpace = "Untitled"
    //@State private var spaces = ["Home", "Space 2"]
    @State private var spaceIcons: [String: String]? = [:]
    
    @State private var reloadTitles = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
    @State private var hideSidebar = false
    
    @State private var searchInSidebar = ""
    @State private var newTabSearch = ""
    @State private var newTabSaveSearch = ""
    
    @State private var currentTabNum = 0
    
    @State private var selectedIndex: Int? = 0
    
    @FocusState private var focusedField: FocusedField?
    
    @AppStorage("selectedSpaceIndex") var selectedSpaceIndex = 0
    
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = true
    @AppStorage("favoritesStyle") var favoritesStyle = false
    @AppStorage("faviconLoadingStyle") var faviconLoadingStyle = false
    
    @AppStorage("sidebarLeft") var sidebarLeft = true
    
    @AppStorage("showBorder") var showBorder = true
    
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
    
    var body: some View {
        GeometryReader { geo in
            if spaces.count > 0 {
                ZStack {
                    ZStack {
                        LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                        
                        HStack(spacing: 0) {
                            if sidebarLeft {
                                if showBorder {
                                    ThreeDots(hoverTinySpace: $hoverTinySpace, hideSidebar: $hideSidebar)
                                        .disabled(true)
                                }
                                
                                Sidebar(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, geo: geo)
                                    .animation(.easeOut).frame(width: hideSidebar ? 0: 300).offset(x: hideSidebar ? -320: 0).padding(.trailing, hideSidebar ? 0: 10)
                                    .padding(showBorder ? 0: 15)
                                    .padding(.top, showBorder ? 0: 10)
                            }
                            
                            ZStack {
                                Color.white
                                    .opacity(0.4)
                                    .cornerRadius(10)
                                //MARK: - WebView
                                if selectedTabLocation == "favoriteTabs" {
                                    WebView(navigationState: favoritesNavigationState)
                                        .cornerRadius(10)
                                }
                                if selectedTabLocation == "tabs" {
                                    WebView(navigationState: navigationState)
                                        .cornerRadius(10)
                                }
                                
                                if selectedTabLocation == "pinnedTabs" {
                                    WebView(navigationState: pinnedNavigationState)
                                        .cornerRadius(10)
                                }
                                
                                Spacer()
                                    .frame(width: 20)
                            }.padding(sidebarLeft ? .trailing: .leading, showBorder ? 12: 0)
                                .animation(.default)
                            
                            if !sidebarLeft {
                                if showBorder {
                                    ThreeDots(hoverTinySpace: $hoverTinySpace, hideSidebar: $hideSidebar)
                                        .disabled(true)
                                }
                                
                                
                                Sidebar(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, geo: geo)
                                
                                    .animation(.easeOut).frame(width: hideSidebar ? 0: 300).offset(x: hideSidebar ? 320: 0).padding(.leading, hideSidebar ? 0: 10)
                                    .padding(showBorder ? 0: 15)
                                    .padding(.top, showBorder ? 0: 10)
                            }
                        }
                        .padding(.trailing, showBorder ? 10: 0)
                        .padding(.vertical, showBorder ? 25: 0)
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
                                if !sidebarLeft {
                                    Spacer()
                                }
                                
                                ZStack {
                                    Color.white.opacity(0.00001)
                                        .frame(width: 35)
                                        .onTapGesture {
                                            tapSidebarShown = true
                                            
                                        }
                                    
                                    HStack {
                                        
                                        Sidebar(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, geo: geo)
                                            .padding(15)
                                            .background(content: {
                                                if sidebarLeft {
                                                    LinearGradient(colors: [startColor, Color(hex: averageHexColor(hex1: startHex, hex2: endHex))], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                        .opacity(1.0)
                                                } else {
                                                    LinearGradient(colors: [Color(hex: averageHexColor(hex1: startHex, hex2: endHex)), endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                        .opacity(1.0)
                                                }
                                            })
                                            .frame(width: 300)
                                            .cornerRadius(10)
                                            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 0)
                                        
                                        Spacer()
                                    }.padding(40)
                                        .padding(.leading, 30)
                                        .frame(width: hoveringSidebar || tapSidebarShown ? 350: 0)
                                        .offset(x: hoveringSidebar || tapSidebarShown ? 0: sidebarLeft ? -350: 300)
                                        .clipped()
                                    
                                }.onHover(perform: { hovering in
                                    if hovering {
                                        hoveringSidebar = true
                                    }
                                    else {
                                        hoveringSidebar = false
                                    }
                                })
                                
                                if sidebarLeft {
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
                                navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: formatURL(from: newTabSearch))!))
                                //modelContext.insert(TabStorage(url: formatURL(from: newTabSearch)))
                                
                                tabBarShown = false
                                commandBarSearchSubmitted = false
                                newTabSearch = ""
                                
                                saveSpaceData()
                            }
                    }
                    
                    
                    //MARK: - Command Bar
                    /*if commandBarShown {
                     ZStack {
                     Color.white.opacity(0.001)
                     .background(.thinMaterial)
                     
                     VStack {
                     HStack {
                     Image(systemName: "magnifyingglass")
                     .foregroundStyle(Color.black.opacity(0.3))
                     //.foregroundStyle(LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing))
                     
                     
                     TextField(text: $searchInSidebar) {
                     HStack {
                     Text("⌘+L - Search or Enter URL...")
                     .opacity(0.8)
                     //.foregroundStyle(Color.black.opacity(0.3))
                     //.foregroundStyle(LinearGradient(colors: [startColor, endColor], startPoint: .leading, endPoint: .trailing))
                     }
                     }
                     .autocorrectionDisabled(true)
                     .textInputAutocapitalization(.never)
                     .onSubmit {
                     if selectedTabLocation == "pinnedTabs" {
                     pinnedNavigationState.currentURL = URL(string: formatURL(from: searchInSidebar))
                     pinnedNavigationState.selectedWebView?.load(URLRequest(url: URL(string: searchInSidebar)!))
                     }
                     else if selectedTabLocation == "favoriteTabs" {
                     favoritesNavigationState.currentURL = URL(string: formatURL(from: searchInSidebar))
                     favoritesNavigationState.selectedWebView?.load(URLRequest(url: URL(string: searchInSidebar)!))
                     }
                     else {
                     navigationState.currentURL = URL(string: formatURL(from: searchInSidebar))
                     navigationState.selectedWebView?.load(URLRequest(url: URL(string: searchInSidebar)!))
                     }
                     
                     commandBarShown = false
                     }
                     .focused($focusedField, equals: .commandBar)
                     .onAppear() {
                     focusedField = .commandBar
                     }
                     .onDisappear() {
                     focusedField = .none
                     }
                     }
                     
                     SuggestionsView(newTabSearch: $searchInSidebar, newTabSaveSearch: $newTabSaveSearch, suggestionUrls: suggestionUrls)
                     }.padding(15)
                     }.frame(width: 550, height: 300).cornerRadius(10).shadow(color: Color(hex: "0000").opacity(0.5), radius: 20, x: 0, y: 0)
                     .ignoresSafeArea()
                     }*/
                    
                    else if commandBarShown {
                        CommandBar(commandBarText: $searchInSidebar, searchSubmitted: $commandBarSearchSubmitted2, collapseHeightAnimation: $commandBarCollapseHeightAnimation)
                            .onChange(of: commandBarSearchSubmitted) { thing in
                                if selectedTabLocation == "tabs" {
                                    //navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: formatURL(from: newTabSearch))!))
                                    navigationState.currentURL = URL(string: formatURL(from: newTabSearch))!
                                    //modelContext.insert(TabStorage(url: formatURL(from: newTabSearch)))
                                    
                                    //                                var savingWebsites = [] as [String]
                                    //                                for webView in navigationState.webViews.compactMap { $0.url?.absoluteString } {
                                    //                                    savingWebsites.append("\(webView.url?.description)")
                                    //                                }
                                    
                                    saveSpaceData()
                                }
                                
                                tabBarShown = false
                                commandBarSearchSubmitted = false
                                newTabSearch = ""
                            }
                    }
                }
                .onAppear() {
                    for space in spaces {
                        if space.spaceName == currentSpace {
                            for tab in space.tabUrls {
                                navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: tab) ?? URL(string: "https://figma.com")!))
                            }
                            for tab in space.pinnedUrls {
                                pinnedNavigationState.createNewWebView(withRequest: URLRequest(url: URL(string: tab) ?? URL(string: "https://thebrowser.company")!))
                            }
                            for tab in space.favoritesUrls {
                                favoritesNavigationState.createNewWebView(withRequest: URLRequest(url: URL(string: tab) ?? URL(string: "https://arc.net")!))
                            }
                        }
                    }
                    navigationState.selectedWebView = nil
                    pinnedNavigationState.selectedWebView = nil
                    favoritesNavigationState.selectedWebView = nil
                }
                
                
                .ignoresSafeArea()
            }
        }.task {
            if spaces.count <= 0 {
                await modelContext.insert(SpaceStorage(spaceName: "Untitled", spaceIcon: "circle.fill", favoritesUrls: [], pinnedUrls: [], tabUrls: []))
                
                do {
                    try await modelContext.save()
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func saveSpaceData() {
        let savingTodayTabs = navigationState.webViews.compactMap { $0.url?.absoluteString }
        let savingPinnedTabs = pinnedNavigationState.webViews.compactMap { $0.url?.absoluteString }
        let savingFavoriteTabs = favoritesNavigationState.webViews.compactMap { $0.url?.absoluteString }
        
        if !spaces.isEmpty {
            spaces[selectedSpaceIndex].tabUrls = savingTodayTabs
        }
        else {
            modelContext.insert(SpaceStorage(spaceName: "Untitled", spaceIcon: "circle.fill", favoritesUrls: [], pinnedUrls: [], tabUrls: savingTodayTabs))
        }
        
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func saveToLocalStorage() {
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
    }
}
