//
//  TabOverview.swift
//  Aura
//
//  Created by Reyna Myers on 25/6/24.
//

import SwiftUI
import WebKit
import SDWebImage
import SDWebImageSwiftUI
import SwiftData

struct TabOverview: View {
    @Namespace var namespace
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    @Environment(\.modelContext) private var modelContext
    
    @Binding var selectedSpaceIndex: Int
    
    @EnvironmentObject var variables: ObservableVariables
    @EnvironmentObject var mobileTabs: MobileTabsModel
    
    @FocusState var newTabFocus: Bool
    @FocusState var inTabFocus: Bool
    
    init(selectedSpaceIndex: Binding<Int>) {
        self._selectedSpaceIndex = selectedSpaceIndex
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if selectedSpaceIndex < spaces.count && (!spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty) {
                    LinearGradient(colors: [Color(hex: spaces[selectedSpaceIndex].startHex), Color(hex: spaces[selectedSpaceIndex].endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                        .animation(.linear)
                }
                else {
                    LinearGradient(colors: [variables.startColor, variables.endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                        .animation(.linear)
                }
                
                ScrollView {
                    TabList(selectedSpaceIndex: $selectedSpaceIndex, newTabFocus: $newTabFocus, geo: geo)
                        .namespace(namespace)
                }.onTapGesture(perform: {
                    mobileTabs.newTabFromTab = false
                    
                    if newTabFocus {
                        newTabFocus = false
                    }
                })
                .onOpenURL { url in
                    if url.absoluteString.starts(with: "aura://") {
                        //variables.navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: "https\(url.absoluteString.dropFirst(4))")!))
                    }
                    else {
                        createTab(url: url.absoluteString, isBrowseForMeTab: false)
                    }
                    print("Url:")
                    print(url)
                }
                .scrollDisabled(mobileTabs.closeTabScrollDisabledCounter > 50)
                
                
                TabTypeSwitcher()
                
                
                if mobileTabs.fullScreenWebView {
                    WebsiteView(namespace: namespace, url: $mobileTabs.webURL, webViewManager: mobileTabs.webViewManager, parentGeo: geo, webURL: $mobileTabs.webURL, fullScreenWebView: $mobileTabs.fullScreenWebView, tab: mobileTabs.selectedTab!, browseForMeTabs: $mobileTabs.browseForMeTabs)
                        .offset(x: mobileTabs.tabOffset.width, y: mobileTabs.tabOffset.height)
                        .scaleEffect(mobileTabs.tabScale)
                }
                
                VStack {
                    if !mobileTabs.fullScreenWebView {
                        HStack {
                            Button(action: {
                                variables.showSettings = true
                            }, label: {
                                Image(systemName: "gearshape")
                                
                            }).buttonStyle(ToolbarButtonStyle())
                                .sheet(isPresented: $variables.showSettings, content: {
                                    if selectedSpaceIndex < spaces.count && (!spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty) {
                                        NewSettings(presentSheet: $variables.showSettings, startHex: spaces[selectedSpaceIndex].startHex, endHex: spaces[selectedSpaceIndex].endHex)
                                    }
                                    else {
                                        NewSettings(presentSheet: $variables.showSettings, startHex: variables.startHex, endHex: variables.endHex)
                                    }
                                })
                            
                            Spacer()
                        }.padding(.top, 50)
                            .padding(.leading, 20)
                    }
                    
                    Spacer()
                    
                    ScrollView(showsIndicators: false) {
                        VStack {
                            if newTabFocus {
                                ForEach(Array(mobileTabs.suggestions.prefix(5)), id:\.self) { suggestion in
                                    HStack {
                                        Button(action: {
                                            withAnimation {
                                                newTabFocus = false
                                                createTab(url: formatURL(from: suggestion), isBrowseForMeTab: false)
                                                mobileTabs.newTabSearch = ""
                                            }
                                        }, label: {
                                            ZStack {
                                                ZStack {
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .fill(
                                                            .white.gradient.shadow(.inner(color: .black.opacity(0.2), radius: 10, x: 0, y: -3))
                                                        )
                                                        .animation(.default, value: newTabFocus)
                                                }
                                                
                                                HStack {
                                                    Text(.init(suggestion))
                                                        .animation(.default)
                                                        .foregroundColor(Color(hex: "4D4D4D"))
                                                        .font(.system(.headline, design: .rounded, weight: .bold))
                                                        .padding(.horizontal, 10)
                                                    
                                                    Spacer()
                                                    
                                                    Button(action: {
                                                        withAnimation {
                                                            newTabFocus = false
                                                            createTab(url: formatURL(from: suggestion), isBrowseForMeTab: true)
                                                            mobileTabs.newTabSearch = ""
                                                        }
                                                    }, label: {
                                                        
                                                    }).buttonStyle(BrowseForMeButtonStyle())
                                                }
                                                
                                            }.frame(minHeight: 50)
                                                .padding(.horizontal, 10)
                                        })
                                    }
                                }.animation(.easeInOut)
                            }
                        }.rotationEffect(Angle(degrees: 180))
                            .onChange(of: mobileTabs.newTabSearch, perform: { value in
                                Task {
                                    await fetchXML(searchRequest: mobileTabs.newTabSearch)
                                }
                                
                                Task {
                                    await mobileTabs.suggestions = formatXML(from: mobileTabs.xmlString)
                                }
                            })
                            .onChange(of: newTabFocus, perform: { newValue in
                                if mobileTabs.newTabFromTab && !newTabFocus {
                                    mobileTabs.newTabFromTab = false
                                }
                                if !newTabFocus {
                                    mobileTabs.suggestions.removeAll()
                                }
                            })
                    }.rotationEffect(Angle(degrees: 180))
                        .onTapGesture(perform: {
                            mobileTabs.newTabFromTab = false
                            
                            if newTabFocus {
                                newTabFocus = false
                                mobileTabs.newTabSearch = ""
                            }
                        })
                    
                    ZStack {
                        Rectangle()
                            .fill(.thinMaterial)
                            .frame(height: newTabFocus || inTabFocus ? 75: 150)
                            .onChange(of: mobileTabs.webURL, {
                                if mobileTabs.fullScreenWebView, let selectedTab = mobileTabs.selectedTab {
                                    updateTabURL(for: selectedTab.id, with: mobileTabs.webURL)
                                }
                            })
                        
                        VStack {
                            if !mobileTabs.fullScreenWebView || mobileTabs.newTabFromTab {
                                HStack(spacing: 0) {
                                    ZStack {
                                        ZStack {
                                            Capsule()
                                                .fill(.white)
                                            
                                            if mobileTabs.newTabSearch.isEmpty {
                                                Label("Search or enter url", systemImage: "magnifyingglass")
                                                    .foregroundColor(Color(hex: "4D4D4D"))
                                                    .font(.system(.headline, design: .rounded, weight: .bold))
                                                    .padding(.horizontal, newTabFocus ? 10: 0)
                                                    .animation(.default, value: newTabFocus)
                                                
                                                if newTabFocus {
                                                    Spacer()
                                                }
                                            }
                                            
                                        }.onTapGesture {
                                            newTabFocus = true
                                        }
                                        
                                        TextField("", text: $mobileTabs.newTabSearch)
                                            .focused($newTabFocus)
                                            .padding(.horizontal, 10)
                                            .textFieldStyle(.plain)
#if !os(macOS)
                                            .keyboardType(.webSearch)
                                            .textInputAutocapitalization(.never)
#endif
                                            .autocorrectionDisabled(true)
                                            .submitLabel(.search)
#if !os(visionOS) && !os(macOS)
                                            .scrollDismissesKeyboard(.immediately)
#endif
                                            .tint(Color(.systemBlue))
                                            .foregroundColor(Color(hex: "4D4D4D"))
                                            .font(.system(.headline, design: .rounded, weight: .bold))
                                            .padding(.horizontal, newTabFocus ? 10: 0)
                                            .onSubmit({
                                                withAnimation {
                                                    mobileTabs.newTabFromTab = false
                                                    newTabFocus = false
                                                    createTab(url: formatURL(from: mobileTabs.newTabSearch), isBrowseForMeTab: false)
                                                    mobileTabs.newTabSearch = ""
                                                }
                                            })
                                        
                                    }.frame(height: 50)
                                    
                                    Spacer()
                                        .frame(width: 10)
                                    
                                    Button(action: {
                                        if mobileTabs.newTabSearch == "" && newTabFocus {
                                            newTabFocus = false
                                            mobileTabs.newTabFromTab = false
                                        }
                                        else if !newTabFocus {
                                            withAnimation {
                                                newTabFocus = true
                                            }
                                        } else {
                                            withAnimation {
                                                mobileTabs.newTabFromTab = false
                                                newTabFocus = false
                                                createTab(url: formatURL(from: mobileTabs.newTabSearch), isBrowseForMeTab: false)
                                                mobileTabs.newTabSearch = ""
                                            }
                                        }
                                    }, label: {
                                        if mobileTabs.newTabSearch == "" && newTabFocus {
                                            Image(systemName: "xmark")
                                        }
                                        else {
                                            Image(systemName: newTabFocus ? "magnifyingglass": "plus")
                                        }
                                    }).buttonStyle(PlusButtonStyle())
                                        .onAppear() {
                                            if mobileTabs.settings.commandBarOnLaunch {
                                                withAnimation {
                                                    newTabFocus = true
                                                }
                                            }
                                        }
                                        .scaleEffect(!newTabFocus ? 0: 1)
                                        .frame(width: !newTabFocus ? 0: .infinity)
                                    
                                }//.padding(.leading, newTabFocus ? 10: 0)
                                .padding(.horizontal, 15)
                                    .onChange(of: mobileTabs.newTabSearch, {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                            if mobileTabs.newTabSearch == "" {
                                                mobileTabs.suggestions.removeAll()
                                            }
                                        })
                                    })
                                
                                if !newTabFocus && !inTabFocus {
                                    spaceSelector
                                }
                            }
                            else {
                                VStack {
                                    ZStack {
                                        HStack(spacing: 0) {
                                            ZStack {
                                                ZStack {
                                                    Capsule()
                                                        .fill(.white)
                                                    
                                                    if mobileTabs.fromTabSearch.isEmpty {
                                                        Label("Search or enter url", systemImage: inTabFocus ? "": "magnifyingglass")
                                                            .foregroundColor(Color(hex: "4D4D4D"))
                                                            .font(.system(.headline, design: .rounded, weight: .bold))
                                                            .padding(.horizontal, inTabFocus ? 10: 0)
                                                            //.animation(.default, value: newTabFocus)
                                                        
                                                        if newTabFocus {
                                                            Spacer()
                                                        }
                                                    }
                                                    
                                                }.onTapGesture {
                                                    inTabFocus = true
                                                }
                                                
                                                TextField("", text: $mobileTabs.fromTabSearch)
                                                    .focused($inTabFocus)
                                                    .multilineTextAlignment(inTabFocus ? .leading: .center)
                                                    .padding(.horizontal, 10)
                                                    //.opacity(newTabFocus ? 1.0: 0.0)
                                                    .textFieldStyle(.plain)
        #if !os(macOS)
                                                    .keyboardType(.webSearch)
                                                    .textInputAutocapitalization(.never)
        #endif
                                                    .autocorrectionDisabled(true)
                                                    .submitLabel(.search)
        #if !os(visionOS) && !os(macOS)
                                                    .scrollDismissesKeyboard(.immediately)
        #endif
                                                    .tint(Color(.systemBlue))
                                                    .foregroundColor(Color(hex: "4D4D4D"))
                                                    .font(.system(.headline, design: .rounded, weight: .bold))
                                                    .padding(.horizontal, inTabFocus ? 10: 0)
                                                    .onSubmit({
                                                        withAnimation {
                                                            DispatchQueue.main.async {
                                                                mobileTabs.webViewManager.load(urlString: formatURL(from: mobileTabs.fromTabSearch))
                                                                print("Loading url:")
                                                                print(formatURL(from: mobileTabs.fromTabSearch))
                                                                
                                                                mobileTabs.newTabFromTab = false
                                                                inTabFocus = false
                                                            }
                                                        }
                                                    })
                                                    .onAppear() {
                                                        mobileTabs.fromTabSearch = unformatURL(url: mobileTabs.webURL)
                                                    }
                                                    .onChange(of: mobileTabs.webURL) { oldValue, newValue in
                                                        mobileTabs.fromTabSearch = unformatURL(url: mobileTabs.webURL)
                                                    }
                                                
                                            }.frame(height: 50)
                                            
                                            
                                            Spacer()
                                                .frame(width: 10)
                                            
                                            Button(action: {
                                                if mobileTabs.fromTabSearch == "" && inTabFocus {
                                                    inTabFocus = false
                                                    mobileTabs.newTabFromTab = false
                                                }
                                                else if !newTabFocus {
                                                    withAnimation {
                                                        inTabFocus = true
                                                    }
                                                } else {
                                                    withAnimation {
                                                        mobileTabs.webViewManager.load(urlString: formatURL(from: mobileTabs.fromTabSearch))
                                                        mobileTabs.newTabFromTab = false
                                                        inTabFocus = false
                                                        //mobileTabs.newTabSearch = ""
                                                    }
                                                }
                                            }, label: {
                                                if mobileTabs.fromTabSearch == "" && inTabFocus {
                                                    Image(systemName: "xmark")
                                                }
                                                else {
                                                    Image(systemName: inTabFocus ? "magnifyingglass": "plus")
                                                }
                                            }).buttonStyle(PlusButtonStyle())
                                                .scaleEffect(!inTabFocus ? 0: 1)
                                                .frame(width: !inTabFocus ? 0: .infinity)
                                            
                                        }//.padding(.leading, newTabFocus ? 10: 0)
                                        .padding(.horizontal, 15)
                                            .onChange(of: mobileTabs.fromTabSearch, {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                                    if mobileTabs.fromTabSearch == "" {
                                                        mobileTabs.suggestions.removeAll()
                                                    }
                                                })
                                            })
                                        
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .fill(.white)
//                                            .frame(height: 50)
//                                            .padding(.horizontal, 15)
//                                        
//                                        Text(unformatURL(url: mobileTabs.webURL).prefix(30))
//                                            .lineLimit(1)
                                        
                                    }.offset(x: mobileTabs.tabOffset.width, y: mobileTabs.tabOffset.height * 3)
                                        .scaleEffect(mobileTabs.tabScale)
                                        .gesture(
                                            DragGesture()
                                                .onChanged { gesture in
                                                    withAnimation {
                                                        mobileTabs.gestureStarted = true
                                                    }
                                                    mobileTabs.exponentialThing = mobileTabs.exponentialThing * 0.99
                                                    var dragX = min(max(gesture.translation.width, -50), 50)
                                                    dragX *= mobileTabs.exponentialThing
                                                    
                                                    let dragY = gesture.translation.height
                                                    if dragY < 0 { // Only allow upward movement
                                                        let slowDragY = dragY * 0.3 // Drag up slower
                                                        mobileTabs.tabOffset = CGSize(width: dragX, height: slowDragY)
                                                        mobileTabs.tabScale = 1 - min(-slowDragY / 200, 0.5)
                                                    }
                                                }
                                                .onEnded { gesture in
                                                    mobileTabs.exponentialThing = 1
                                                    withAnimation {
                                                        mobileTabs.gestureStarted = false
                                                    }
                                                    if gesture.translation.height < -100 {
                                                        //self.presentationMode.wrappedValue.dismiss()
                                                        withAnimation {
                                                            mobileTabs.fullScreenWebView = false
                                                            mobileTabs.webURL = ""
                                                        }
                                                    }
                                                    withAnimation(.spring()) {
                                                        mobileTabs.tabOffset = .zero
                                                        mobileTabs.tabScale = 1.0
                                                    }
                                                    
                                                }
                                        )
                                    
                                    if !newTabFocus && !inTabFocus {
                                        HStack {
                                            Button(action: {
                                                mobileTabs.webViewManager.goBack()
                                            }, label: {
                                                Image(systemName: "chevron.left")
                                            })
                                            .disabled(!mobileTabs.webViewManager.canGoBack())
                                            .foregroundStyle(!mobileTabs.webViewManager.canGoBack() ? Color.gray: Color(.systemBlue))
                                            .shadow(color: .white.opacity(0.5), radius: 2, x: 0, y: 0)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                mobileTabs.webViewManager.goForward()
                                            }, label: {
                                                Image(systemName: "chevron.right")
                                            })
                                            .disabled(!mobileTabs.webViewManager.canGoForward())
                                            .foregroundStyle(!mobileTabs.webViewManager.canGoForward() ? Color.gray: Color(.systemBlue))
                                            .shadow(color: .white.opacity(0.5), radius: 5, x: 0, y: 0)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                mobileTabs.newTabFromTab = true
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                                    mobileTabs.newTabFromTab = true
                                                    
                                                    if !newTabFocus {
                                                        withAnimation {
                                                            newTabFocus = true
                                                        }
                                                    } else {
                                                        withAnimation {
                                                            newTabFocus = false
                                                            createTab(url: formatURL(from: mobileTabs.newTabSearch), isBrowseForMeTab: false)
                                                            mobileTabs.newTabSearch = ""
                                                        }
                                                    }
                                                })
                                            }, label: {
                                                Image(systemName: "plus")
                                            })
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                withAnimation {
                                                    mobileTabs.fullScreenWebView = false
                                                }
                                            }, label: {
                                                Image(systemName: "square.on.square")
                                            })
                                        }
                                        .font(.system(.title2, design: .rounded, weight: .regular))
                                        .foregroundStyle(Color(.systemBlue))
                                        .opacity(Double(mobileTabs.tabScale))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                    }
                                }
                            }
                        }
                    }//.offset(y: newTabFocus || inTabFocus ? 50: 0)
                }.ignoresSafeArea(newTabFocus || inTabFocus ? .container: .all, edges: .all)
            }
        }
        .environmentObject(mobileTabs)
        .onAppear {
            updateTabs()
        }
    }
    
    private var spaceSelector: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                ScrollViewReader { proxy in
                    HStack(spacing: 10) {
                        ForEach(spaces.indices, id: \.self) { index in
                            Button(action: {
                                withAnimation {
                                    withAnimation {
                                        selectedSpaceIndex = index
                                        updateTabs()
                                        proxy.scrollTo(index, anchor: .center) // Snap to center on tap
                                    }
                                }
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.regularMaterial)
                                        .frame(width: geometry.size.width - 50, height: 50)
                                    
                                    HStack {
                                        Image(systemName: spaces[index].spaceIcon)
                                        Text(spaces[index].spaceName)
                                    }
                                    .foregroundStyle(Color(hex: "4D4D4D"))
                                    .font(.system(size: 16, weight: .bold))
                                    .opacity(selectedSpaceIndex == index ? 1.0 : 0.4)
                                    .padding(.horizontal, 15)
                                }
                                .frame(width: geometry.size.width / 2, height: 50)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(15)
                                .contentShape(Rectangle())
                                .id(index)
                                .onAppear {
                                    if selectedSpaceIndex == index {
                                        proxy.scrollTo(index, anchor: .center)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                }
            }
            .padding(.bottom)
        }.frame(height: 75)
    }
    
    
    private func handleDragChange(_ gesture: DragGesture.Value, for id: UUID) {
        mobileTabs.offsets[id] = gesture.translation
        mobileTabs.zIndexes[id] = 100
        var tilt = min(Double(abs(gesture.translation.width)) / 20, 15)
        if gesture.translation.width < 0 {
            tilt *= -1
        }
        mobileTabs.tilts[id] = tilt
        
        mobileTabs.closeTabScrollDisabledCounter = abs(Int(gesture.translation.width))
    }
    
    private func handleDragEnd(_ gesture: DragGesture.Value, for id: UUID) {
        mobileTabs.zIndexes[id] = 1
        if abs(gesture.translation.width) > 100 {
            withAnimation {
                if gesture.translation.width < 0 {
                    mobileTabs.offsets[id] = CGSize(width: -500, height: 0)
                } else {
                    mobileTabs.offsets[id] = CGSize(width: 500, height: 0)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        removeItem(id)
                    }
                }
            }
        } else {
            withAnimation {
                mobileTabs.offsets[id] = .zero
                mobileTabs.tilts[id] = 0.0
            }
        }
        
        mobileTabs.closeTabScrollDisabledCounter = 0
    }
    
    private func updateTabs() {
        if UserDefaults.standard.integer(forKey: "savedSelectedSpaceIndex") > spaces.count - 1 {
            selectedSpaceIndex = 0
        }
        
        Task {
            if spaces.count <= 0 {
                await modelContext.insert(SpaceStorage(spaceIndex: spaces.count, spaceName: "Untitled", spaceIcon: "circle.fill", favoritesUrls: [], pinnedUrls: [], tabUrls: []))
            }
        }
        
        if spaces.count > selectedSpaceIndex {
            var temporaryTabs = spaces[selectedSpaceIndex].tabUrls.map { (id: UUID(), url: $0) }
            //tabs = temporaryTabs.reversed()
            mobileTabs.tabs = temporaryTabs
            mobileTabs.pinnedTabs = spaces[selectedSpaceIndex].pinnedUrls.map { (id: UUID(), url: $0) }
            mobileTabs.favoriteTabs = spaces[selectedSpaceIndex].favoritesUrls.map { (id: UUID(), url: $0) }
        }
    }
    
    private func saveTabs() {
        if UserDefaults.standard.integer(forKey: "savedSelectedSpaceIndex") > spaces.count - 1 {
            selectedSpaceIndex = 0
        }
        
        if spaces.count > selectedSpaceIndex {
            // Extracting URLs from tabs, pinnedTabs, and favoriteTabs arrays
            let extractedTabUrls = mobileTabs.tabs.map { $0.url }
            let extractedPinnedUrls = mobileTabs.pinnedTabs.map { $0.url }
            let extractedFavoriteUrls = mobileTabs.favoriteTabs.map { $0.url }
            
            // Updating the corresponding space with the extracted URLs
            spaces[selectedSpaceIndex].tabUrls = extractedTabUrls
            spaces[selectedSpaceIndex].pinnedUrls = extractedPinnedUrls
            spaces[selectedSpaceIndex].favoritesUrls = extractedFavoriteUrls
        }
    }
    
    private func removeItem(_ id: UUID) {
        mobileTabs.browseForMeTabs.removeAll { $0 == id.description }
        
        switch mobileTabs.selectedTabsSection {
        case .tabs:
            if let index = mobileTabs.tabs.firstIndex(where: { $0.id == id }) {
                mobileTabs.tabs.remove(at: index)
                spaces[selectedSpaceIndex].tabUrls.remove(at: index)
            }
        case .pinned:
            if let index = mobileTabs.pinnedTabs.firstIndex(where: { $0.id == id }) {
                mobileTabs.pinnedTabs.remove(at: index)
                spaces[selectedSpaceIndex].pinnedUrls.remove(at: index)
            }
        case .favorites:
            if let index = mobileTabs.favoriteTabs.firstIndex(where: { $0.id == id }) {
                mobileTabs.favoriteTabs.remove(at: index)
                spaces[selectedSpaceIndex].favoritesUrls.remove(at: index)
            }
        }
        
        withAnimation {
            mobileTabs.offsets.removeValue(forKey: id)
            mobileTabs.tilts.removeValue(forKey: id)
            mobileTabs.zIndexes.removeValue(forKey: id)
        }
    }
    
    private func updateTabURL(for id: UUID, with newURL: String) {
        switch mobileTabs.selectedTabsSection {
        case .tabs:
            if let index = mobileTabs.tabs.firstIndex(where: { $0.id == id }) {
                mobileTabs.tabs[index].url = newURL
                spaces[selectedSpaceIndex].tabUrls[index] = newURL
            }
        case .pinned:
            if let index = mobileTabs.pinnedTabs.firstIndex(where: { $0.id == id }) {
                mobileTabs.pinnedTabs[index].url = newURL
                spaces[selectedSpaceIndex].pinnedUrls[index] = newURL
            }
        case .favorites:
            if let index = mobileTabs.favoriteTabs.firstIndex(where: { $0.id == id }) {
                mobileTabs.favoriteTabs[index].url = newURL
                spaces[selectedSpaceIndex].favoritesUrls[index] = newURL
            }
        }
    }
    
    
    private func createTab(url: String, isBrowseForMeTab: Bool) {
        let newTab = (id: UUID(), url: url)
        
        switch mobileTabs.selectedTabsSection {
        case .tabs:
            mobileTabs.tabs.append(newTab)
            spaces[selectedSpaceIndex].tabUrls.append(url)
        case .pinned:
            mobileTabs.pinnedTabs.append(newTab)
            spaces[selectedSpaceIndex].pinnedUrls.append(url)
        case .favorites:
            mobileTabs.favoriteTabs.append(newTab)
            spaces[selectedSpaceIndex].favoritesUrls.append(url)
        }
        
        if isBrowseForMeTab {
            mobileTabs.browseForMeTabs.append(newTab.id.description)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            withAnimation {
                mobileTabs.selectedTab = newTab
                mobileTabs.webURL = newTab.url
                mobileTabs.fullScreenWebView = true
            }
        })
    }
    
    func fetchXML(searchRequest: String) {
        guard let url = URL(string: "https://toolbarqueries.google.com/complete/search?q=\(searchRequest.replacingOccurrences(of: " ", with: "+"))&output=toolbar&hl=en") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let xmlContent = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.mobileTabs.xmlString = xmlContent
                }
            } else {
                print("Unable to convert data to string")
            }
        }.resume()
    }
    // More APIs for Search suggestions. Implement in the future
    // https://duckduckgo.com/ac/?q=YOUR_QUERY_HERE&type=list
    // https://api.bing.com/osjson.aspx?query=YOUR_QUERY_HERE
    
    func formatXML(from input: String) -> [String] {
        var results = [String]()
        
        // Find all occurrences of 'data="' in the XML string
        var currentIndex = mobileTabs.xmlString.startIndex
        while let startIndex = mobileTabs.xmlString[currentIndex...].range(of: "data=\"")?.upperBound {
            let remainingSubstring = mobileTabs.xmlString[startIndex...]
            
            // Find the end of the attribute value enclosed in quotation marks
            if let endIndex = remainingSubstring.range(of: "\"")?.lowerBound {
                let attributeValue = mobileTabs.xmlString[startIndex..<endIndex]
                results.append(String(attributeValue))
                
                // Move to the next character after the found attribute value
                currentIndex = endIndex
            } else {
                break
            }
        }
        
        return results
    }
}


struct NamespaceEnvironmentKey: EnvironmentKey {
    static var defaultValue: Namespace.ID = Namespace().wrappedValue
}

extension EnvironmentValues {
    var namespace: Namespace.ID {
        get { self[NamespaceEnvironmentKey.self] }
        set { self[NamespaceEnvironmentKey.self] = newValue }
    }
}

extension View {
    func namespace(_ value: Namespace.ID) -> some View {
        environment(\.namespace, value)
    }
}
