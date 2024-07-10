//
//  SideabrWithSpaceParameter.swift
//  Aura
//
//  Created by Caedmon Myers on 10/7/24.
//

import Foundation
import SwiftUI
import SwiftData
import WebKit
import SDWebImageSwiftUI

struct SidebarSpaceParameter: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    
    @State var currentSelectedSpaceIndex: Int
    
    @EnvironmentObject var variables: ObservableVariables
    @EnvironmentObject var manager: WebsiteManager
    @StateObject var settings = SettingsVariables()
    
    @Binding var selectedTabLocation: String
    
    //@ObservedObject var navigationState: NavigationState
    //@ObservedObject var pinnedNavigationState: NavigationState
    //@ObservedObject var favoritesNavigationState: NavigationState
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
    
    @AppStorage("faviconShape") var faviconShape = "circle"
    
    @AppStorage("selectedSpaceIndex") var selectedSpaceIndex = 0
    
    @State var hoverPaintbrush = false
    
    @FocusState var renameIsFocused: Bool
    
    // Selection States
    @State private var changingIcon = ""
    @State private var draggedTab: WKWebView?
    
    @State private var textRect = CGRect()
    
    @State private var draggedItem: String?
    @State private var draggedItemIndex: Int?
    @State private var currentHoverIndex: Int?
    @State var reorderingTabs: [String] = []
    
    var body: some View {
            VStack {
                // Sidebar Searchbar
                Button {
//                    if ((variables.navigationState.currentURL?.absoluteString.isEmpty) == nil) && ((variables.pinnedNavigationState.currentURL?.absoluteString.isEmpty) == nil) && ((variables.favoritesNavigationState.currentURL?.absoluteString.isEmpty) == nil) {
//                        tabBarShown.toggle()
//                        commandBarShown = false
//                    }
//                    else {
//                        commandBarShown.toggle()
//                        tabBarShown = false
//                    }
                    if manager.selectedWebView != nil && manager.selectedTabLocation == .pinned {
                        tabBarShown = false
                        commandBarShown.toggle()
                    }
                    else if ((variables.navigationState.currentURL?.absoluteString.isEmpty) == nil) && ((variables.pinnedNavigationState.currentURL?.absoluteString.isEmpty) == nil) && ((variables.favoritesNavigationState.currentURL?.absoluteString.isEmpty) == nil) {
                        tabBarShown.toggle()
                        commandBarShown = false
                    }
                    else {
                        commandBarShown.toggle()
                        tabBarShown = false
                    }
                } label: {
                    ZStack {
#if !os(visionOS)
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(Color(.white).opacity(hoverSidebarSearchField ? 0.3 : 0.15))
                        #endif
                        
                        HStack(spacing: 0) {
                            if manager.selectedWebView != nil {
                                if manager.selectedWebView?.webView.hasOnlySecureContent ?? false {
                                    Image(systemName: "lock.fill")
                                        .foregroundStyle(Color.white)
                                        .font(.system(.body, design: .rounded, weight: .bold))
                                        .padding(.horizontal, 5)
                                }
                                else {
                                    Image(systemName: "lock.open.fill")
                                        .foregroundStyle(Color.red)
                                        .font(.system(.body, design: .rounded, weight: .bold))
                                        .padding(.horizontal, 5)
                                }
                            }
                            
                            //Text(unformatURL(url: selectedTabLocation == "tabs" ? variables.navigationState.selectedWebView?.url?.absoluteString ?? "": selectedTabLocation == "pinnedTabs" ? variables.pinnedNavigationState.selectedWebView?.url?.absoluteString ?? "": variables.favoritesNavigationState.selectedWebView?.url?.absoluteString ?? ""))
                            Text(unformatURL(url: searchInSidebar))
                                .padding(.leading, 5)
                                .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                                .lineLimit(1)
                            
                            Spacer()
                        }
                    }
                    .frame(height: 50)
                    .onHover(perform: { hovering in
                        if hovering {
                            hoverSidebarSearchField = true
                        }
                        else {
                            hoverSidebarSearchField = false
                        }
                    })
                }.buttonStyle(.plain)
                
                
                // Tabs
                ScrollView {
                    // Favorite Tabs
                    IntVGrid(itemCount: spaces[currentSelectedSpaceIndex].favoritesUrls.count, numberOfColumns: 4) { tabIndex in
                            /*ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(textColor.opacity(tab == variables.favoritesNavigationState.selectedWebView ? 1.0 : hoverTab == tab ? 0.6: 0.2), lineWidth: 3)
                                    .fill(textColor.opacity(tab == variables.favoritesNavigationState.selectedWebView ? 0.5 : hoverTab == tab ? 0.15: 0.0001))
                                    .frame(height: 75)
                                
                                if favoritesStyle {
                                    HStack {
                                        if tab.title == "" {
                                            Text(unformatURL(url: tab.url?.absoluteString ?? "Tab not found"))
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
                                                .cornerRadius(faviconShape == "square" ? 0: faviconShape == "squircle" ? 10: 100)
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
                                                .cornerRadius(faviconShape == "square" ? 0: faviconShape == "squircle" ? 10: 100)
                                            
                                        } placeholder: {
                                            LoadingAnimations(size: 35, borderWidth: 5.0)
                                        }
                                        
                                    }
                                }
                                
                            }
                            .contextMenu {
                                Button {
                                    variables.pinnedNavigationState.webViews.append(tab)
                                    
                                    if let index = variables.favoritesNavigationState.webViews.firstIndex(of: tab) {
                                        favoriteRemoveTab(at: index)
                                    }
                                } label: {
                                    Label("Pin Tab", systemImage: "pin")
                                }
                                
                                Button {
                                    variables.navigationState.webViews.append(tab)
                                    
                                    if let index = variables.favoritesNavigationState.webViews.firstIndex(of: tab) {
                                        favoriteRemoveTab(at: index)
                                    }
                                } label: {
                                    Label("Unfavorite", systemImage: "star.fill")
                                }
                                
                                Button {
                                    if let index = variables.favoritesNavigationState.webViews.firstIndex(of: tab) {
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
                                variables.navigationState.selectedWebView = nil
                                variables.navigationState.currentURL = nil
                                
                                variables.pinnedNavigationState.selectedWebView = nil
                                variables.pinnedNavigationState.currentURL = nil
                                
                                selectedTabLocation = "favoriteTabs"
                                
                                manager.selectedTabLocation = .favorites
                                
                                Task {
                                    await variables.favoritesNavigationState.selectedWebView = tab
                                    await variables.favoritesNavigationState.currentURL = tab.url
                                }
                                
                                if let unwrappedURL = tab.url {
                                    searchInSidebar = unwrappedURL.absoluteString
                                }
                            }
                            .onDrag {
                                self.draggedTab = tab
                                return NSItemProvider()
                            }
                            .onDrop(of: [.text], delegate: DropViewDelegate(destinationItem: tab, allTabs: $variables.favoritesNavigationState.webViews, draggedItem: $draggedTab))
                             */
                        
                        VStack {
                            ZStack {
                                if reloadTitles {
                                    Color.white.opacity(0.0)
                                }
                                
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                                    .fill(Color(.white).opacity((tabIndex == manager.selectedTabIndex && manager.selectedTabLocation == .favorites) ? 0.5 : (manager.hoverTabIndex == tabIndex && manager.hoverTabLocation == .favorites) ? 0.2: 0.0001))
                                    .frame(height: 75)
                                
                                if !favoritesStyle {
                                    if faviconLoadingStyle {
                                        WebImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(spaces[currentSelectedSpaceIndex].favoritesUrls[tabIndex])&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30, height: 30)
                                                .cornerRadius(faviconShape == "square" ? 0: faviconShape == "squircle" ? 5: 100)
                                                .padding(.leading, 5)
                                            
                                        } placeholder: {
                                            LoadingAnimations(size: 30, borderWidth: 5.0)
                                                .padding(.leading, 5)
                                        }
                                        .onSuccess { image, data, cacheType in
                                            
                                        }
                                        .indicator(.activity)
                                        .transition(.fade(duration: 0.5))
                                        .scaledToFit()
                                        
                                    } else {
                                        AsyncImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(spaces[currentSelectedSpaceIndex].favoritesUrls[tabIndex])&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30, height: 30)
                                                .cornerRadius(faviconShape == "square" ? 0: faviconShape == "squircle" ? 5: 100)
                                                .padding(.leading, 5)
                                            
                                        } placeholder: {
                                            LoadingAnimations(size: 30, borderWidth: 5.0)
                                                .padding(.leading, 5)
                                        }
                                    }
                                }
                                else {
                                    if spaces[currentSelectedSpaceIndex].favoritesUrls.count > tabIndex {
                                        Text(manager.linksWithTitles[spaces[currentSelectedSpaceIndex].favoritesUrls[tabIndex]] ?? spaces[currentSelectedSpaceIndex].favoritesUrls[tabIndex])
                                            .lineLimit(1)
                                            .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                                            .padding(.leading, 5)
                                            .onReceive(timer) { _ in
                                                reloadTitles.toggle()
                                            }
                                    }
                                }
                                
                            }
                            .contextMenu {
                                Button {
                                    variables.browseForMeSearch = spaces[currentSelectedSpaceIndex].favoritesUrls[tabIndex]
                                    variables.isBrowseForMe = true
                                } label: {
                                    Label("Browse for Me", systemImage: "globe.desk")
                                }
#if !os(macOS)
                                Button {
                                    UIPasteboard.general.string = spaces[currentSelectedSpaceIndex].favoritesUrls[tabIndex]
                                } label: {
                                    Label("Copy URL", systemImage: "link")
                                }
#endif
                                Button {
                                    var temporaryUrls = spaces[currentSelectedSpaceIndex].favoritesUrls
                                    temporaryUrls.insert(spaces[currentSelectedSpaceIndex].favoritesUrls[tabIndex], at: tabIndex + 1)
                                    
                                    spaces[currentSelectedSpaceIndex].favoritesUrls = temporaryUrls
                                } label: {
                                    Label("Duplicate", systemImage: "plus.square.on.square")
                                }
                                
                                Button {
                                    var temporaryUrls = spaces[currentSelectedSpaceIndex].pinnedUrls
                                    temporaryUrls.append(spaces[currentSelectedSpaceIndex].favoritesUrls[tabIndex])
                                    
                                    spaces[currentSelectedSpaceIndex].pinnedUrls = temporaryUrls
                                    
                                    favoriteRemoveTab(at: tabIndex)
                                    
                                } label: {
                                    Label("Pin", systemImage: "pin.fill")
                                }
                                
                                Button {
                                    var temporaryUrls = spaces[currentSelectedSpaceIndex].tabUrls
                                    temporaryUrls.append(spaces[currentSelectedSpaceIndex].favoritesUrls[tabIndex])
                                    
                                    spaces[currentSelectedSpaceIndex].tabUrls = temporaryUrls
                                    
                                    favoriteRemoveTab(at: tabIndex)
                                    
                                } label: {
                                    Label("Unfavorite", systemImage: "star")
                                }
                                
                                Button {
                                    favoriteRemoveTab(at: tabIndex)
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
                                    manager.hoverTabIndex = tabIndex
                                    manager.hoverTabLocation = .favorites
                                }
                                else {
                                    manager.hoverTabIndex = -1
                                }
                            })
                            .onTapGesture {
                                manager.selectedTabIndex = tabIndex
                                
                                manager.selectedTabLocation = .favorites
                                
                                manager.selectOrAddWebView(urlString: spaces[currentSelectedSpaceIndex].favoritesUrls[tabIndex])
                                
                                searchInSidebar = unformatURL(url: spaces[currentSelectedSpaceIndex].favoritesUrls[tabIndex])
                            }
                            .onDrag {
                                draggedItem = spaces[selectedSpaceIndex].favoritesUrls[tabIndex]
                                draggedItemIndex = tabIndex
                                reorderingTabs = spaces[selectedSpaceIndex].favoritesUrls
                                
                                manager.dragTabLocation = .favorites
                                
                                return NSItemProvider(object: spaces[selectedSpaceIndex].favoritesUrls[tabIndex] as NSString)
                            }
                        }
                        .background(
                            Color.white.opacity(0.0001)
                        )
                        .onDrop(of: [.text], delegate: IndexDropViewDelegate(
                            destinationIndex: tabIndex,
                            allItems: $reorderingTabs,
                            draggedItem: $draggedItem,
                            draggedItemIndex: $draggedItemIndex,
                            currentHoverIndex: $currentHoverIndex,
                            onDropAction: {
                                withAnimation {
                                    spaces[selectedSpaceIndex].favoritesUrls = reorderingTabs
                                }
                                
                                manager.selectedTabIndex = tabIndex
                                
                                currentHoverIndex = -1
                            }
                        ))
                        
                    }.padding(10)
                    
                    ForEach(0..<spaces[currentSelectedSpaceIndex].pinnedUrls.count, id: \.self) { tabIndex in
                        VStack {
                            if tabIndex < draggedItemIndex ?? 0 {
                                if currentHoverIndex == tabIndex && manager.dragTabLocation == .pinned {
                                    HStack(spacing: 0) {
                                        Circle()
                                            .stroke(Color(hex: "181F5B"), lineWidth: 2)
                                            .frame(height: 8)
                                        
                                        Color(hex: "181F5B")
                                            .frame(height: 2)
                                            .cornerRadius(10)
                                            .offset(x: -2)
                                    }.padding(.horizontal, 10)
                                }
                            }
                            ZStack {
                                if reloadTitles {
                                    Color.white.opacity(0.0)
                                }
                                
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(Color(.white).opacity((tabIndex == manager.selectedTabIndex && manager.selectedTabLocation == .pinned) ? 0.5 : (manager.hoverTabIndex == tabIndex && manager.hoverTabLocation == .pinned) ? 0.2: 0.0001))
                                    .frame(height: 50)
                                
                                HStack {
                                    if faviconLoadingStyle {
                                        WebImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(spaces[currentSelectedSpaceIndex].pinnedUrls[tabIndex])&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 25, height: 25)
                                                .cornerRadius(faviconShape == "square" ? 0: faviconShape == "squircle" ? 5: 100)
                                                .padding(.leading, 5)
                                            
                                        } placeholder: {
                                            LoadingAnimations(size: 25, borderWidth: 5.0)
                                                .padding(.leading, 5)
                                        }
                                        .onSuccess { image, data, cacheType in
                                            
                                        }
                                        .indicator(.activity)
                                        .transition(.fade(duration: 0.5))
                                        .scaledToFit()
                                        
                                    } else {
                                        AsyncImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(spaces[currentSelectedSpaceIndex].pinnedUrls[tabIndex])&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 25, height: 25)
                                                .cornerRadius(faviconShape == "square" ? 0: faviconShape == "squircle" ? 5: 100)
                                                .padding(.leading, 5)
                                            
                                        } placeholder: {
                                            LoadingAnimations(size: 25, borderWidth: 5.0)
                                                .padding(.leading, 5)
                                        }
                                    }
                                    
                                    
                                    Text(manager.linksWithTitles[spaces[currentSelectedSpaceIndex].pinnedUrls[tabIndex]] ?? spaces[currentSelectedSpaceIndex].pinnedUrls[tabIndex])
                                        .lineLimit(1)
                                        .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                                        .padding(.leading, 5)
                                        .onReceive(timer) { _ in
                                            reloadTitles.toggle()
                                        }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        pinnedRemoveTab(at: tabIndex)
                                    }) {
                                        if (manager.hoverTabIndex == tabIndex && manager.hoverTabLocation == .pinned) || (manager.selectedTabLocation == .pinned && manager.selectedTabIndex  == tabIndex) {
                                            ZStack {
#if !os(visionOS)
                                                Color(.white)
                                                    .opacity(manager.hoverCloseTabIndex == tabIndex ? 0.3: 0.0)
#endif
                                                Image(systemName: "xmark")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 15, height: 15)
                                                    .foregroundStyle(Color.white)
                                                    .opacity(manager.hoverCloseTabIndex == tabIndex ? 1.0: 0.8)
                                                
                                            }.frame(width: 35, height: 35)
                                                .onHover(perform: { hovering in
                                                    if hovering {
                                                        manager.hoverCloseTabIndex = tabIndex
                                                        manager.hoverTabLocation = .pinned
                                                    }
                                                    else {
                                                        manager.hoverCloseTabIndex = -1
                                                    }
                                                })
#if !os(visionOS) && !os(macOS)
                                                .cornerRadius(7)
                                                .padding(.trailing, 10)
                                                .hoverEffect(.lift)
#endif
                                            
                                        }
                                    }.buttonStyle(.plain)
                                }
                            }
                            .contextMenu {
                                Button {
                                    variables.browseForMeSearch = spaces[currentSelectedSpaceIndex].pinnedUrls[tabIndex]
                                    variables.isBrowseForMe = true
                                } label: {
                                    Label("Browse for Me", systemImage: "globe.desk")
                                }
#if !os(macOS)
                                Button {
                                    UIPasteboard.general.string = spaces[currentSelectedSpaceIndex].pinnedUrls[tabIndex]
                                } label: {
                                    Label("Copy URL", systemImage: "link")
                                }
#endif
                                Button {
                                    var temporaryUrls = spaces[currentSelectedSpaceIndex].pinnedUrls
                                    temporaryUrls.insert(spaces[currentSelectedSpaceIndex].pinnedUrls[tabIndex], at: tabIndex + 1)
                                    
                                    spaces[currentSelectedSpaceIndex].pinnedUrls = temporaryUrls
                                } label: {
                                    Label("Duplicate", systemImage: "plus.square.on.square")
                                }
                                
                                Button {
                                    var temporaryUrls = spaces[currentSelectedSpaceIndex].tabUrls
                                    temporaryUrls.append(spaces[currentSelectedSpaceIndex].pinnedUrls[tabIndex])
                                    
                                    spaces[currentSelectedSpaceIndex].tabUrls = temporaryUrls
                                    
                                    pinnedRemoveTab(at: tabIndex)
                                    
                                } label: {
                                    Label("Unpin", systemImage: "pin.fill")
                                }
                                
                                Button {
                                    var temporaryUrls = spaces[currentSelectedSpaceIndex].favoritesUrls
                                    temporaryUrls.append(spaces[currentSelectedSpaceIndex].pinnedUrls[tabIndex])
                                    
                                    spaces[currentSelectedSpaceIndex].favoritesUrls = temporaryUrls
                                    
                                    pinnedRemoveTab(at: tabIndex)
                                    
                                } label: {
                                    Label("Favorite", systemImage: "star")
                                }
                                
                                Button {
                                    pinnedRemoveTab(at: tabIndex)
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
                                    manager.hoverTabIndex = tabIndex
                                    manager.hoverTabLocation = .pinned
                                }
                                else {
                                    manager.hoverTabIndex = -1
                                }
                            })
                            .onTapGesture {
                                manager.selectedTabIndex = tabIndex
                                
                                manager.selectedTabLocation = .pinned
                                
                                manager.selectOrAddWebView(urlString: spaces[currentSelectedSpaceIndex].pinnedUrls[tabIndex])
                                
                                searchInSidebar = unformatURL(url: spaces[currentSelectedSpaceIndex].pinnedUrls[tabIndex])
                            }
                            .onDrag {
                                draggedItem = spaces[selectedSpaceIndex].pinnedUrls[tabIndex]
                                draggedItemIndex = tabIndex
                                reorderingTabs = spaces[selectedSpaceIndex].pinnedUrls
                                
                                manager.dragTabLocation = .pinned
                                
                                //currentHoverIndex = -1
                                
                                return NSItemProvider(object: spaces[selectedSpaceIndex].pinnedUrls[tabIndex] as NSString)
                            }
                            
                            if tabIndex > draggedItemIndex ?? 0 {
                            //if tabIndex != draggedItemIndex {
                                if currentHoverIndex == tabIndex && manager.dragTabLocation == .pinned {
                                    HStack(spacing: 0) {
                                        Circle()
                                            .stroke(Color(hex: "181F5B"), lineWidth: 2)
                                            .frame(height: 8)
                                        
                                        Color(hex: "181F5B")
                                            .frame(height: 2)
                                            .cornerRadius(10)
                                            .offset(x: -2)
                                    }.padding(.horizontal, 10)
                                }
                            }
                        }
                        .background(
                            Color.white.opacity(0.0001)
                        )
                        .onDrop(of: [.text], delegate: IndexDropViewDelegate(
                            destinationIndex: tabIndex,
                            allItems: $reorderingTabs,
                            draggedItem: $draggedItem,
                            draggedItemIndex: $draggedItemIndex,
                            currentHoverIndex: $currentHoverIndex,
                            onDropAction: {
                                withAnimation {
                                    spaces[selectedSpaceIndex].pinnedUrls = reorderingTabs
                                }
                                currentHoverIndex = -1
                            }
                        ))                    }
                    .onAppear() {
                        manager.fetchTitles(for: spaces[currentSelectedSpaceIndex].pinnedUrls)
                    }
                    
                    ZStack {
                        HStack {
                            Spacer()
                                .frame(width: 50, height: 40)
                            
                            ZStack {
                                TextField("", text: $temporaryRenameSpace)
                                    .textFieldStyle(.plain)
                                    .foregroundStyle(textColor)
                                    .opacity(renameIsFocused ? 0.75: 0)
                                    .tint(Color.white)
                                    .font(.system(.caption, design: .rounded, weight: .medium))
                                    .focused($renameIsFocused)
                                    .onSubmit {
                                        spaces[selectedSpaceIndex].spaceName = temporaryRenameSpace
                                        
                                        Task {
                                            do {
                                                try await modelContext.save()
                                            }
                                            catch {
                                                print(error.localizedDescription)
                                            }
                                        }
                                        
                                        temporaryRenameSpace = ""
                                    }
                                
                            }
                            
                        }
                        
                        HStack {
                            Button {
                                presentIcons.toggle()
                            } label: {
                                ZStack {
                                    HoverButtonDisabledVision(hoverInteraction: $spaceIconHover)
                                    
                                    Image(systemName: spaces[currentSelectedSpaceIndex].spaceIcon)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(textColor)
                                        .opacity(spaceIconHover ? 1.0: 0.5)
                                    
                                }.frame(width: 40, height: 40).cornerRadius(7)
#if !os(visionOS) && !os(macOS)
                                    .hoverEffect(.lift)
                                    .hoverEffectDisabled(!hoverEffectsAbsorbCursor)
                                #endif
                                    .onHover(perform: { hovering in
                                        if hovering {
                                            spaceIconHover = true
                                        }
                                        else {
                                            spaceIconHover = false
                                        }
                                    })
                            }.buttonStyle(.plain)
                            
                            Text(!renameIsFocused ? spaces[currentSelectedSpaceIndex].spaceName: temporaryRenameSpace)
                                .foregroundStyle(textColor)
                                .opacity(!renameIsFocused ? 1.0: 0)
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .onTapGesture {
                                    temporaryRenameSpace = spaces[currentSelectedSpaceIndex].spaceName
                                    temporaryRenameSpace = String(temporaryRenameSpace/*.dropLast(5)*/)
                                    renameIsFocused = true
                                }
#if !os(visionOS) && !os(macOS)
                                .hoverEffect(.lift)
                            #endif
                            
                            if renameIsFocused {
                                Button(action: {
                                    renameIsFocused = false
                                }, label: {
                                    Image(systemName: "checkmark.circle.fill")
                                        .frame(height: 20)
                                        .foregroundStyle(Color.white)
                                        .opacity(0.5)
                                })
#if !os(visionOS) && !os(macOS)
                                .hoverEffect(.lift)
                                    .hoverEffectDisabled(!hoverEffectsAbsorbCursor)
                                #endif
                            }
                            
                            textColor
                                .opacity(0.5)
                                .frame(height: 1)
                                .cornerRadius(10)
                            
                            
                            Menu {
                                VStack {
                                    Button(action: {
                                        changeColorSheet.toggle()
                                    }, label: {
                                        Label("Edit Theme", systemImage: "paintpalette")
                                    })
                                    
                                    Button(action: {
                                        withAnimation {
                                            variables.boostEditor.toggle()
                                        }
                                    }, label: {
                                        Label("Boost Editor", systemImage: "paintbrush")
                                    })
                                    
                                    Button(action: {
                                        temporaryRenameSpace = spaces[currentSelectedSpaceIndex].spaceName
                                        temporaryRenameSpace = String(temporaryRenameSpace/*.dropLast(5)*/)
                                        renameIsFocused = true
                                    }, label: {
                                        Label("Rename Space", systemImage: "rectangle.and.pencil.and.ellipsis.rtl")
                                    })
                                    
                                    Button(action: {
                                        presentIcons.toggle()
                                    }, label: {
                                        Label("Change Space Icon", systemImage: spaces[currentSelectedSpaceIndex].spaceIcon)
                                    })
                                }
                            } label: {
                                ZStack {
                                    HoverButtonDisabledVision(hoverInteraction: $hoverPaintbrush)
                                    
                                    Image(systemName: "ellipsis")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 25)
                                        .foregroundStyle(textColor)
                                        .opacity(hoverPaintbrush ? 1.0: 0.5)
                                    
                                }.frame(width: 40, height: 40).cornerRadius(7)
                            }
#if !os(visionOS) && !os(macOS)
                            .hoverEffect(.lift)
                                .hoverEffectDisabled(!hoverEffectsAbsorbCursor)
                            #endif
                                .onHover(perform: { hovering in
                                    if hovering {
                                        hoverPaintbrush = true
                                    }
                                    else {
                                        hoverPaintbrush = false
                                    }
                                })
                            
                            
                        }
                    }
                    .padding(.vertical, 10)
                    .popover(isPresented: $changeColorSheet, attachmentAnchor: .point(.trailing), arrowEdge: .leading, content: {
                        VStack(spacing: 20) {
                            ZStack {
                                LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .bottomLeading, endPoint: .topTrailing)
                                    .frame(width: 250, height: 200)
                                    .ignoresSafeArea()
                                    .offset(x: -10)
                            }.frame(width: 200, height: 200)
                            
                            VStack {
                                ColorPicker("Start Color", selection: $startColor)
                                    .onChange(of: startColor) { newValue in
                                        //saveColor(color: newValue, key: "startColorHex")
                                        
                                        let uiColor1 = UIColor(newValue)
                                        let hexString1 = uiColor1.toHex()
                                        
                                        spaces[selectedSpaceIndex].startHex = hexString1 ?? "858585"
                                    }
                                
                                ColorPicker("End Color", selection: $endColor)
                                    .onChange(of: endColor) { newValue in
                                        //saveColor(color: newValue, key: "endColorHex")
                                        
                                        let uiColor2 = UIColor(newValue)
                                        let hexString2 = uiColor2.toHex()
                                        
                                        spaces[selectedSpaceIndex].endHex = hexString2 ?? "ADADAD"
                                    }
                                
                                ColorPicker("Text Color", selection: $textColor)
                                    .onChange(of: textColor) { newValue in
                                        saveColor(color: newValue, key: "textColorHex")
                                    }
                            }
                            .padding()
                            
                            Spacer()
                        }
                        
                    })
                    .popover(isPresented: $presentIcons, attachmentAnchor: .point(.trailing), arrowEdge: .leading) {
                        ZStack {
#if !os(visionOS)
                            LinearGradient(colors: [startColor, endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                .opacity(1.0)
                            
                            if currentSelectedSpaceIndex < spaces.count {
                                if !spaces[currentSelectedSpaceIndex].startHex.isEmpty && !spaces[currentSelectedSpaceIndex].endHex.isEmpty {
                                    LinearGradient(colors: [Color(hex: spaces[currentSelectedSpaceIndex].startHex), Color(hex: spaces[currentSelectedSpaceIndex].endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                }
                            }
                            #endif
                            
                            //IconsPicker(currentIcon: $changingIcon)
                            IconsPicker(currentIcon: $changingIcon, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, selectedSpaceIndex: $currentSelectedSpaceIndex)
                                .onChange(of: changingIcon) {
                                    spaces[selectedSpaceIndex].spaceIcon = changingIcon
                                    do {
                                        try modelContext.save()
                                    }
                                    catch {
                                        
                                    }
                                }
                                .onDisappear() {
                                    changingIcon = ""
                                }
                        }
                    }
                    
                    Button {
                        tabBarShown.toggle()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(Color(.white).opacity(hoverNewTabSection ? 0.5: 0.0))
                                .frame(height: 50)
                            HStack {
                                Label("New Tab", systemImage: "plus")
                                    .foregroundStyle(textColor)
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
                    }.buttonStyle(.plain)
                    .onAppear() {
                        if settings.commandBarOnLaunch {
                            tabBarShown = true
                        }
                    }
                    .onChange(of: manager.selectedWebView?.webView.url?.absoluteString ?? "") {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                            let newUrl = manager.selectedWebView?.webView.url?.absoluteString ?? ""
                            searchInSidebar = newUrl
                            
                            if manager.selectedTabLocation == .pinned {
                                spaces[selectedSpaceIndex].pinnedUrls[manager.selectedTabIndex] = newUrl
                            }
                            else if manager.selectedTabLocation == .tabs {
                                spaces[selectedSpaceIndex].tabUrls[manager.selectedTabIndex] = newUrl
                            }
                            else if manager.selectedTabLocation == .favorites {
                                spaces[selectedSpaceIndex].favoritesUrls[manager.selectedTabIndex] = newUrl
                            }
                            
                            let fetchTitlesArrays = spaces[selectedSpaceIndex].tabUrls + spaces[selectedSpaceIndex].pinnedUrls + spaces[selectedSpaceIndex].favoritesUrls
                            
                            manager.fetchTitlesIfNeeded(for: fetchTitlesArrays)
                        })
                    }
                    
                    ForEach(Array(stride(from: spaces[currentSelectedSpaceIndex].tabUrls.count-1, through: 0, by: -1)), id: \.self) { tabIndex in
                    //ForEach(0..<spaces[currentSelectedSpaceIndex].tabUrls.count, id: \.self) { tabIndex in
                        VStack {
                            
                            if tabIndex > draggedItemIndex ?? 0 {
                                if currentHoverIndex == tabIndex && manager.dragTabLocation == .tabs {
                                    HStack(spacing: 0) {
                                        Circle()
                                            .stroke(Color(hex: "181F5B"), lineWidth: 2)
                                            .frame(height: 8)
                                        
                                        Color(hex: "181F5B")
                                            .frame(height: 2)
                                            .cornerRadius(10)
                                            .offset(x: -2)
                                    }.padding(.horizontal, 10)
                                }
                            }
                            ZStack {
                                if reloadTitles {
                                    Color.white.opacity(0.0)
                                }
                                
                                RoundedRectangle(cornerRadius: 20)
                                    .foregroundStyle(Color(.white).opacity((tabIndex == manager.selectedTabIndex && manager.selectedTabLocation == .tabs) ? 0.5 : (manager.hoverTabIndex == tabIndex && manager.hoverTabLocation == .tabs) ? 0.2: 0.0001))
                                    .frame(height: 50)
                                
                                HStack {
                                    if faviconLoadingStyle {
                                        WebImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(spaces[currentSelectedSpaceIndex].tabUrls[tabIndex])&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 25, height: 25)
                                                .cornerRadius(faviconShape == "square" ? 0: faviconShape == "squircle" ? 5: 100)
                                                .padding(.leading, 5)
                                            
                                        } placeholder: {
                                            LoadingAnimations(size: 25, borderWidth: 5.0)
                                                .padding(.leading, 5)
                                        }
                                        .onSuccess { image, data, cacheType in
                                            
                                        }
                                        .indicator(.activity)
                                        .transition(.fade(duration: 0.5))
                                        .scaledToFit()
                                        
                                    } else {
                                        AsyncImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(spaces[currentSelectedSpaceIndex].tabUrls[tabIndex])&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 25, height: 25)
                                                .cornerRadius(faviconShape == "square" ? 0: faviconShape == "squircle" ? 5: 100)
                                                .padding(.leading, 5)
                                            
                                        } placeholder: {
                                            LoadingAnimations(size: 25, borderWidth: 5.0)
                                                .padding(.leading, 5)
                                        }
                                    }
                                    
                                    
                                    Text(manager.linksWithTitles[spaces[currentSelectedSpaceIndex].tabUrls[tabIndex]] ?? spaces[currentSelectedSpaceIndex].tabUrls[tabIndex])
                                        .lineLimit(1)
                                        .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                                        .padding(.leading, 5)
                                        .onReceive(timer) { _ in
                                            reloadTitles.toggle()
                                        }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        removeTab(at: tabIndex)
                                    }) {
                                        if (manager.hoverTabIndex == tabIndex && manager.hoverTabLocation == .tabs) || (manager.selectedTabLocation == .tabs && manager.selectedTabIndex  == tabIndex) {
                                            ZStack {
#if !os(visionOS)
                                                Color(.white)
                                                    .opacity(manager.hoverCloseTabIndex == tabIndex ? 0.3: 0.0)
#endif
                                                Image(systemName: "xmark")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 15, height: 15)
                                                    .foregroundStyle(Color.white)
                                                    .opacity(manager.hoverCloseTabIndex == tabIndex ? 1.0: 0.8)
                                                
                                            }.frame(width: 35, height: 35)
                                                .onHover(perform: { hovering in
                                                    if hovering {
                                                        manager.hoverCloseTabIndex = tabIndex
                                                        manager.hoverTabLocation = .tabs
                                                    }
                                                    else {
                                                        manager.hoverCloseTabIndex = -1
                                                    }
                                                })
#if !os(visionOS) && !os(macOS)
                                                .cornerRadius(7)
                                                .padding(.trailing, 10)
                                                .hoverEffect(.lift)
#endif
                                            
                                        }
                                    }.buttonStyle(.plain)
                                }
                            }
                            .contextMenu {
                                Button {
                                    variables.browseForMeSearch = spaces[currentSelectedSpaceIndex].tabUrls[tabIndex]
                                    variables.isBrowseForMe = true
                                } label: {
                                    Label("Browse for Me", systemImage: "globe.desk")
                                }
#if !os(macOS)
                                Button {
                                    UIPasteboard.general.string = spaces[currentSelectedSpaceIndex].tabUrls[tabIndex]
                                } label: {
                                    Label("Copy URL", systemImage: "link")
                                }
#endif
                                Button {
                                    var temporaryUrls = spaces[currentSelectedSpaceIndex].tabUrls
                                    temporaryUrls.insert(spaces[currentSelectedSpaceIndex].tabUrls[tabIndex], at: tabIndex + 1)
                                    
                                    spaces[currentSelectedSpaceIndex].tabUrls = temporaryUrls
                                } label: {
                                    Label("Duplicate", systemImage: "plus.square.on.square")
                                }
                                
                                Button {
                                    var temporaryUrls = spaces[currentSelectedSpaceIndex].pinnedUrls
                                    temporaryUrls.append(spaces[currentSelectedSpaceIndex].tabUrls[tabIndex])
                                    
                                    spaces[currentSelectedSpaceIndex].pinnedUrls = temporaryUrls
                                    
                                    removeTab(at: tabIndex)
                                    
                                } label: {
                                    Label("Pin", systemImage: "pin.fill")
                                }
                                
                                Button {
                                    var temporaryUrls = spaces[currentSelectedSpaceIndex].favoritesUrls
                                    temporaryUrls.append(spaces[currentSelectedSpaceIndex].tabUrls[tabIndex])
                                    
                                    spaces[currentSelectedSpaceIndex].favoritesUrls = temporaryUrls
                                    
                                    removeTab(at: tabIndex)
                                    
                                } label: {
                                    Label("Favorite", systemImage: "star")
                                }
                                
                                Button {
                                    removeTab(at: tabIndex)
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
                                    manager.hoverTabIndex = tabIndex
                                    manager.hoverTabLocation = .tabs
                                }
                                else {
                                    manager.hoverTabIndex = -1
                                }
                            })
                            .onTapGesture {
                                //variables.navigationState.selectedWebView = nil
                                //variables.navigationState.currentURL = nil
                                
                                //variables.favoritesNavigationState.selectedWebView = nil
                                //variables.favoritesNavigationState.currentURL = nil
                                
                                manager.selectedTabIndex = tabIndex
                                
                                manager.selectedTabLocation = .tabs
                                
                                //                            Task {
                                //                                await pinnedNavigationState.selectedWebView = tab
                                //                                await pinnedNavigationState.currentURL = tab.url
                                //                            }
                                
                                //                            if let unwrappedURL = spaces[currentSelectedSpaceIndex].pinnedUrls[tabIndex] {
                                //                                searchInSidebar = unwrappedURL.absoluteString
                                //                            }
                                manager.selectOrAddWebView(urlString: spaces[currentSelectedSpaceIndex].tabUrls[tabIndex])
                                
                                searchInSidebar = unformatURL(url: spaces[currentSelectedSpaceIndex].tabUrls[tabIndex])
                            }
                            .onDrag {
                                draggedItem = spaces[selectedSpaceIndex].tabUrls[tabIndex]
                                draggedItemIndex = tabIndex
                                reorderingTabs = spaces[selectedSpaceIndex].tabUrls
                                
                                manager.dragTabLocation = .tabs
                                
                                //currentHoverIndex = -1
                                
                                return NSItemProvider(object: spaces[selectedSpaceIndex].tabUrls[tabIndex] as NSString)
                            }
                            
                            if tabIndex < draggedItemIndex ?? 0 {
                            //if tabIndex != draggedItemIndex {
                                if currentHoverIndex == tabIndex && manager.dragTabLocation == .tabs {
                                    HStack(spacing: 0) {
                                        Circle()
                                            .stroke(Color(hex: "181F5B"), lineWidth: 2)
                                            .frame(height: 8)
                                        
                                        Color(hex: "181F5B")
                                            .frame(height: 2)
                                            .cornerRadius(10)
                                            .offset(x: -2)
                                    }.padding(.horizontal, 10)
                                }
                            }
                        }
                        .background(
                            Color.white.opacity(0.0001)
                        )
                        .onDrop(of: [.text], delegate: IndexDropViewDelegate(
                            destinationIndex: tabIndex,
                            allItems: $reorderingTabs,
                            draggedItem: $draggedItem,
                            draggedItemIndex: $draggedItemIndex,
                            currentHoverIndex: $currentHoverIndex,
                            onDropAction: {
                                withAnimation {
                                    spaces[selectedSpaceIndex].tabUrls = reorderingTabs
                                }
                                currentHoverIndex = -1
                            }
                        ))
                    }
                    .onAppear() {
                        manager.fetchTitles(for: spaces[currentSelectedSpaceIndex].tabUrls)
                    }
                }
                
                
            }
    }
    
    func favoriteRemoveTab(at index: Int) {
        var temporaryUrls = spaces[currentSelectedSpaceIndex].favoritesUrls
        
        if index == manager.selectedTabIndex && manager.selectedTabLocation == .favorites {
            if temporaryUrls.count > 1 { // Check if there's more than one tab
                if index == 0 { // If the first tab is being deleted, select the next one
                    manager.selectedTabIndex = 1
                } else { // Otherwise, select the previous one
                    manager.selectedTabIndex = index - 1
                }
            } else { // If it's the only tab, set the selectedWebView to nil
                manager.selectedWebView = nil
                manager.selectedTabIndex = -1
            }
        }
        
        temporaryUrls.remove(at: index)
        
        spaces[currentSelectedSpaceIndex].favoritesUrls = temporaryUrls
        
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func pinnedRemoveTab(at index: Int) {
        var temporaryUrls = spaces[currentSelectedSpaceIndex].pinnedUrls
        
        temporaryUrls.remove(at: index)
        
        spaces[currentSelectedSpaceIndex].pinnedUrls = temporaryUrls
        
        if index == manager.selectedTabIndex && manager.selectedTabLocation == .pinned {
            if temporaryUrls.count > 1 { // Check if there's more than one tab
                if index == 0 { // If the first tab is being deleted, select the next one
                    manager.selectedTabIndex = 1
                } else { // Otherwise, select the previous one
                    manager.selectedTabIndex = index - 1
                }
            } else { // If it's the only tab, set the selectedWebView to nil
                manager.selectedWebView = nil
                manager.selectedTabIndex = -1
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeTab(at index: Int) {
        var temporaryUrls = spaces[currentSelectedSpaceIndex].tabUrls
        
        print("Removing Tab:")
        print(temporaryUrls)
        
        temporaryUrls.remove(at: index)
        
        print(temporaryUrls)
        
        spaces[currentSelectedSpaceIndex].tabUrls = temporaryUrls
        
        print(spaces[currentSelectedSpaceIndex].tabUrls)
        
        if index == manager.selectedTabIndex && manager.selectedTabLocation == .tabs {
            if temporaryUrls.count > 1 { // Check if there's more than one tab
                if index == 0 { // If the first tab is being deleted, select the next one
                    manager.selectedTabIndex = 1
                } else { // Otherwise, select the previous one
                    manager.selectedTabIndex = index - 1
                }
            } else { // If it's the only tab, set the selectedWebView to nil
                manager.selectedWebView = nil
                manager.selectedTabIndex = -1
            }
        }
//        if manager.selectedTabIndex > spaces[currentSelectedSpaceIndex].tabUrls.count {
//            manager.selectedTabIndex = spaces[currentSelectedSpaceIndex].tabUrls.count-1
//        }
        
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
        print("Done")
        
        //saveSpaceData()
    }
    
    func saveSpaceData() {
        let savingTodayTabs = variables.navigationState.webViews.compactMap { $0.url?.absoluteString }
        let savingPinnedTabs = variables.pinnedNavigationState.webViews.compactMap { $0.url?.absoluteString }
        let savingFavoriteTabs = variables.favoritesNavigationState.webViews.compactMap { $0.url?.absoluteString }
        
        if !spaces.isEmpty {
            spaces[currentSelectedSpaceIndex].tabUrls = savingTodayTabs
        }
        else {
            modelContext.insert(SpaceStorage(spaceIndex: spaces.count, spaceName: "Untitled", spaceIcon: "circle.fill", favoritesUrls: [], pinnedUrls: [], tabUrls: savingTodayTabs))
        }
        
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /*func saveToLocalStorage2(spaceName: String) {
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
    }*/
}
