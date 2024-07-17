//
//  SideabrSpaceParameter.swift
//  Aura
//
//  Created by Reyna Myers on 10/7/24.
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
    @EnvironmentObject var settings: SettingsVariables
    
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
    
    @State var pdfData: Data? = nil
    
    var body: some View {
            VStack {
                // Sidebar Searchbar
                Button {
                    if manager.selectedWebView != nil {
                        variables.tabBarShown = false
                        variables.commandBarShown.toggle()
                    }
                    else {
                        variables.commandBarShown.toggle()
                        variables.tabBarShown = false
                    }
                } label: {
                    ZStack {
#if !os(visionOS)
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.white).opacity(hoverSidebarSearchField ? 0.3 : 0.15))
                            .stroke(Color.white.opacity(hoverSidebarSearchField ? 0.8: 0.0), lineWidth: 2)
                        #endif
                        
                        HStack(spacing: 0) {
                            if manager.selectedWebView != nil {
                                if manager.selectedWebView?.webView.hasOnlySecureContent ?? false {
                                    Menu(content: {
                                        Label("Secure", systemImage: "lock.fill")
                                    }, label: {
                                        Image(systemName: "lock.fill")
                                            .foregroundStyle(Color.white)
                                            .font(.system(.body, design: .rounded, weight: .semibold))
                                            .hoverEffect(.highlight)
                                            .padding(.horizontal, 5)
                                            .padding(.leading, 5)
                                    })
                                }
                                else {
                                    Menu(content: {
                                        Label("Not Secure", systemImage: "lock.open.fill")
                                    }, label: {
                                        Image(systemName: "lock.open.fill")
                                            .foregroundStyle(Color.red)
                                            .font(.system(.body, design: .rounded, weight: .semibold))
                                            .hoverEffect(.highlight)
                                            .padding(.horizontal, 5)
                                            .padding(.leading, 5)
                                    })
                                }
                            }
                            
                            if unformatURL(url: variables.searchInSidebar).isEmpty {
                                Text("Search or Enter URL")
                                    .padding(.leading, 5)
                                    .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                                    .opacity(0.8)
                                    .lineLimit(1)
                            }
                            else {
                                Text(unformatURL(url: variables.searchInSidebar))
                                    .padding(.leading, 5)
                                    .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            if manager.selectedWebView != nil {
                                Menu(content: {
                                    ControlGroup {
                                        Button(action: {
                                            UIPasteboard.general.string = manager.selectedWebView?.webView.url?.absoluteString ?? ""
                                        }, label: {
                                            Label("Copy Url", systemImage: "link")
                                        })
                                        
                                        #if !os(visionOS)
                                        ShareLink(item: manager.selectedWebView?.webView.url?.absoluteURL ?? URL("")!, label: {
                                            Label("Share", systemImage: "square.and.arrow.up")
                                        })
                                        #endif
                                    }
                                    
                                    Button(action: {
                                        withAnimation {
                                            variables.boostEditor.toggle()
                                        }
                                    }, label: {
                                        Label("Boost Editor", systemImage: "paintbrush")
                                    })
                                    
                                    
                                    Button(action: {
                                        if variables.boosts.disabledBoosts.contains(unformatPlainURL(url: manager.selectedWebView?.webView.url?.absoluteString ?? "")) {
                                            variables.boosts.enableBoost(unformatPlainURL(url: manager.selectedWebView?.webView.url?.absoluteString ?? ""))
                                        }
                                        else {
                                            variables.boosts.disableBoost(unformatPlainURL(url: manager.selectedWebView?.webView.url?.absoluteString ?? ""))
                                        }
                                    }, label: {
                                        if variables.boosts.disabledBoosts.contains(unformatPlainURL(url: manager.selectedWebView?.webView.url?.absoluteString ?? "")) {
                                            Label("Enable Boost", systemImage: "paintbrush.pointed.fill")
                                        }
                                        else {
                                            Label("Disable Boost", systemImage: "paintbrush.pointed")
                                        }
                                    })
                                    
                                    /*Button(action: {
                                        
                                    }, label: {
                                        Label("Save as PDF", systemImage: "arrow.down.document")
                                    })
                                    
                                    ShareLink(items: pdfData!, label: {
                                        Label("Save as PDF", systemImage: "arrow.down.document")
                                    })
                                    .onAppear() {
                                        let pdfConfiguration = WKPDFConfiguration()
                                        
                                                pdfConfiguration.rect = CGRect(x: 0, y: 0, width: manager.selectedWebView?.webView.scrollView.contentSize.width, height: manager.selectedWebView?.webView.scrollView.contentSize.height)

                                        manager.selectedWebView?.webView.createPDF(configuration: pdfConfiguration) { result in
                                                    switch result {
                                                    case .success(let data):
                                                        guard let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
                                                            return
                                                        }

                                                        pdfData = data
                                                        
                                                        do {
                                                            let savePath = downloadsDirectory.appendingPathComponent(manager.selectedWebView?.webView?.url?.absoluteString ?? "PDF").appendingPathExtension("pdf")
                                                            
                                                            try data.write(to: savePath)

                                                            print("Successfully created and saved PDF at \(savePath)")
                                                        } catch let error {
                                                            print("Could not save pdf due to \(error.localizedDescription)")
                                                        }

                                                    case .failure(let failure):
                                                        print(failure.localizedDescription)
                                                    }
                                                }
                                    }*/
                                    
                                    
                                }, label: {
                                    Image(systemName: "switch.2")
                                        .foregroundStyle(Color.white)
                                        .font(.system(.body, design: .rounded, weight: .bold))
                                        .hoverEffect(.highlight)
                                        .padding(.horizontal, 5)
                                        .padding(.trailing, 5)
                                })
                            }
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
                    .padding(.top, 2)
                
                
                // Tabs
                ScrollView {
                    // Favorite Tabs
                    IntVGrid(itemCount: spaces[currentSelectedSpaceIndex].favoritesUrls.count, numberOfColumns: 4) { tabIndex in
                        VStack {
                            ZStack {
                                if reloadTitles {
                                    Color.white.opacity(0.0)
                                }
                                
                                RoundedRectangle(cornerRadius: settings.favoriteTabCornerRadius)
                                    .stroke(Color.white.opacity(0.5), lineWidth: settings.favoriteTabBorderWidth)
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
                                if !settings.hideBrowseForMe {
                                    Button {
                                        variables.browseForMeSearch = spaces[currentSelectedSpaceIndex].favoritesUrls[tabIndex]
                                        variables.isBrowseForMe = true
                                    } label: {
                                        Label("Browse for Me", systemImage: "globe.desk")
                                    }
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
                                
                                variables.searchInSidebar = unformatURL(url: spaces[currentSelectedSpaceIndex].favoritesUrls[tabIndex])
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
                                if !settings.hideBrowseForMe {
                                    Button {
                                        variables.browseForMeSearch = spaces[currentSelectedSpaceIndex].pinnedUrls[tabIndex]
                                        variables.isBrowseForMe = true
                                    } label: {
                                        Label("Browse for Me", systemImage: "globe.desk")
                                    }
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
                                
                                variables.searchInSidebar = unformatURL(url: spaces[currentSelectedSpaceIndex].pinnedUrls[tabIndex])
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
                                    .foregroundStyle(variables.textColor)
                                    .opacity(renameIsFocused ? 0.75: 0)
                                    .tint(Color.white)
                                    .font(.system(.caption, design: .rounded, weight: .medium))
                                    .focused($renameIsFocused)
                                    .onSubmit {
                                        spaces[selectedSpaceIndex].spaceName = temporaryRenameSpace
                                        
                                        Task {
                                            do {
                                                try modelContext.save()
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
                                        .foregroundStyle(variables.textColor)
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
                                .foregroundStyle(variables.textColor)
                                .opacity(!renameIsFocused ? 1.0: 0)
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .onTapGesture {
                                    temporaryRenameSpace = spaces[currentSelectedSpaceIndex].spaceName
                                    temporaryRenameSpace = String(temporaryRenameSpace)
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
                            
                            variables.textColor
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
                                        temporaryRenameSpace = spaces[currentSelectedSpaceIndex].spaceName
                                        temporaryRenameSpace = String(temporaryRenameSpace)
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
                                        .foregroundStyle(variables.textColor)
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
                                LinearGradient(gradient: Gradient(colors: [variables.startColor, variables.endColor]), startPoint: .bottomLeading, endPoint: .topTrailing)
                                    .frame(width: 250, height: 200)
                                    .ignoresSafeArea()
                                    .offset(x: -10)
                            }.frame(width: 200, height: 200)
                            
                            VStack {
                                ColorPicker("Start Color", selection: $variables.startColor)
                                    .onChange(of: variables.startColor) { oldValue, newValue in
                                        let uiColor1 = UIColor(newValue)
                                        let hexString1 = uiColor1.toHex()
                                        
                                        spaces[selectedSpaceIndex].startHex = hexString1 ?? "858585"
                                    }
                                
                                ColorPicker("End Color", selection: $variables.endColor)
                                    .onChange(of: variables.endColor) { oldValue, newValue in
                                        let uiColor2 = UIColor(newValue)
                                        let hexString2 = uiColor2.toHex()
                                        
                                        spaces[selectedSpaceIndex].endHex = hexString2 ?? "ADADAD"
                                    }
                                
                                ColorPicker("Text Color", selection: $variables.textColor)
                                    .onChange(of: variables.textColor) { oldValue, newValue in
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
                            LinearGradient(colors: [variables.startColor, variables.endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
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
                        variables.tabBarShown.toggle()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundStyle(Color(.white).opacity(hoverNewTabSection ? 0.5: 0.0))
                                .frame(height: 50)
                            HStack {
                                Label("New Tab", systemImage: "plus")
                                    .foregroundStyle(variables.textColor)
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
                            variables.tabBarShown = true
                        }
                    }
                    .onChange(of: manager.selectedWebView?.webView.url?.absoluteString ?? "") {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                            let newUrl = manager.selectedWebView?.webView.url?.absoluteString ?? ""
                            variables.searchInSidebar = newUrl
                            
                            if manager.selectedWebView != nil {
                                if manager.selectedTabLocation == .pinned {
                                    spaces[selectedSpaceIndex].pinnedUrls[manager.selectedTabIndex] = newUrl
                                }
                                else if manager.selectedTabLocation == .tabs {
                                    spaces[selectedSpaceIndex].tabUrls[manager.selectedTabIndex] = newUrl
                                }
                                else if manager.selectedTabLocation == .favorites {
                                    spaces[selectedSpaceIndex].favoritesUrls[manager.selectedTabIndex] = newUrl
                                }
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
                                if !settings.hideBrowseForMe {
                                    Button {
                                        variables.browseForMeSearch = spaces[currentSelectedSpaceIndex].tabUrls[tabIndex]
                                        variables.isBrowseForMe = true
                                    } label: {
                                        Label("Browse for Me", systemImage: "globe.desk")
                                    }
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
                                
                                variables.searchInSidebar = unformatURL(url: spaces[currentSelectedSpaceIndex].tabUrls[tabIndex])
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
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
        print("Done")
    }
}
