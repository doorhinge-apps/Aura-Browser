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


struct Suggestion: Identifiable, Codable {
    var id: String    // This will hold the Firestore document ID
    var url: String
}

class FaviconStore: ObservableObject {
    @Published var favicons: [String: FaviconImage] = [:]
    
    func fetchFavicon(for webView: WKWebView) {
        guard let urlString = webView.url?.absoluteString else { return }
        
        // Avoid refetching if we already have the favicon.
        if favicons[urlString] != nil { return }
        
        Task {
            do {
                let favicon = try await FaviconFinder(url: webView.url!)
                    .fetchFaviconURLs()
                    .download()
                    .largest ()
                
                // Update the favicons dictionary. Make sure this happens on the main thread.
                DispatchQueue.main.async {
                    self.favicons[urlString] = favicon.image
                }
            } catch {
                print("Failed to fetch favicon for \(urlString): \(error)")
            }
            
        }
    }
}

let defaults = UserDefaults.standard

extension UIColor {
    func toHex() -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}

struct ContentView: View {
    // WebView Handling
    @ObservedObject var navigationState = NavigationState()
    @ObservedObject var pinnedNavigationState = NavigationState()
    @ObservedObject var favoritesNavigationState = NavigationState()
    
    @ObservedObject var favicons = FaviconStore()
    
    
    // Storage and Website Loading
    @AppStorage("currentSpace") var currentSpace = "Untitled"
    @State var spaces = ["Home", "Space 2"]
//    @State var spaceIcons = [:] as? Dictionary<String, String>
    @State var spaceIcons: [String: String]? = [:]
    
    @State var reloadTitles = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    // Settings and Sheets
    @State var hoverTab = WKWebView()
    
    @State var showSettings = false
    @State var changeColorSheet = false
    
    @State var startColor: Color = Color.purple
    @State var endColor: Color = Color.pink
    
    @AppStorage("startColorHex") var startHex = "ffffff"
    @AppStorage("endColorHex") var endHex = "000000"
    
    @State var presentIcons = false
    
    
    // Hover Effects
    @State var hoverTinySpace = false
    
    @State var hoverSidebarButton = false
    @State var hoverPaintbrush = false
    @State var hoverReloadButton = false
    @State var hoverForwardButton = false
    @State var hoverBackwardButton = false
    @State var hoverNewTab = false
    @State var settingsButtonHover = false
    @State var hoverNewTabSection = false
    
    @State var hoverSpaceIndex = 1000
    @State var hoverSpace = ""
    
    @State var hoverSidebarSearchField = false
    
    @State var hoverCloseTab = WKWebView()
    
    @State var spaceIconHover = false
    
    
    // Animations and Gestures
    @State var reloadRotation = 0
    @State var draggedTab: WKWebView?
    
    
    // Selection States
    @State var tabBarShown = false
    @State var commandBarShown = false
    
    @State var changingIcon = ""
    @State var hideSidebar = false
    
    @State var searchInSidebar = ""
    @State var newTabSearch = ""
    @State var newTabSaveSearch = ""
    
    @State var currentTabNum = 0
    
    @State var selectedIndex: Int? = 0
    
    @FocusState private var focusedField: FocusedField?
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = true
    @AppStorage("favoritesStyle") var favoritesStyle = false
    @AppStorage("faviconLoadingStyle") var faviconLoadingStyle = false
    
    @AppStorage("sidebarLeft") var sidebarLeft = true
    
    @AppStorage("showBorder") var showBorder = true
    
    @State var inspectCode = ""
    
    enum FocusedField {
        case commandBar, tabBar, none
    }
    @State var selectedTabLocation = "tabs"
    
    // Other Stuff
    @State var screenWidth = UIScreen.main.bounds.width
    
    @State var hoveringSidebar = false
    @State var tapSidebarShown = false
    
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
                        
                        VStack {
                            //MARK: - Sidebar Buttons
                            ToolbarButtonsView(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, geo: geo).frame(height: 40)
                            
                            sidebar
                        }
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
                        //if navigationState.selectedWebView != nil {
                        if selectedTabLocation == "tabs" {
                            WebView(navigationState: navigationState)
                                .cornerRadius(10)
                        }
                        
                        //if pinnedNavigationState.selectedWebView != nil {
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
                                            
                                            //                                            navigationState.selectedWebView?.reload()
                                            //                                            navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                            //
                                            //                                            navigationState.selectedWebView = navigationState.selectedWebView
                                            //                                            //navigationState.currentURL = navigationState.currentURL
                                            //
                                            //                                            if let unwrappedURL = navigationState.currentURL {
                                            //                                                searchInSidebar = unwrappedURL.absoluteString
                                            //                                            }
                                            //                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            //                                                navigationState.selectedWebView?.reload()
                                            //                                                navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                            //
                                            //                                                navigationState.selectedWebView = navigationState.selectedWebView
                                            //                                                //navigationState.currentURL = navigationState.currentURL
                                            //
                                            //                                                if let unwrappedURL = navigationState.currentURL {
                                            //                                                    searchInSidebar = unwrappedURL.absoluteString
                                            //                                                }
                                            //                                            }
                                            Task {
                                                await navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                            }
                                        }, label: {
                                            ZStack {
                                                //Color(.white)
                                                //    .opacity(hoverSidebarButton ? 0.5: 0.0)
                                                
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
                                                    .opacity(hoverNewTab ? 1.0: 0.5)
                                                
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
                    
                    
                    // Beta for inspect element
                    /*VStack {
                     ScrollView {
                     ScrollView(.horizontal) {
                     CodeText(inspectCode)
                     .codeTextLanguage(.html)
                     .font(.system(.callout, weight: .semibold))
                     .onChange(of: navigationState.selectedWebView) { thing in
                     DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                     Task {
                     await getHTMLContent(from: navigationState.selectedWebView ?? WKWebView()) { htmlContent in
                     if let html = htmlContent {
                     inspectCode = "\(htmlContent)"
                     } else {
                     inspectCode = "Error"
                     }
                     }
                     }
                     }
                     }
                     }
                     }
                     }.frame(width: 150)
                     .clipped()*/
                    if !sidebarLeft {
                        if showBorder {
                            ThreeDots(hoverTinySpace: $hoverTinySpace, hideSidebar: $hideSidebar)
                                .disabled(true)
                        }
                        
                        VStack {
                            //MARK: - Sidebar Buttons
                            ToolbarButtonsView(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, geo: geo).frame(height: 40)
                            
                            sidebar
                        }
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
                    
                    //searchSuggestions.fetchData()
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
                                    
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                                        tapSidebarShown = false
//                                    }
                                }
                            
                            HStack {
                                VStack {
                                    ToolbarButtonsView(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, geo: geo).frame(height: 40)
                                    
                                    sidebar
                                }.padding(15)
                                    .background(content: {
                                        LinearGradient(colors: [startColor, Color(hex: averageHexColor(hex1: startHex, hex2: endHex))], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                            .opacity(1.0)
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
                /*.onHover(perform: { hovering in
                 if hovering {
                 hoveringSidebar = true
                 }
                 else {
                 hoveringSidebar = false
                 }
                 })*/
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
//                            ZStack {
//                                Color.white
//
//                                VStack {
//                                    HStack {
//                                        Image(systemName: "magnifyingglass")
//                                            .foregroundStyle(LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing))
//
//                                        TextField("⌘+L - Search or Enter URL...", text: $searchInSidebar)
//                                            .textInputAutocapitalization(.never)
//                                            .foregroundStyle(LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing))
//                                            .autocorrectionDisabled(true)
//                                            .focused($focusedField, equals: .commandBar)
//                                            .onAppear() {
//                                                focusedField = .commandBar
//                                            }
//                                            .onDisappear() {
//                                                focusedField = .none
//                                            }
//                                            .onSubmit {
//                                                //searchSuggestions.addSuggestion(url: newTabSearch)
//                                                //navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: formatURL(from: searchInSidebar))!))
//                                                navigationState.currentURL = URL(string: formatURL(from: searchInSidebar))
//
//                                                navigationState.selectedWebView?.load(URLRequest(url: URL(string: searchInSidebar)!))
//
//                                                //navigationState.selectedWebView?.reload()
//
//                                                commandBarShown = false
//                                            }
//                                    }
//                                    .padding(20)
//                                }
//                            }.frame(width: 550, height: 300).cornerRadius(10).shadow(color: Color(hex: "0000").opacity(0.5), radius: 20, x: 0, y: 0)
//                                .ignoresSafeArea()
                    
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
                                        //navigationState.currentURL = URL(string: formatURL(from: searchInSidebar))
                                        //navigationState.selectedWebView?.load(URLRequest(url: URL(string: searchInSidebar)!))
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
            .onAppear {
                if let urlsData = UserDefaults.standard.data(forKey: "\(currentSpace)userTabs"),
                   let urlStringArray = try? JSONDecoder().decode([String].self, from: urlsData) {
                    let urls = urlStringArray.compactMap { URL(string: $0) }
                    for url in urls {
                        let request = URLRequest(url: url)
                        
                        navigationState.createNewWebView(withRequest: request)
                        
                    }
                }
                
                if let urlsData = UserDefaults.standard.data(forKey: "\(currentSpace)pinnedTabs"),
                   let urlStringArray = try? JSONDecoder().decode([String].self, from: urlsData) {
                    let urls = urlStringArray.compactMap { URL(string: $0) }
                    for url in urls {
                        let request = URLRequest(url: url)
                        
                        pinnedNavigationState.createNewWebView(withRequest: request)
                        
                    }
                }
                
                if let urlsData = UserDefaults.standard.data(forKey: "\(currentSpace)favoriteTabs"),
                   let urlStringArray = try? JSONDecoder().decode([String].self, from: urlsData) {
                    let urls = urlStringArray.compactMap { URL(string: $0) }
                    for url in urls {
                        let request = URLRequest(url: url)
                        
                        favoritesNavigationState.createNewWebView(withRequest: request)
                        
                    }
                }
                
                Task {
                    await navigationState.selectedWebView = nil
                    await navigationState.currentURL = nil
                    
                    await pinnedNavigationState.selectedWebView = nil
                    await pinnedNavigationState.currentURL = nil
                    
                    await favoritesNavigationState.selectedWebView = nil
                    await favoritesNavigationState.currentURL = nil
                }
                
                spaceIcons = UserDefaults.standard.dictionary(forKey: "spaceIcons") as? [String: String]
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
    
    func getHTMLContent(from webView: WKWebView, completion: @escaping (String?) -> Void) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { (html: Any?, error: Error?) in
            guard let htmlString = html as? String, error == nil else {
                print("Failed to get HTML: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            completion(htmlString)
        }
    }
    
    
    var sidebar: some View {
        VStack {
            
            
            //Text(navigationState.currentURL?.absoluteString ?? "")
            //    .lineLimit(1)
            
            //MARK: - Sidebar Searchbar
            Button {
                if ((navigationState.currentURL?.absoluteString.isEmpty) == nil) && ((pinnedNavigationState.currentURL?.absoluteString.isEmpty) == nil) && ((favoritesNavigationState.currentURL?.absoluteString.isEmpty) == nil) {
                    newTabSearch = ""
                    tabBarShown.toggle()
                    commandBarShown = false
                }
                else {
                    commandBarShown.toggle()
                    tabBarShown = false
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Color(.white).opacity(hoverSidebarSearchField ? 0.3 : 0.15))
                    //.foregroundStyle(navigationState.currentURL?.absoluteString ?? "(none)" == tab.url ? Color(.white).opacity(0.4): hoverTab == tab ? Color(.white).opacity(0.2): Color.clear)
                        .frame(height: 50)
                    
                    HStack {
                        if navigationState.currentURL != nil {
                            Text(navigationState.currentURL?.absoluteString ?? "")
                                .padding(.leading, 5)
                                .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                                .lineLimit(1)
                                .onReceive(timer) { _ in
                                    if !commandBarShown {
                                        if let unwrappedURL = navigationState.selectedWebView?.url {
                                            searchInSidebar = unwrappedURL.absoluteString
                                        }
                                    }
                                }
                        }
                        else if pinnedNavigationState.currentURL != nil {
                            Text(pinnedNavigationState.currentURL?.absoluteString ?? "")
                                .padding(.leading, 5)
                                .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                                .lineLimit(1)
                                .onReceive(timer) { _ in
                                    if !commandBarShown {
                                        if let unwrappedURL = pinnedNavigationState.selectedWebView?.url {
                                            searchInSidebar = unwrappedURL.absoluteString
                                        }
                                    }
                                }
                        }
                        else if favoritesNavigationState.currentURL != nil {
                            Text(favoritesNavigationState.currentURL?.absoluteString ?? "")
                                .padding(.leading, 5)
                                .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                                .lineLimit(1)
                                .onReceive(timer) { _ in
                                    if !commandBarShown {
                                        if let unwrappedURL = favoritesNavigationState.selectedWebView?.url {
                                            searchInSidebar = unwrappedURL.absoluteString
                                        }
                                    }
                                }
                        }
                        
                        Spacer() // Pushes the delete button to the edge
                    }
                    
                    
                }.onHover(perform: { hovering in
                    if hovering {
                        hoverSidebarSearchField = true
                    }
                    else {
                        hoverSidebarSearchField = false
                    }
                })
            }.keyboardShortcut("l", modifiers: .command)
            
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(favoritesNavigationState.webViews, id:\.self) { tab in
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(tab == favoritesNavigationState.selectedWebView ? 1.0 : hoverTab == tab ? 0.6: 0.2), lineWidth: 3)
                            .fill(Color(.white).opacity(tab == favoritesNavigationState.selectedWebView ? 0.5 : hoverTab == tab ? 0.15: 0.0001))
                            .frame(height: 75)
                        
                        
                        if favoritesStyle {
                            HStack {
                                if tab.title == "" {
                                    Text(tab.url?.absoluteString ?? "Tab not found.")
                                        .lineLimit(1)
                                        .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                                        .padding(.leading, 5)
                                        .onReceive(timer) { _ in
                                            reloadTitles.toggle()
                                        }
                                }
                                else {
                                    Text(tab.title ?? "Tab not found.")
                                        .lineLimit(1)
                                        .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                                        .padding(.leading, 5)
                                        .onReceive(timer) { _ in
                                            reloadTitles.toggle()
                                        }
                                }
                            }
                        } else {
                            if faviconLoadingStyle {
                                WebImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(tab.url?.absoluteString)&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35, height: 35)
                                        .cornerRadius(50)
                                } placeholder: {
                                    Rectangle().foregroundColor(.gray)
                                }
                                .onSuccess { image, data, cacheType in
                                    // Success
                                    // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                                }
                                .indicator(.activity) // Activity Indicator
                                .transition(.fade(duration: 0.5)) // Fade Transition with duration
                                .scaledToFit()
                            } else {
                                AsyncImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(tab.url?.absoluteString)&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 35, height: 35)
                                        .cornerRadius(50)
                                    
                                } placeholder: {
                                    LoadingAnimations(size: 35, borderWidth: 5.0)
                                }

                            }
                        }
                        
                        
                    }
                    .contextMenu {
                        Button {
                            pinnedNavigationState.webViews.append(tab)
                            
                            if let index = favoritesNavigationState.webViews.firstIndex(of: tab) {
                                favoriteRemoveTab(at: index)
                            }
                        } label: {
                            Label("Pin Tab", systemImage: "pin")
                        }
                        
                        Button {
                            navigationState.webViews.append(tab)
                            
                            if let index = favoritesNavigationState.webViews.firstIndex(of: tab) {
                                favoriteRemoveTab(at: index)
                            }
                        } label: {
                            Label("Unfavorite", systemImage: "star.fill")
                        }
                        
                        Button {
                            if let index = favoritesNavigationState.webViews.firstIndex(of: tab) {
                                favoriteRemoveTab(at: index)
                            }
                        } label: {
                            Label("Close Tab", systemImage: "xmark")
                        }
                        
                    }
                    .onAppear() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            hoverTab = WKWebView()
                        }
                    }
                    .onHover(perform: { hovering in
                        if hovering {
                            hoverTab = tab
                        }
                        else {
                            hoverTab = WKWebView()
                        }
                    })
                    .onTapGesture {
                        
                        navigationState.selectedWebView = nil
                        navigationState.currentURL = nil
                        
                        pinnedNavigationState.selectedWebView = nil
                        pinnedNavigationState.currentURL = nil
                        
                        selectedTabLocation = "favoriteTabs"
                        
                        Task {
                            await favoritesNavigationState.selectedWebView = tab
                            await favoritesNavigationState.currentURL = tab.url
                        }
                        
                        if let unwrappedURL = tab.url {
                            searchInSidebar = unwrappedURL.absoluteString
                        }
                    }
                    .onDrag {
                        self.draggedTab = tab
                        return NSItemProvider()
                    }
                    .onDrop(of: [.text], delegate: DropViewDelegate(destinationItem: tab, allTabs: $favoritesNavigationState.webViews, draggedItem: $draggedTab))
                }
            }
            
            
            //MARK: - Tabs
            ScrollView {
                //FavoriteTabs(navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hoverTab: hoverTab, reloadTitles: $reloadTitles, selectedTabLocation: $selectedTabLocation, searchInSidebar: $searchInSidebar, draggedTab: draggedTab)
                
                
                ForEach(pinnedNavigationState.webViews, id: \.self) { tab in
                    //ReorderableForEach(navigationState.webViews, id: \.self) { tab, isDragged in
                    //ReorderableForEach(navigationState.webViews) {tab, isDragged in
                    ZStack {
                        if reloadTitles {
                            Color.white.opacity(0.0)
                        }
                        
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(Color(.white).opacity(tab == pinnedNavigationState.selectedWebView ? 0.5 : hoverTab == tab ? 0.2: 0.0001))
                        //.foregroundStyle(navigationState.currentURL?.absoluteString ?? "(none)" == tab.url ? Color(.white).opacity(0.4): hoverTab == tab ? Color(.white).opacity(0.2): Color.clear)
                            .frame(height: 50)
                        
                        
                        HStack {
                            if faviconLoadingStyle {
                                WebImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(tab.url?.absoluteString)&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .cornerRadius(50)
                                        .padding(.leading, 5)
                                    
                                } placeholder: {
                                    LoadingAnimations(size: 25, borderWidth: 5.0)
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
                                AsyncImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(tab.url?.absoluteString)&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .cornerRadius(50)
                                        .padding(.leading, 5)
                                    
                                } placeholder: {
                                    LoadingAnimations(size: 25, borderWidth: 5.0)
                                        .padding(.leading, 5)
                                }

                            }
                            
                            
                            if tab.title == "" {
                                Text(tab.url?.absoluteString ?? "Tab not found.")
                                    .lineLimit(1)
                                    .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                                    .padding(.leading, 5)
                                    .onReceive(timer) { _ in
                                        reloadTitles.toggle()
                                    }
                            }
                            else {
                                Text(tab.title ?? "Tab not found.")
                                    .lineLimit(1)
                                    .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                                    .padding(.leading, 5)
                                    .onReceive(timer) { _ in
                                        reloadTitles.toggle()
                                    }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                if let index = pinnedNavigationState.webViews.firstIndex(of: tab) {
                                    pinnedRemoveTab(at: index)
                                }
                            }) {
                                if hoverTab == tab || pinnedNavigationState.selectedWebView == tab {
                                    ZStack {
                                        Color(.white)
                                            .opacity(hoverCloseTab == tab ? 0.3: 0.0)
                                        
                                        Image(systemName: "xmark")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 15, height: 15)
                                            .foregroundStyle(Color.white)
                                            .opacity(hoverCloseTab == tab ? 1.0: 0.8)
                                        
                                    }.frame(width: 35, height: 35).cornerRadius(7).padding(.trailing, 10)
                                        .hoverEffect(.lift)
                                        .onHover(perform: { hovering in
                                            if hovering {
                                                hoverCloseTab = tab
                                            }
                                            else {
                                                hoverCloseTab = WKWebView()
                                            }
                                        })
                                    
                                }
                            }
                        }
                        
                        
                    }
                    .contextMenu {
                        Button {
                            pinnedNavigationState.createNewWebView(withRequest: URLRequest(url: URL(string: formatURL(from: tab.url?.absoluteString ?? ""))!))
                        } label: {
                            Label("Duplicate", systemImage: "plus.square.on.square")
                        }
                        
                        Button {
                            navigationState.webViews.append(tab)
                            
                            if let index = pinnedNavigationState.webViews.firstIndex(of: tab) {
                                pinnedRemoveTab(at: index)
                            }
                        } label: {
                            Label("Unpin", systemImage: "pin.fill")
                        }
                        
                        Button {
                            favoritesNavigationState.webViews.append(tab)
                            
                            if let index = pinnedNavigationState.webViews.firstIndex(of: tab) {
                                pinnedRemoveTab(at: index)
                            }
                        } label: {
                            Label("Favorite", systemImage: "star")
                        }
                        
                        Button {
                            if let index = pinnedNavigationState.webViews.firstIndex(of: tab) {
                                pinnedRemoveTab(at: index)
                            }
                        } label: {
                            Label("Close Tab", systemImage: "xmark")
                        }
                        
                    }
                    .onAppear() {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            hoverTab = WKWebView()
                        }
                    }
                    .onHover(perform: { hovering in
                        if hovering {
                            hoverTab = tab
                        }
                        else {
                            hoverTab = WKWebView()
                        }
                    })
                    .onTapGesture {
                        navigationState.selectedWebView = nil
                        navigationState.currentURL = nil
                        
                        favoritesNavigationState.selectedWebView = nil
                        favoritesNavigationState.currentURL = nil
                        
                        selectedTabLocation = "pinnedTabs"
                        
                        Task {
                            await pinnedNavigationState.selectedWebView = tab
                            await pinnedNavigationState.currentURL = tab.url
                        }
                        
                        if let unwrappedURL = tab.url {
                            searchInSidebar = unwrappedURL.absoluteString
                        }
                    }
                    .onDrag {
                        self.draggedTab = tab
                        return NSItemProvider()
                    }
                    .onDrop(of: [.text], delegate: DropViewDelegate(destinationItem: tab, allTabs: $pinnedNavigationState.webViews, draggedItem: $draggedTab))
                }
                
                HStack {
                    Button {
                        presentIcons.toggle()
                    } label: {
                        ZStack {
                            Color(.white)
                                .opacity(spaceIconHover ? 0.5: 0.0)
                            
                            Image(systemName: spaceIcons?[currentSpace] ?? "circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.white)
                                .opacity(spaceIconHover ? 1.0: 0.5)
                            
                        }.frame(width: 40, height: 40).cornerRadius(7)
                            .hoverEffect(.lift)
                            .onHover(perform: { hovering in
                                if hovering {
                                    spaceIconHover = true
                                }
                                else {
                                    spaceIconHover = false
                                }
                            })
                    }

                    
                    Text(currentSpace)
                        .foregroundStyle(Color.white)
                        .opacity(0.5)
                        .font(.system(.caption, design: .rounded, weight: .medium))
                    
                    Color.white
                        .opacity(0.5)
                        .frame(height: 1)
                        .cornerRadius(10)
                    
                }.padding(.vertical, 10)
                    .popover(isPresented: $presentIcons) {
                        ZStack {
                            LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                .opacity(1.0)
                            
                            
                            IconsPicker(currentIcon: $changingIcon)
                                .onChange(of: changingIcon) { thing in
                                    
                                }
                                .onDisappear() {
                                    changingIcon = ""
                                }
                        }
                    }
                
                Button {
                    tabBarShown.toggle()
                    
                    hoverTinySpace.toggle()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(Color(.white).opacity(hoverNewTabSection ? 0.5: 0.0))
                            .frame(height: 50)
                        HStack {
                            Label("New Tab", systemImage: "plus")
                                .foregroundStyle(Color.white)
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .padding(.leading, 10)
                            
                            Spacer()
                        }
                    }
                    .onHover(perform: { hovering in
                        if hovering {
                            hoverNewTabSection = true
                        }
                        else {
                            hoverNewTabSection = false
                        }
                    })
                }
                
                
                
                
                ForEach(navigationState.webViews.reversed(), id: \.self) { tab in
                    //ReorderableForEach(navigationState.webViews, id: \.self) { tab, isDragged in
                    //ReorderableForEach(navigationState.webViews) {tab, isDragged in
                    ZStack {
                        if reloadTitles {
                            Color.white.opacity(0.0)
                        }
                        
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(Color(.white).opacity(tab == navigationState.selectedWebView ? 0.5 : hoverTab == tab ? 0.2: 0.0))
                        //.foregroundStyle(navigationState.currentURL?.absoluteString ?? "(none)" == tab.url ? Color(.white).opacity(0.4): hoverTab == tab ? Color(.white).opacity(0.2): Color.clear)
                            .frame(height: 50)
                        
                        
                        HStack {
                            if faviconLoadingStyle {
                                WebImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(tab.url?.absoluteString)&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .cornerRadius(50)
                                        .padding(.leading, 5)
                                    
                                } placeholder: {
                                    LoadingAnimations(size: 25, borderWidth: 5.0)
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
                                AsyncImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(tab.url?.absoluteString)&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                        .cornerRadius(50)
                                        .padding(.leading, 5)
                                    
                                } placeholder: {
                                    LoadingAnimations(size: 25, borderWidth: 5.0)
                                        .padding(.leading, 5)
                                }

                            }

                            
                            if tab.title == "" {
                                Text(tab.url?.absoluteString ?? "Tab not found.")
                                    .lineLimit(1)
                                    .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                                    .padding(.leading, 5)
                                    .onReceive(timer) { _ in
                                        reloadTitles.toggle()
                                    }
                            }
                            else {
                                Text(tab.title ?? "Tab not found.")
                                    .lineLimit(1)
                                    .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                                    .padding(.leading, 5)
                                    .onReceive(timer) { _ in
                                        reloadTitles.toggle()
                                    }
                            }
                            
                            Spacer() // Pushes the delete button to the edge
                            
                            Button(action: {
                                if let index = navigationState.webViews.firstIndex(of: tab) {
                                    removeTab(at: index)
                                }
                            }) {
                                if hoverTab == tab || navigationState.selectedWebView == tab {
                                    ZStack {
                                        Color(.white)
                                            .opacity(hoverCloseTab == tab ? 0.3: 0.0)
                                        
                                        Image(systemName: "xmark")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 15, height: 15)
                                            .foregroundStyle(Color.white)
                                            .opacity(hoverCloseTab == tab ? 1.0: 0.8)
                                        
                                    }.frame(width: 35, height: 35).cornerRadius(7).padding(.trailing, 10)
                                        .hoverEffect(.lift)
                                        .onHover(perform: { hovering in
                                            if hovering {
                                                hoverCloseTab = tab
                                            }
                                            else {
                                                hoverCloseTab = WKWebView()
                                            }
                                        })
                                    
                                }
                            }.keyboardShortcut("w", modifiers: .option)
                        }
                        
                    }
                    .contextMenu {
                        Button {
                            navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: formatURL(from: tab.url?.absoluteString ?? ""))!))
                        } label: {
                            Label("Duplicate", systemImage: "plus.square.on.square")
                        }
                        
                        Button {
                            pinnedNavigationState.webViews.append(tab)
                            
                            if let index = navigationState.webViews.firstIndex(of: tab) {
                                removeTab(at: index)
                            }
                        } label: {
                            Label("Pin Tab", systemImage: "pin")
                        }
                        
                        Button {
                            favoritesNavigationState.webViews.append(tab)
                            
                            if let index = navigationState.webViews.firstIndex(of: tab) {
                                removeTab(at: index)
                            }
                        } label: {
                            Label("Favorite", systemImage: "star")
                        }
                        
                        Button {
                            if let index = navigationState.webViews.firstIndex(of: tab) {
                                removeTab(at: index)
                            }
                        } label: {
                            Label("Close Tab", systemImage: "xmark")
                        }
                        
                    }
                    .onHover(perform: { hovering in
                        if hovering {
                            hoverTab = tab
                        }
                        else {
                            hoverTab = WKWebView()
                        }
                    })
                    .onTapGesture {
                        pinnedNavigationState.selectedWebView = nil
                        pinnedNavigationState.currentURL = nil
                        
                        favoritesNavigationState.selectedWebView = nil
                        favoritesNavigationState.currentURL = nil
                        
                        selectedTabLocation = "tabs"
                        
                        Task {
                            await navigationState.selectedWebView = tab
                            await navigationState.currentURL = tab.url
                        }
                        
                        if let unwrappedURL = tab.url {
                            searchInSidebar = unwrappedURL.absoluteString
                        }
                    }
                    .onDrag {
                        self.draggedTab = tab
                        return NSItemProvider()
                    }
                    .onDrop(of: [.text], delegate: DropViewDelegate(destinationItem: tab, allTabs: $navigationState.webViews, draggedItem: $draggedTab))
                }
            }
            
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
                            .foregroundStyle(Color.white)
                            .opacity(settingsButtonHover ? 1.0: 0.5)
                        
                    }.frame(width: 40, height: 40).cornerRadius(7)
                        .hoverEffect(.lift)
                        .hoverEffectDisabled(!hoverEffectsAbsorbCursor)
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
                    Settings(presentSheet: $showSettings)
                }
                
                Spacer()
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(spaces, id:\.self) { space in
                            Button {
                                saveToLocalStorage2(spaceName: currentSpace)
                                
                                currentSpace = space
                                
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
                                    print("\(currentSpace)userTabs")
                                    
                                    if let urlsData = UserDefaults.standard.data(forKey: "\(currentSpace)userTabs"),
                                       let urlStringArray = try? JSONDecoder().decode([String].self, from: urlsData) {
                                        let urls = urlStringArray.compactMap { URL(string: $0) }
                                        for url in urls {
                                            let request = URLRequest(url: url)
                                            
                                            await navigationState.createNewWebView(withRequest: request)
                                            
                                        }
                                    }
                                    
                                    if let urlsData = UserDefaults.standard.data(forKey: "\(currentSpace)pinnedTabs"),
                                       let urlStringArray = try? JSONDecoder().decode([String].self, from: urlsData) {
                                        let urls = urlStringArray.compactMap { URL(string: $0) }
                                        for url in urls {
                                            let request = URLRequest(url: url)
                                            
                                            await pinnedNavigationState.createNewWebView(withRequest: request)
                                            
                                        }
                                    }
                                    
                                    if let urlsData = UserDefaults.standard.data(forKey: "\(currentSpace)favoriteTabs"),
                                       let urlStringArray = try? JSONDecoder().decode([String].self, from: urlsData) {
                                        let urls = urlStringArray.compactMap { URL(string: $0) }
                                        for url in urls {
                                            let request = URLRequest(url: url)
                                            
                                            await favoritesNavigationState.createNewWebView(withRequest: request)
                                            
                                        }
                                    }
                                }
                            } label: {
                                ZStack {
                                    Color(.white)
                                        .opacity(hoverSpace == space ? 0.5: 0.0)
                                    
                                    Image(systemName: String(spaceIcons?[space] ?? "circle.fill"))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(Color.white)
                                        .opacity(hoverSpace == space ? 1.0: 0.5)
                                    
                                }.frame(width: 40, height: 40).cornerRadius(7)
                                    .hoverEffect(.lift)
                                    .hoverEffectDisabled(!hoverEffectsAbsorbCursor)
                                    .onHover(perform: { hovering in
                                        if hovering {
                                            hoverSpace = space
                                        }
                                        else {
                                            hoverSpace = ""
                                        }
                                    })
                            }
                            
                        }
                    }.padding(.horizontal, 10)
                }.scrollIndicators(.hidden)
                    .frame(height: 45)
            }
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
    
    func saveToLocalStorage2(spaceName: String) {
        let urlStringArray = navigationState.webViews.compactMap { $0.url?.absoluteString }
            if let urlsData = try? JSONEncoder().encode(urlStringArray){
            UserDefaults.standard.set(urlsData, forKey: "\(spaceName)userTabs")
                
        }
        
        let urlStringArray2 = pinnedNavigationState.webViews.compactMap { $0.url?.absoluteString }
            if let urlsData = try? JSONEncoder().encode(urlStringArray2){
            UserDefaults.standard.set(urlsData, forKey: "\(spaceName)pinnedTabs")
                
        }
        
        let urlStringArray3 = favoritesNavigationState.webViews.compactMap { $0.url?.absoluteString }
            if let urlsData = try? JSONEncoder().encode(urlStringArray3){
            UserDefaults.standard.set(urlsData, forKey: "\(spaceName)favoriteTabs")
                
        }
    }
    
    
    

    
    //MARK: - Functions
    func removeTab(at index: Int) {
        // If the deleted tab is the currently selected one
        if navigationState.selectedWebView == navigationState.webViews[index] {
            if navigationState.webViews.count > 1 { // Check if there's more than one tab
                if index == 0 { // If the first tab is being deleted, select the next one
                    navigationState.selectedWebView = navigationState.webViews[1]
                } else { // Otherwise, select the previous one
                    navigationState.selectedWebView = navigationState.webViews[index - 1]
                }
            } else { // If it's the only tab, set the selectedWebView to nil
                navigationState.selectedWebView = nil
            }
        }
        
        navigationState.webViews.remove(at: index)
    }
    
    func pinnedRemoveTab(at index: Int) {
        // If the deleted tab is the currently selected one
        if pinnedNavigationState.selectedWebView == pinnedNavigationState.webViews[index] {
            if pinnedNavigationState.webViews.count > 1 { // Check if there's more than one tab
                if index == 0 { // If the first tab is being deleted, select the next one
                    pinnedNavigationState.selectedWebView = pinnedNavigationState.webViews[1]
                } else { // Otherwise, select the previous one
                    pinnedNavigationState.selectedWebView = pinnedNavigationState.webViews[index - 1]
                }
            } else { // If it's the only tab, set the selectedWebView to nil
                pinnedNavigationState.selectedWebView = nil
            }
        }
        
        pinnedNavigationState.webViews.remove(at: index)
    }
    
    func favoriteRemoveTab(at index: Int) {
        // If the deleted tab is the currently selected one
        if favoritesNavigationState.selectedWebView == favoritesNavigationState.webViews[index] {
            if favoritesNavigationState.webViews.count > 1 { // Check if there's more than one tab
                if index == 0 { // If the first tab is being deleted, select the next one
                    favoritesNavigationState.selectedWebView = favoritesNavigationState.webViews[1]
                } else { // Otherwise, select the previous one
                    favoritesNavigationState.selectedWebView = favoritesNavigationState.webViews[index - 1]
                }
            } else { // If it's the only tab, set the selectedWebView to nil
                favoritesNavigationState.selectedWebView = nil
            }
        }
        
        favoritesNavigationState.webViews.remove(at: index)
    }
}



class CustomUITextField: UITextField {
    
    var onUpArrow: (() -> Void)?
    var onDownArrow: (() -> Void)?
    
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            guard let key = press.key else { continue }
            
            switch key.keyCode {
            case .keyboardUpArrow:
                onUpArrow?() // Trigger the action for up arrow key
                return
            case .keyboardDownArrow:
                onDownArrow?() // Trigger the action for down arrow key
                return
            default:
                break
            }
        }
        
        super.pressesBegan(presses, with: event)
    }
}

struct WebsiteSuggestion: Codable {
    var url: String
    var title: String
}


