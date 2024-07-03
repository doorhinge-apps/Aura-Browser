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
    @Environment(\.modelContext) var modelContext
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    
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
    
    var body: some View {
            VStack {
                // Sidebar Searchbar
                Button {
                    if ((variables.navigationState.currentURL?.absoluteString.isEmpty) == nil) && ((variables.pinnedNavigationState.currentURL?.absoluteString.isEmpty) == nil) && ((variables.favoritesNavigationState.currentURL?.absoluteString.isEmpty) == nil) {
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
                        
                        HStack {
                            //Text(unformatURL(url: selectedTabLocation == "tabs" ? variables.navigationState.selectedWebView?.url?.absoluteString ?? "": selectedTabLocation == "pinnedTabs" ? variables.pinnedNavigationState.selectedWebView?.url?.absoluteString ?? "": variables.favoritesNavigationState.selectedWebView?.url?.absoluteString ?? ""))
                            Text(searchInSidebar)
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
                    VGrid(variables.favoritesNavigationState.webViews, numberOfColumns: 4) { tab in
                            ZStack {
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
                        
                    }.padding(10)
                    
                    ForEach(0..<spaces[selectedSpaceIndex].pinnedUrls.count, id: \.self) { tabIndex in
                        //PinnedTab(reloadTitles: $reloadTitles, tab: tab, hoverTab: $hoverTab, faviconLoadingStyle: $faviconLoadingStyle, searchInSidebar: $searchInSidebar, hoverCloseTab: $hoverCloseTab, selectedTabLocation: $selectedTabLocation, draggedTab: $draggedTab, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState)
                        
                        ZStack {
                            if reloadTitles {
                                Color.white.opacity(0.0)
                            }
                            
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(Color(.white).opacity((tabIndex == manager.selectedTabIndex && manager.selectedTabLocation == .pinned) ? 0.5 : (manager.hoverTabIndex == tabIndex && manager.hoverTabLocation == .pinned) ? 0.2: 0.0001))
                                .frame(height: 50)
                            
                            HStack {
                                if faviconLoadingStyle {
                                    WebImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(spaces[selectedSpaceIndex].pinnedUrls[tabIndex])&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
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
                                    AsyncImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(spaces[selectedSpaceIndex].pinnedUrls[tabIndex])&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
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
                                
                                
                                Text(manager.linksWithTitles[spaces[selectedSpaceIndex].pinnedUrls[tabIndex]] ?? spaces[selectedSpaceIndex].pinnedUrls[tabIndex])
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
                                variables.browseForMeSearch = spaces[selectedSpaceIndex].pinnedUrls[tabIndex]
                                variables.isBrowseForMe = true
                            } label: {
                                Label("Browse for Me", systemImage: "globe.desk")
                            }
                #if !os(macOS)
                            Button {
                                UIPasteboard.general.string = spaces[selectedSpaceIndex].pinnedUrls[tabIndex]
                            } label: {
                                Label("Copy URL", systemImage: "link")
                            }
                            #endif
                            Button {
                                spaces[selectedSpaceIndex].pinnedUrls.insert(spaces[selectedSpaceIndex].pinnedUrls[tabIndex], at: tabIndex + 1)
                            } label: {
                                Label("Duplicate", systemImage: "plus.square.on.square")
                            }
                            
                            Button {
                                spaces[selectedSpaceIndex].tabUrls.append(spaces[selectedSpaceIndex].pinnedUrls[tabIndex])
                                
                                pinnedRemoveTab(at: tabIndex)
                                
                            } label: {
                                Label("Unpin", systemImage: "pin.fill")
                            }
                            
                            Button {
                                spaces[selectedSpaceIndex].favoritesUrls.append(spaces[selectedSpaceIndex].pinnedUrls[tabIndex])
                                
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
                            //variables.navigationState.selectedWebView = nil
                            //variables.navigationState.currentURL = nil
                            
                            //variables.favoritesNavigationState.selectedWebView = nil
                            //variables.favoritesNavigationState.currentURL = nil
                            
                            manager.selectedTabIndex = tabIndex
                            
                            manager.selectedTabLocation = .pinned
                            
//                            Task {
//                                await pinnedNavigationState.selectedWebView = tab
//                                await pinnedNavigationState.currentURL = tab.url
//                            }
                            
//                            if let unwrappedURL = spaces[selectedSpaceIndex].pinnedUrls[tabIndex] {
//                                searchInSidebar = unwrappedURL.absoluteString
//                            }
                            manager.selectOrAddWebView(urlString: spaces[selectedSpaceIndex].pinnedUrls[tabIndex])
                            
                            searchInSidebar = unformatURL(url: spaces[selectedSpaceIndex].pinnedUrls[tabIndex])
                        }
                        .onDrag {
                            self.manager.draggedIndex = tabIndex
                            return NSItemProvider(object: String(tabIndex) as NSString)
                        }
                        .onDrop(of: [.text], delegate: IndexDropViewDelegate(
                            destinationIndex: tabIndex,
                            allStrings: spaces[selectedSpaceIndex].pinnedUrls,
                            draggedIndex: $manager.draggedIndex,
                            onSuccessfulDrop: {
                                print("String moved successfully.")
                            }
                        ))
                    }
                    .onAppear() {
                        manager.fetchTitles(for: spaces[selectedSpaceIndex].pinnedUrls)
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
                                    
                                    Image(systemName: spaces[selectedSpaceIndex].spaceIcon)
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
                            
                            Text(!renameIsFocused ? spaces[selectedSpaceIndex].spaceName: temporaryRenameSpace)
                                .foregroundStyle(textColor)
                                .opacity(!renameIsFocused ? 1.0: 0)
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .onTapGesture {
                                    temporaryRenameSpace = spaces[selectedSpaceIndex].spaceName
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
                                        Label("Edit Theme", systemImage: "paintbrush.pointed")
                                    })
                                    
                                    Button(action: {
                                        temporaryRenameSpace = spaces[selectedSpaceIndex].spaceName
                                        temporaryRenameSpace = String(temporaryRenameSpace/*.dropLast(5)*/)
                                        renameIsFocused = true
                                    }, label: {
                                        Label("Rename Space", systemImage: "rectangle.and.pencil.and.ellipsis.rtl")
                                    })
                                    
                                    Button(action: {
                                        presentIcons.toggle()
                                    }, label: {
                                        Label("Change Space Icon", systemImage: spaces[selectedSpaceIndex].spaceIcon)
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
                            
                            if selectedSpaceIndex < spaces.count {
                                if !spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty {
                                    LinearGradient(colors: [Color(hex: spaces[selectedSpaceIndex].startHex), Color(hex: spaces[selectedSpaceIndex].endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                }
                            }
                            #endif
                            
                            //IconsPicker(currentIcon: $changingIcon)
                            IconsPicker(currentIcon: $changingIcon, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, selectedSpaceIndex: $selectedSpaceIndex)
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
                    
                    ForEach(variables.navigationState.webViews.reversed(), id: \.self) { tab in
                        TodayTab(reloadTitles: $reloadTitles, tab: tab, hoverTab: $hoverTab, faviconLoadingStyle: $faviconLoadingStyle, searchInSidebar: $searchInSidebar, hoverCloseTab: $hoverCloseTab, selectedTabLocation: $selectedTabLocation, draggedTab: $draggedTab, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState)
                    }
                }
                
                
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
    
    func saveSpaceData() {
        let savingTodayTabs = variables.navigationState.webViews.compactMap { $0.url?.absoluteString }
        let savingPinnedTabs = variables.pinnedNavigationState.webViews.compactMap { $0.url?.absoluteString }
        let savingFavoriteTabs = variables.favoritesNavigationState.webViews.compactMap { $0.url?.absoluteString }
        
        if !spaces.isEmpty {
            spaces[selectedSpaceIndex].tabUrls = savingTodayTabs
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
