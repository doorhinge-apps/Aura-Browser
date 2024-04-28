//
//  Sidebar.swift
//  Aura
//
//  Created by Quinn O'Donnell on 4/27/24.
//

import Foundation
import SwiftUI
import SwiftData
import WebKit
import SDWebImageSwiftUI

struct Sidebar: View {
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
    @Binding var hoverSpace: String
    var geo: GeometryProxy
    
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
    
    @State private var startHex = "ffffff"
    @State private var endHex = "000000"
    
    @State private var presentIcons = false
    
    // Hover Effects
    @State private var hoverSidebarSearchField = false
    
    @State private var hoverCloseTab = WKWebView()
    
    @State private var spaceIconHover = false
    
    @State private var settingsButtonHover = false
    @State private var hoverNewTabSection = false
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = true
    @AppStorage("favoritesStyle") var favoritesStyle = false
    @AppStorage("faviconLoadingStyle") var faviconLoadingStyle = false
    
    // Selection States
    @State private var changingIcon = ""
    @State private var draggedTab: WKWebView?
    
    var body: some View {
        VStack {
            ToolbarButtonsView(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, geo: geo).frame(height: 40)
            
            // Sidebar Searchbar
            Button {
                if ((navigationState.currentURL?.absoluteString.isEmpty) == nil) && ((pinnedNavigationState.currentURL?.absoluteString.isEmpty) == nil) && ((favoritesNavigationState.currentURL?.absoluteString.isEmpty) == nil) {
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
            
            // Favorite Tabs
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
            
            // Tabs
            ScrollView {
                ForEach(pinnedNavigationState.webViews, id: \.self) { tab in
                    ZStack {
                        if reloadTitles {
                            Color.white.opacity(0.0)
                        }
                        
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(Color(.white).opacity(tab == pinnedNavigationState.selectedWebView ? 0.5 : hoverTab == tab ? 0.2: 0.0001))
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
                    
                }
                .padding(.vertical, 10)
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
                    ZStack {
                        if reloadTitles {
                            Color.white.opacity(0.0)
                        }
                        
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(Color(.white).opacity(tab == navigationState.selectedWebView ? 0.5 : hoverTab == tab ? 0.2: 0.0))
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
}
