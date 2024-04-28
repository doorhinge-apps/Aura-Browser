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
    @Query var tabs: [TabStorage]
    
    // WebView Handling
    @ObservedObject var navigationState = NavigationState()
    @ObservedObject var pinnedNavigationState = NavigationState()
    @ObservedObject var favoritesNavigationState = NavigationState()
    
    // Storage and Website Loading
    @AppStorage("currentSpace") var currentSpace = "Untitled"
    @State private var spaces = ["Home", "Space 2"]
    @State private var spaceIcons: [String: String]? = [:]
    
    @State private var reloadTitles = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Settings and Sheets
    @State private var hoverTab = WKWebView()
    
    @State private var showSettings = false
    @State private var changeColorSheet = false
    
    @State private var startColor: Color = Color.purple
    @State private var endColor: Color = Color.pink
    
    @AppStorage("startColorHex") var startHex = "ffffff"
    @AppStorage("endColorHex") var endHex = "000000"
    
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
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ZStack {
                    LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                    
                    HStack(spacing: 0) {
                        if sidebarLeft {
                            if showBorder {
                                ThreeDots(hoverTinySpace: $hoverTinySpace, hideSidebar: $hideSidebar)
                                    .disabled(true)
                            }
                            
                            Sidebar(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, hoverSpace: $hoverSpace, geo: geo)
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
                            
                            //MARK: - Hidden Sidebar Actions
                            if hideSidebar && hoverTinySpace {
                                VStack {
                                    HStack {
                                        VStack {
                                            Button(action: {
                                                
                                                Task {
                                                    await hideSidebar.toggle()
                                                }
                                                
                                                Task {
                                                    await navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                                }
                                            }, label: {
                                                ZStack {
                                                    LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                        .opacity(hoverSidebarButton ? 1.0: 0.8)
                                                    
                                                    Image(systemName: "sidebar.left")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 25, height: 25)
                                                        .foregroundStyle(Color.white)
                                                        .opacity(hoverSidebarButton ? 1.0: 0.5)
                                                    
                                                }.animation(.smooth).frame(width: 50, height: 50).cornerRadius(75).hoverEffect(.lift)
                                            })
                                            .onHover(perform: { hovering in
                                                if hovering {
                                                    hoverSidebarButton = true
                                                }
                                                else {
                                                    hoverSidebarButton = false
                                                }
                                            })
                                            
                                            
                                            Button(action: {
                                                reloadRotation += 360
                                                
                                                if selectedTabLocation == "tabs" {
                                                    navigationState.selectedWebView?.reload()
                                                    navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                                    
                                                    navigationState.selectedWebView = navigationState.selectedWebView
                                                    //navigationState.currentURL = navigationState.currentURL
                                                    
                                                    if let unwrappedURL = navigationState.currentURL {
                                                        searchInSidebar = unwrappedURL.absoluteString
                                                    }
                                                }
                                                else if selectedTabLocation == "pinnedTabs" {
                                                    pinnedNavigationState.selectedWebView?.reload()
                                                    pinnedNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                                    
                                                    pinnedNavigationState.selectedWebView = pinnedNavigationState.selectedWebView
                                                    
                                                    if let unwrappedURL = pinnedNavigationState.currentURL {
                                                        searchInSidebar = unwrappedURL.absoluteString
                                                    }
                                                }
                                                else if selectedTabLocation == "favoriteTabs" {
                                                    favoritesNavigationState.selectedWebView?.reload()
                                                    favoritesNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                                    
                                                    favoritesNavigationState.selectedWebView = favoritesNavigationState.selectedWebView
                                                    
                                                    if let unwrappedURL = favoritesNavigationState.currentURL {
                                                        searchInSidebar = unwrappedURL.absoluteString
                                                    }
                                                }
                                                
                                                hoverTinySpace = false
                                            }, label: {
                                                ZStack {
                                                    //Color(.white)
                                                    //    .opacity(hoverSidebarButton ? 0.5: 0.0)
                                                    
                                                    LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                        .opacity(hoverReloadButton ? 1.0: 0.8)
                                                    
                                                    Image(systemName: "arrow.clockwise")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 25, height: 25)
                                                        .foregroundStyle(Color.white)
                                                        .opacity(hoverReloadButton ? 1.0: 0.5)
                                                        .rotationEffect(Angle(degrees: Double(reloadRotation)))
                                                        .animation(.bouncy, value: reloadRotation)
                                                    
                                                }.animation(.smooth).frame(width: 50, height: 50).cornerRadius(75).hoverEffect(.lift)
                                            })
                                            .onHover(perform: { hovering in
                                                if hovering {
                                                    hoverReloadButton = true
                                                }
                                                else {
                                                    hoverReloadButton = false
                                                }
                                            })
                                            
                                            
                                            
                                            Button(action: {
                                                if selectedTabLocation == "tabs" {
                                                    navigationState.selectedWebView?.goBack()
                                                }
                                                else if selectedTabLocation == "pinnedTabs" {
                                                    pinnedNavigationState.selectedWebView?.goBack()
                                                }
                                                else if selectedTabLocation == "favoriteTabs" {
                                                    favoritesNavigationState.selectedWebView?.goBack()
                                                }
                                                
                                                hoverTinySpace = false
                                            }, label: {
                                                ZStack {
                                                    //Color(.white)
                                                    //    .opacity(hoverSidebarButton ? 0.5: 0.0)
                                                    
                                                    LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                        .opacity(hoverBackwardButton ? 1.0: 0.8)
                                                    
                                                    Image(systemName: "arrow.left")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 25, height: 25)
                                                        .foregroundStyle(Color.white)
                                                        .opacity(hoverBackwardButton ? 1.0: 0.5)
                                                    
                                                }.animation(.smooth).frame(width: 50, height: 50).cornerRadius(75).hoverEffect(.lift)
                                            })
                                            .onHover(perform: { hovering in
                                                if hovering {
                                                    hoverBackwardButton = true
                                                }
                                                else {
                                                    hoverBackwardButton = false
                                                }
                                            })
                                            
                                            
                                            Button(action: {
                                                if selectedTabLocation == "tabs" {
                                                    navigationState.selectedWebView?.goForward()
                                                }
                                                else if selectedTabLocation == "pinnedTabs" {
                                                    pinnedNavigationState.selectedWebView?.goForward()
                                                }
                                                else if selectedTabLocation == "favoriteTabs" {
                                                    favoritesNavigationState.selectedWebView?.goForward()
                                                }
                                                
                                                hoverTinySpace = false
                                            }, label: {
                                                ZStack {
                                                    //Color(.white)
                                                    //    .opacity(hoverSidebarButton ? 0.5: 0.0)
                                                    
                                                    LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                        .opacity(hoverForwardButton ? 1.0: 0.8)
                                                    
                                                    Image(systemName: "arrow.right")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 25, height: 25)
                                                        .foregroundStyle(Color.white)
                                                        .opacity(hoverForwardButton ? 1.0: 0.5)
                                                    
                                                }.animation(.smooth).frame(width: 50, height: 50).cornerRadius(75).hoverEffect(.lift)
                                            })
                                            .onHover(perform: { hovering in
                                                if hovering {
                                                    hoverForwardButton = true
                                                }
                                                else {
                                                    hoverForwardButton = false
                                                }
                                            })
                                            
                                            
                                            
                                            Button(action: {
                                                tabBarShown = true
                                                
                                                hoverTinySpace = false
                                            }, label: {
                                                ZStack {
                                                    //Color(.white)
                                                    //    .opacity(hoverSidebarButton ? 0.5: 0.0)
                                                    
                                                    LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                        .opacity(hoverNewTab ? 1.0: 0.8)
                                                    
                                                    Image(systemName: "plus")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 25, height: 25)
                                                        .foregroundStyle(Color.white)
                                                        .opacity(hoverNewTab ? 1.0 : 0.5)
                                                }.animation(.smooth).frame(width: 50, height: 50).cornerRadius(75).hoverEffect(.lift)
                                            })
                                            .onHover(perform: { hovering in
                                                if hovering {
                                                    hoverNewTab = true
                                                }
                                                else {
                                                    hoverNewTab = false
                                                }
                                            })
                                            
                                        }
                                        
                                        
                                        Spacer()
                                    }
                                    
                                    Spacer()
                                }
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
                            
                            
                            Sidebar(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, hoverSpace: $hoverSpace, geo: geo)
                            
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
                                    
                                    Sidebar(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, hoverSpace: $hoverSpace, geo: geo)
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
                    ZStack {
                        Color.white.opacity(0.001)
                            .background(.regularMaterial)
                        
                        VStack {
                            ZStack {
                                Color.white.opacity(0.0001)
                                    .onTapGesture {
                                        focusedField = .tabBar
                                    }
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(Color.black.opacity(0.3))
                                    //.foregroundStyle(LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing))
                                    
                                    
                                    TextField(text: $newTabSearch) {
                                        HStack {
                                            Text("Search or Enter URL...")
                                                .opacity(0.8)
                                            //.foregroundStyle(Color.black.opacity(0.3))
                                            //.foregroundStyle(LinearGradient(colors: [startColor, endColor], startPoint: .leading, endPoint: .trailing))
                                        }
                                    }
                                    .autocorrectionDisabled(true)
                                    .textInputAutocapitalization(.never)
                                    .onSubmit {
                                        navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: formatURL(from: newTabSearch))!))
                                        modelContext.insert(TabStorage(url: formatURL(from: newTabSearch)))
                                        
                                        tabBarShown = false
                                    }
                                    .focused($focusedField, equals: .tabBar)
                                    .onAppear() {
                                        focusedField = .tabBar
                                    }
                                    .onDisappear() {
                                        focusedField = .none
                                        newTabSearch = ""
                                    }
                                    .onChange(of: newTabSearch) { thing in
                                        newTabSaveSearch = newTabSearch
                                    }
                                    
                                }.padding([.leading, .trailing, .top], 15)
                            }.frame(height: 50)
                            
                            SuggestionsView(newTabSearch: $newTabSearch, newTabSaveSearch: $newTabSaveSearch, suggestionUrls: suggestionUrls)
                                .padding([.leading, .trailing, .bottom], 15)
                        }
                    }.frame(width: 550, height: 300).cornerRadius(10).shadow(color: Color(hex: "0000").opacity(0.5), radius: 20, x: 0, y: 0)
                        .ignoresSafeArea()
                }
                
                //MARK: - Command Bar
                else if commandBarShown {
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
                }
            }
            .onChange(of: spaces) { newValue in
                UserDefaults.standard.setValue(spaces, forKey: "spaces")
            }
            .onChange(of: spaceIcons) { newValue in
                UserDefaults.standard.setValue(spaceIcons, forKey: "spaceIcons")
            }
            .onChange(of: navigationState.webViews) { newValue in
                saveToLocalStorage()
            }
            .onChange(of: pinnedNavigationState.webViews) { newValue in
                saveToLocalStorage()
            }
            .onChange(of: favoritesNavigationState.webViews) { newValue in
                saveToLocalStorage()
            }
            .ignoresSafeArea()
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
