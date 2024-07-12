//
//  TestingView.swift
//  iPad browser
//
//  Created by Reyna Myers on 8/9/23.
//

import SwiftUI
#if !os(macOS)
import UIKit
#else
import AppKit
#endif
import WebKit
import Combine
import SDWebImage
import SDWebImageSwiftUI
import SwiftData
import CodeEditor


let defaults = UserDefaults.standard


struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    
    @StateObject var variables = ObservableVariables()
    @StateObject var settings = SettingsVariables()
    @StateObject private var boostStore = BoostStore()
    
    @StateObject var manager =  WebsiteManager()
    
    @AppStorage("currentSpace") var currentSpace = "Untitled"
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let rotationTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    @AppStorage("startColorHex") var startHex = "8A3CEF"
    @AppStorage("endColorHex") var endHex = "84F5FE"
    @AppStorage("textColorHex") var textHex = "ffffff"
    
    @State var boostEditor = true
    @State var currentBoostText = ""
    @State var currentPassedClassesString = ""
    @State var generateAICSS = false
    
    @AppStorage("hideSidebar") var hideSidebar = false
    
    
    @FocusState private var focusedField: FocusedField?
    
    @AppStorage("selectedSpaceIndex") var selectedSpaceIndex = 0
    
    enum FocusedField {
        case commandBar, tabBar, none
    }
    
    @State var launchingAnimation = true
    
    @State var changingBoost = false
    @State var boostWindowWidth: CGFloat = 300.0
    @State var webInspectorHeight: CGFloat = 300.0
    
    @State var inspectCodeString = ""
    @State var customAIBoostInstructions = ""
    
    @State var cssTimeout = false
    
    @State var inspectorTab = 0
    
    @State var aiGenerationPopover = false
    
    @State var htmlInspectTimeoutCounter = 0
    
    var body: some View {
        ZStack {
            if UIDevice.current.userInterfaceIdiom != .phone {
                GeometryReader { geo in
                    if spaces.count > 0 {
                        ZStack {
                            ZStack {
#if !os(visionOS)
                                if selectedSpaceIndex < spaces.count && (!spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty) {
                                    LinearGradient(colors: [Color(hex: spaces[selectedSpaceIndex].startHex), Color(hex: spaces[selectedSpaceIndex].endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                }
                                else {
                                    LinearGradient(colors: [variables.startColor, variables.endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                }
#endif
                                
                                if settings.prefferedColorScheme == "dark" || (settings.prefferedColorScheme == "automatic" && colorScheme == .dark) {
                                    Color.black.opacity(0.5)
                                }
                                
                                
                                HStack(spacing: 0) {
                                    //if UIDevice.current.userInterfaceIdiom != .phone {
                                        if settings.sidebarLeft {
                                            if settings.showBorder {
                                                ThreeDots(hoverTinySpace: $variables.hoverTinySpace, hideSidebar: $hideSidebar)
                                                    .disabled(true)
                                            }
                                            
                                                PagedSidebar(selectedTabLocation: $variables.selectedTabLocation, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $variables.searchInSidebar, commandBarShown: $variables.commandBarShown, tabBarShown: $variables.tabBarShown, startColor: $variables.startColor, endColor: $variables.endColor, textColor: $variables.textColor, hoverSpace: $variables.hoverSpace, showSettings: $variables.showSettings, fullGeo: geo)
                                        }
                                    HStack {
                                        GeometryReader { webGeo in
                                            ZStack {
                                                Color.white
                                                    .opacity(0.4)
                                                    .cornerRadius(10)
                                                
                                                
                                                //MARK: - WebView
                                                CurrentWebView(webGeo: webGeo)
                                                    .overlay(content: {
                                                        loadingIndicators(for: manager.selectedWebView?.webView.isLoading ?? false)
                                                    })
                                                
                                                if !settings.swipeNavigationDisabled {
                                                    if manager.selectedWebView != nil {
                                                        HStack(alignment: .center, spacing: 0) {
                                                            navigationButton(imageName: "arrow.left", action: {
                                                                manager.selectedWebView?.webView.goBack()
                                                            })
                                                            .padding(.trailing, 30)
                                                            
                                                            Spacer()
                                                                .frame(width: webGeo.size.width)
                                                            
                                                            navigationButton(imageName: "arrow.right", action: {
                                                                manager.selectedWebView?.webView.goForward()
                                                            })
                                                            .padding(.leading, 30)
                                                            
                                                        }
                                                        .frame(width: webGeo.size.width)
                                                        .offset(x: variables.navigationOffset)
                                                    }
                                                }
                                                
                                                if variables.auraTab == "dashboard" && variables.selectedTabLocation == "" {
                                                    Dashboard(startHexSpace: spaces[selectedSpaceIndex].startHex, endHexSpace: spaces[selectedSpaceIndex].endHex)
                                                        .cornerRadius(10)
                                                        .clipped()
                                                }
                                                
                                                Spacer()
                                                    .frame(width: 20)
                                                
                                                HStack {
                                                    Button {
                                                        Task {
                                                            hideSidebar.toggle()
                                                        }
                                                    } label: {
                                                        
                                                    }
                                                    .keyboardShortcut(variables.shortcuts.parseShortcut(shortcut: variables.shortcuts.toggleSidebar))
                                                    .buttonStyle(.plain)
                                                    
                                                    Button {
                                                        if manager.selectedWebView?.webView.canGoBack ?? true {
                                                            withAnimation(.bouncy, {
                                                                variables.backArrowPulse = true
                                                            })
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                                                withAnimation(.bouncy, {
                                                                    variables.backArrowPulse = false
                                                                })
                                                            })
                                                            
                                                            manager.selectedWebView?.webView.goBack()
                                                        }
                                                    } label: {
                                                        
                                                    }
                                                    .keyboardShortcut(variables.shortcuts.parseShortcut(shortcut: variables.shortcuts.goBack))
                                                    .buttonStyle(.plain)
                                                    
                                                    Button {
                                                        if manager.selectedWebView?.webView.canGoForward ?? true {
                                                            withAnimation(.bouncy, {
                                                                variables.forwardArrowPulse = true
                                                            })
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                                                                withAnimation(.bouncy, {
                                                                    variables.forwardArrowPulse = false
                                                                })
                                                            })
                                                            manager.selectedWebView?.webView.goForward()
                                                        }
                                                    } label: {
                                                        
                                                    }
                                                    .keyboardShortcut(variables.shortcuts.parseShortcut(shortcut: variables.shortcuts.goForward))
                                                    .buttonStyle(.plain)
                                                    
                                                    
                                                    Button {
                                                        withAnimation(.bouncy, {
                                                            variables.reloadRotation += 360
                                                        })
                                                        
                                                        variables.searchInSidebar = manager.selectedWebView?.webView.url?.absoluteString ?? variables.searchInSidebar
                                                        manager.selectedWebView?.reload()
                                                    } label: {
                                                        
                                                    }
                                                    .keyboardShortcut(variables.shortcuts.parseShortcut(shortcut: variables.shortcuts.reload))
                                                    .buttonStyle(.plain)
                                                    
                                                    
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
                                                        
                                                    }
                                                    .keyboardShortcut(variables.shortcuts.parseShortcut(shortcut: variables.shortcuts.commandBar))
                                                    .buttonStyle(.plain)
                                                    
                                                    
                                                    Button {
                                                        if manager.selectedWebView != nil {
                                                            switch manager.selectedTabLocation {
                                                            case .pinned:
                                                                pinnedRemoveTab(at: manager.selectedTabIndex)
                                                            case .favorites:
                                                                favoriteRemoveTab(at: manager.selectedTabIndex)
                                                            case .tabs:
                                                                removeTab(at: manager.selectedTabIndex)
                                                            }
                                                        }
                                                    } label: {
                                                        
                                                    }.keyboardShortcut("w", modifiers: .command)
                                                        .buttonStyle(.plain)
                                                    
                                                    
                                                    Button {
                                                        variables.tabBarShown.toggle()
                                                        variables.commandBarShown = false
                                                    } label: {
                                                        
                                                    }
                                                    .keyboardShortcut(variables.shortcuts.parseShortcut(shortcut: variables.shortcuts.newTab))
                                                    .buttonStyle(.plain)
                                                    
                                                    
                                                }
                                            }
                                            .gesture(
                                                DragGesture()
                                                    .onChanged { value in
                                                        if !settings.swipeNavigationDisabled {
                                                            let startLocation = value.startLocation.x
                                                            let width = webGeo.size.width
                                                            
                                                            if startLocation < 100 || startLocation > (width - 100) {
                                                                let newOffset = value.translation.width
                                                                if abs(newOffset) <= 150 {
                                                                    variables.navigationOffset = newOffset
                                                                } else {
                                                                    variables.navigationOffset = newOffset > 0 ? 150 : -150
                                                                }
                                                                if abs(newOffset) > 100 {
                                                                    if !variables.arrowImpactOnce {
                                                                        heavyHaptics()
                                                                        
                                                                        variables.arrowImpactOnce = true
                                                                    }
                                                                    
                                                                    withAnimation(.linear(duration: 0.3)) {
                                                                        variables.navigationArrowColor = true
                                                                    }
                                                                } else {
                                                                    if variables.arrowImpactOnce {
                                                                        heavyHaptics()
                                                                        
                                                                        variables.arrowImpactOnce = false
                                                                    }
                                                                    withAnimation(.linear(duration: 0.3)) {
                                                                        variables.navigationArrowColor = false
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                    .onEnded { value in
                                                        if !settings.swipeNavigationDisabled {
                                                            variables.arrowImpactOnce = false
                                                            let startLocation = value.startLocation.x
                                                            let width = webGeo.size.width
                                                            
                                                            if startLocation < 150 || startLocation > (width - 150) {
                                                                if variables.navigationOffset >= 100 {
                                                                    goBack()
                                                                } else if variables.navigationOffset < -100 {
                                                                    goForward()
                                                                }
                                                                
                                                                withAnimation(.linear(duration: 0.25)) {
                                                                    variables.navigationOffset = 0
                                                                    variables.navigationArrowColor = false
                                                                }
                                                            }
                                                        }
                                                    }
                                            )
                                            .onChange(of: webGeo.size) {
                                                variables.navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: webGeo.size.width, height: webGeo.size.height))
                                                
                                                variables.pinnedNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: webGeo.size.width, height: webGeo.size.height))
                                                
                                                variables.favoritesNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: webGeo.size.width, height: webGeo.size.height))
                                            }
                                        }
                                        .cornerRadius(10)
                                        .clipped()
                                        .padding(settings.sidebarLeft ? .trailing: .leading, settings.showBorder ? 12: 0)
                                        
                                        if variables.delayedBrowseForMe {
                                            BrowseForMe(searchText: variables.browseForMeSearch, searchResponse: "", closeSheet: $variables.isBrowseForMe)
                                                .frame(width: variables.isBrowseForMe ? 400: 0)
                                                .cornerRadius(10)
                                                .clipped()
                                        }
                                    }.onChange(of: variables.isBrowseForMe, {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                            withAnimation(.linear, {
                                                variables.delayedBrowseForMe = variables.isBrowseForMe
                                            })
                                        })
                                    })
                                    
                                    ZStack {
                                        if variables.boostEditor {
                                            HStack(spacing: 0) {
                                                VStack {
                                                    Color.black
                                                        .opacity(0.0001)
                                                    
                                                    Color.gray
                                                        .opacity(0.8)
                                                        .cornerRadius(50)
                                                        .frame(height: 30)
                                                    
                                                    Color.black
                                                        .opacity(0.0001)
                                                    
                                                }.frame(width: 10)
                                                    .padding(.trailing, 10)
                                                    .gesture(
                                                        DragGesture()
                                                            .onChanged { value in
                                                                let changedWidth = boostWindowWidth - value.translation.width
                                                                
                                                                boostWindowWidth = max(200, changedWidth)
                                                            }
                                                    )
                                                
                                                
                                                VStack {
                                                    ZStack {
                                                        AIBoostGenerator(customInstructions: $customAIBoostInstructions, passedClasses: $currentPassedClassesString, text: $currentBoostText, generate: $generateAICSS)
                                                            .opacity(0.0)
                                                        
                                                        CodeEditor(source: $currentBoostText, language: .css, theme: .agate, fontSize: .constant(15), flags: [.selectable, .editable, .smartIndent], indentStyle: .softTab(width: 4), autoPairs: ["{":"}", "'":"'", "(":")"], allowsUndo: true)
                                                        
                                                        
                                                        
                                                        
                                                        VStack {
                                                            HStack {
                                                                Spacer()
                                                                
                                                                Button {
                                                                    aiGenerationPopover = true
                                                                } label: {
                                                                    Text("AI")
                                                                }
                                    #if !os(visionOS)
                                                                .buttonStyle(PlusButtonStyle())
                                                                #endif
                                                                    .padding(15)
                                                                
                                                            }.popover(isPresented: $aiGenerationPopover, content: {
                                                                ZStack {
#if !os(visionOS)
                                if selectedSpaceIndex < spaces.count && (!spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty) {
                                    LinearGradient(colors: [Color(hex: spaces[selectedSpaceIndex].startHex), Color(hex: spaces[selectedSpaceIndex].endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                }
                                else {
                                    LinearGradient(colors: [variables.startColor, variables.endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                }
#endif
                                
                                if settings.prefferedColorScheme == "dark" || (settings.prefferedColorScheme == "automatic" && colorScheme == .dark) {
                                    Color.black.opacity(0.5)
                                }
                                                                    
                                                                    VStack {
                                                                        Text("Options")
                                                                        
                                                                        TextField("Custom Instructions", text: $customAIBoostInstructions)
                                                                        
                                                                        Button(action: {
                                                                            print("Style the boost like this \(customAIBoostInstructions). These are your items to style: \(parseHTMLAI(from: removeHeadContent(from: inspectCodeString)).joined(separator: "\n"))")
                                                                            
                                                                            currentPassedClassesString = parseHTMLAI(from: removeHeadContent(from: inspectCodeString)).joined(separator: "\n")
                                                                            
                                                                            print("currentPassedClassesString:")
                                                                            print(currentPassedClassesString)
                                                                            
                                                                            generateAICSS.toggle()
                                                                        }, label: {
                                                                            Text("Generate CSS")
                                                                        })
#if !os(visionOS)
                                                                        .buttonStyle(PlusButtonStyle())
#endif
                                                                    }
                                                                }
                                                            })
                                                            
                                                            Spacer()
                                                        }
                                                    }
                                                    
                                                    
                                                    HStack {
                                                        Color.black
                                                            .opacity(0.0001)
                                                        
                                                        Color.gray
                                                            .opacity(0.8)
                                                            .cornerRadius(50)
                                                            .frame(width: 30)
                                                        
                                                        Color.black
                                                            .opacity(0.0001)
                                                        
                                                    }.frame(height: 10)
                                                        .gesture(
                                                            DragGesture()
                                                                .onChanged { value in
                                                                    let changedHeight = webInspectorHeight - value.translation.height
                                                                    
                                                                    webInspectorHeight = max(100, changedHeight)
                                                                }
                                                        )
                                                    
                                                    Picker("", selection: $inspectorTab) {
                                                        Text("Inspector").tag(0)
                                                        Text("Classes").tag(1)
                                                    }
                                                    .pickerStyle(.segmented)
                                                    
                                                    if inspectorTab == 0 {
                                                        CodeEditor(source: inspectCodeString, language: .xml, theme: .agate, fontSize: .constant(15), flags: [.selectable, .smartIndent], indentStyle: .softTab(width: 4), allowsUndo: true)
                                                            .frame(height: webInspectorHeight)
                                                    }
                                                    else if inspectorTab == 1 {
                                                        CodeEditor(source: currentPassedClassesString, language: .markdown, theme: .agate, fontSize: .constant(15), flags: [.selectable, .smartIndent], indentStyle: .softTab(width: 4), allowsUndo: true)
                                                            .frame(height: webInspectorHeight)
                                                    }
                                                }
                                                .scrollContentBackground(.hidden)
                                                .tint(.white)
                                                .frame(width: boostWindowWidth)
                                            }
                                        }
                                    }
                                    .onChange(of: currentBoostText) {
                                        if !cssTimeout {
                                            if let urlString = manager.selectedWebView?.webView.url?.absoluteString,
                                               let key = unformatPlainURL(url: urlString).components(separatedBy: "/").first {
                                                
                                                print("Text Changed:")
                                                print("Key: \(key)")
                                                print("Updated Text: \(currentBoostText)")
                                                
                                                variables.boosts.keyValuePairs[key] = currentBoostText
                                                
                                                let jsToInjectCSS = """
                                        (function() {
                                          var style = document.createElement('style');
                                          style.textContent = `\(currentBoostText)`;
                                          document.head.appendChild(style);
                                        })();
                                        """
                                                manager.selectedWebView?.JSperformScript(script: jsToInjectCSS)
                                            }
                                            
                                            cssTimeout = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                                            cssTimeout = false
                                        })
                                    }
                                    .onChange(of: manager.selectedWebView?.webView.url?.absoluteString ?? "") {
                                        
                                        manager.selectedWebView?.getHTML { thing in
                                            validateHTMLResult(thing: thing ?? "Error")
                                        }
                                        
                                        currentBoostText = ""
                                        
                                        if let urlString = manager.selectedWebView?.webView.url?.absoluteString,
                                           let key = unformatPlainURL(url: urlString).components(separatedBy: "/").first,
                                           let savedCSS = variables.boosts.getValue(forKey: key) {
                                            
                                            print("URL Changed:")
                                            print("Key: \(key)")
                                            
                                            currentBoostText = savedCSS
                                            
                                            // Inject saved CSS when the URL changes
                                            let jsToInjectCSS = """
                                            (function() {
                                              var style = document.createElement('style');
                                              style.textContent = `\(savedCSS)`;
                                              document.head.appendChild(style);
                                            })();
                                            """
                                            manager.selectedWebView?.JSperformScript(script: jsToInjectCSS)
                                        }
                                    }
                                    
                                    if true {
                                        if !settings.sidebarLeft {
                                            if settings.showBorder {
                                                ThreeDots(hoverTinySpace: $variables.hoverTinySpace, hideSidebar: $hideSidebar)
                                                    .disabled(true)
                                            }
                                            
                                                PagedSidebar(selectedTabLocation: $variables.selectedTabLocation, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $variables.searchInSidebar, commandBarShown: $variables.commandBarShown, tabBarShown: $variables.tabBarShown, startColor: $variables.startColor, endColor: $variables.endColor, textColor: $variables.textColor, hoverSpace: $variables.hoverSpace, showSettings: $variables.showSettings, fullGeo: geo)
                                        }
                                    }
                                }
                                .padding(.trailing, settings.showBorder ? 10: 0)
                                .padding(.vertical, settings.showBorder ? 25: 0)
                                .onAppear {
                                    if let savedStartColor = getColor(forKey: "startColorHex") {
                                        variables.startColor = savedStartColor
                                    }
                                    if let savedEndColor = getColor(forKey: "endColorHex") {
                                        variables.endColor = savedEndColor
                                    }
                                    if let savedTextColor = getColor(forKey: "textColorHex") {
                                        variables.textColor = savedTextColor
                                    }
                                    
                                    variables.spaceIcons = UserDefaults.standard.dictionary(forKey: "spaceIcons") as? [String: String]
                                }
                                
                                if variables.tabBarShown || variables.commandBarShown || variables.tapSidebarShown {
                                    Button(action: {
                                        variables.tabBarShown = false
                                        variables.commandBarShown = false
                                        variables.tapSidebarShown = false
                                    }, label: {
                                        Color.white.opacity(0.0001)
                                    }).buttonStyle(.plain)
#if !os(macOS)
                                        .hoverEffectDisabled(true)
#endif
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
                                                    variables.tapSidebarShown = true
                                                    
                                                }
                                            
                                            HStack {
                                                //                                        PagedSidebar(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, showSettings: $showSettings, geo: geo)
                                                
                                                //if UIDevice.current.userInterfaceIdiom != .phone {
                                                if true {
                                                    VStack {
                                                        ToolbarButtonsView(selectedTabLocation: $variables.selectedTabLocation, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $variables.searchInSidebar, commandBarShown: $variables.commandBarShown, tabBarShown: $variables.tabBarShown, startColor: $variables.startColor, endColor: $variables.endColor, textColor: $variables.textColor, geo: geo).frame(height: 40)
                                                            .padding([.top, .horizontal], 5)
                                                        
                                                        //Sidebar(selectedTabLocation: $selectedTabLocation, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, showSettings: $showSettings, geo: geo)
                                                        SidebarSpaceParameter(currentSelectedSpaceIndex: variables.selectedSpaceIndex, selectedTabLocation: $variables.selectedTabLocation, hideSidebar: $hideSidebar, searchInSidebar: $variables.searchInSidebar, commandBarShown: $variables.commandBarShown, tabBarShown: $variables.tabBarShown, startColor: $variables.startColor, endColor: $variables.endColor, textColor: $variables.textColor, hoverSpace: $variables.hoverSpace, showSettings: $variables.showSettings, geo: geo)
                                                        
                                                        HStack {
                                                            Button {
                                                                variables.showSettings.toggle()
                                                            } label: {
                                                                ZStack {
                                                                    HoverButtonDisabledVision(hoverInteraction: $variables.settingsButtonHover)
                                                                    
                                                                    Image(systemName: "gearshape")
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .frame(width: 20, height: 20)
                                                                        .foregroundStyle(variables.textColor)
                                                                        .opacity(variables.settingsButtonHover ? 1.0: 0.5)
                                                                    
                                                                }.frame(width: 40, height: 40).cornerRadius(7)
#if !os(visionOS) && !os(macOS)
                                                                    .hoverEffect(.lift)
                                                                    .hoverEffectDisabled(!settings.hoverEffectsAbsorbCursor)
#endif
                                                                    .onHover(perform: { hovering in
                                                                        if hovering {
                                                                            variables.settingsButtonHover = true
                                                                        }
                                                                        else {
                                                                            variables.settingsButtonHover = false
                                                                        }
                                                                    })
                                                            }
                                                            .sheet(isPresented: $variables.showSettings) {
                                                                if #available(iOS 18.0, visionOS 2.0, *) {
                                                                    NewSettings(presentSheet: $variables.showSettings, startHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].startHex: startHex, endHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].endHex: endHex)
                                                                        .presentationSizing(.form)
                                                                } else {
                                                                    NewSettings(presentSheet: $variables.showSettings, startHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].startHex: startHex, endHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].endHex: endHex)
                                                                }
                                                            }
                                                            Spacer()
                                                            
                                                            SpacePicker(navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, currentSpace: $currentSpace, selectedSpaceIndex: $selectedSpaceIndex)
                                                            
                                                            Button(action: {
                                                                modelContext.insert(SpaceStorage(spaceIndex: spaces.count, spaceName: "Untitled \(spaces.count)", spaceIcon: "scribble.variable", favoritesUrls: [], pinnedUrls: [], tabUrls: []))
                                                            }, label: {
                                                                ZStack {
#if !os(visionOS)
                                                                    Color(.white)
                                                                        .opacity(variables.hoverSpace == "veryLongTextForHoveringOnPlusSignSoIDontHaveToUseAnotherVariable" ? 0.5: 0.0)
#endif
                                                                    
                                                                    Image(systemName: "plus")
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .frame(width: 20, height: 20)
                                                                        .foregroundStyle(variables.textColor)
                                                                        .opacity(variables.hoverSpace == "veryLongTextForHoveringOnPlusSignSoIDontHaveToUseAnotherVariable" ? 1.0: 0.5)
                                                                    
                                                                }.frame(width: 40, height: 40).cornerRadius(7)
#if !os(visionOS) && !os(macOS)
                                                                    .hoverEffect(.lift)
                                                                    .hoverEffectDisabled(!settings.hoverEffectsAbsorbCursor)
#endif
                                                                    .onHover(perform: { hovering in
                                                                        if hovering {
                                                                            variables.hoverSpace = "veryLongTextForHoveringOnPlusSignSoIDontHaveToUseAnotherVariable"
                                                                        }
                                                                        else {
                                                                            variables.hoverSpace = ""
                                                                        }
                                                                    })
                                                            })
                                                        }
                                                    }
                                                    .padding(15)
                                                    .frame(width: 300)
                                                    .background(content: {
#if !os(visionOS)
                                                        if settings.sidebarLeft {
                                                            LinearGradient(colors: [variables.startColor, Color(hex: averageHexColor(hex1: variables.startHex, hex2: variables.endHex))], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                                .opacity(1.0)
                                                            if selectedSpaceIndex < spaces.count {
                                                                if !spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty {
                                                                    LinearGradient(colors: [Color(hex: spaces[selectedSpaceIndex].startHex), Color(hex: averageHexColor(hex1: spaces[selectedSpaceIndex].startHex, hex2: spaces[selectedSpaceIndex].endHex))], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                                }
                                                            }
                                                        } else {
                                                            LinearGradient(colors: [Color(hex: averageHexColor(hex1: variables.startHex, hex2: variables.endHex)), variables.endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                                .opacity(1.0)
                                                            if selectedSpaceIndex < spaces.count {
                                                                if !spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty {
                                                                    LinearGradient(colors: [Color(hex: averageHexColor(hex1: spaces[selectedSpaceIndex].startHex, hex2: spaces[selectedSpaceIndex].endHex)), Color(hex: spaces[selectedSpaceIndex].endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                                }
                                                            }
                                                        }
#endif
                                                        
                                                        if settings.prefferedColorScheme == "dark" || (settings.prefferedColorScheme == "automatic" && colorScheme == .dark) {
                                                            Color.black.opacity(0.5)
                                                        }
                                                    })
                                                    .cornerRadius(10)
                                                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 0)
                                                }
                                                else {
                                                    Color.clear
                                                        .sheet(isPresented: $variables.tapSidebarShown) {
                                                            ZStack {
#if !os(visionOS)
                                                                if selectedSpaceIndex < spaces.count && (!spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty) {
                                                                    LinearGradient(colors: [Color(hex: spaces[selectedSpaceIndex].startHex), Color(hex: spaces[selectedSpaceIndex].endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                                }
                                                                else {
                                                                    LinearGradient(colors: [variables.startColor, variables.endColor], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                                }
#endif
                                                                
                                                                if settings.prefferedColorScheme == "dark" || (settings.prefferedColorScheme == "automatic" && colorScheme == .dark) {
                                                                    Color.black.opacity(0.5)
                                                                }
                                                                
                                                                VStack {
                                                                    ToolbarButtonsView(selectedTabLocation: $variables.selectedTabLocation, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $variables.searchInSidebar, commandBarShown: $variables.commandBarShown, tabBarShown: $variables.tabBarShown, startColor: $variables.startColor, endColor: $variables.endColor, textColor: $variables.textColor, geo: geo).frame(height: 40)
                                                                        .padding([.top, .horizontal], 5)
                                                                    
                                                                    SidebarSpaceParameter(currentSelectedSpaceIndex: variables.selectedSpaceIndex, selectedTabLocation: $variables.selectedTabLocation, hideSidebar: $hideSidebar, searchInSidebar: $variables.searchInSidebar, commandBarShown: $variables.commandBarShown, tabBarShown: $variables.tabBarShown, startColor: $variables.startColor, endColor: $variables.endColor, textColor: $variables.textColor, hoverSpace: $variables.hoverSpace, showSettings: $variables.showSettings, geo: geo)
                                                                    
                                                                    HStack {
                                                                        Button {
                                                                            variables.showSettings.toggle()
                                                                        } label: {
                                                                            ZStack {
                                                                                HoverButtonDisabledVision(hoverInteraction: $variables.settingsButtonHover)
                                                                                
                                                                                Image(systemName: "gearshape")
                                                                                    .resizable()
                                                                                    .scaledToFit()
                                                                                    .frame(width: 20, height: 20)
                                                                                    .foregroundStyle(variables.textColor)
                                                                                    .opacity(variables.settingsButtonHover ? 1.0: 0.5)
                                                                                
                                                                            }.frame(width: 40, height: 40).cornerRadius(7)
#if !os(visionOS) && !os(macOS)
                                                                                .hoverEffect(.lift)
                                                                                .hoverEffectDisabled(!settings.hoverEffectsAbsorbCursor)
#endif
                                                                                .onHover(perform: { hovering in
                                                                                    if hovering {
                                                                                        variables.settingsButtonHover = true
                                                                                    }
                                                                                    else {
                                                                                        variables.settingsButtonHover = false
                                                                                    }
                                                                                })
                                                                        }
                                                                        .sheet(isPresented: $variables.showSettings) {
                                                                            if #available(iOS 18.0, visionOS 2.0, *) {
                                                                                NewSettings(presentSheet: $variables.showSettings, startHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].startHex: startHex, endHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].endHex: endHex)
                                                                                    .presentationSizing(.form)
                                                                            } else {
                                                                                NewSettings(presentSheet: $variables.showSettings, startHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].startHex: startHex, endHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].endHex: endHex)
                                                                            }
                                                                        }
                                                                        Spacer()
                                                                        
                                                                        SpacePicker(navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, currentSpace: $currentSpace, selectedSpaceIndex: $selectedSpaceIndex)
                                                                        
                                                                        Button(action: {
                                                                            modelContext.insert(SpaceStorage(spaceIndex: spaces.count, spaceName: "Untitled \(spaces.count)", spaceIcon: "scribble.variable", favoritesUrls: [], pinnedUrls: [], tabUrls: []))
                                                                        }, label: {
                                                                            ZStack {
#if !os(visionOS)
                                                                                Color(.white)
                                                                                    .opacity(variables.hoverSpace == "veryLongTextForHoveringOnPlusSignSoIDontHaveToUseAnotherVariable" ? 0.5: 0.0)
#endif
                                                                                
                                                                                Image(systemName: "plus")
                                                                                    .resizable()
                                                                                    .scaledToFit()
                                                                                    .frame(width: 20, height: 20)
                                                                                    .foregroundStyle(variables.textColor)
                                                                                    .opacity(variables.hoverSpace == "veryLongTextForHoveringOnPlusSignSoIDontHaveToUseAnotherVariable" ? 1.0: 0.5)
                                                                                
                                                                            }.frame(width: 40, height: 40).cornerRadius(7)
#if !os(visionOS) && !os(macOS)
                                                                                .hoverEffect(.lift)
                                                                                .hoverEffectDisabled(!settings.hoverEffectsAbsorbCursor)
#endif
                                                                                .onHover(perform: { hovering in
                                                                                    if hovering {
                                                                                        variables.hoverSpace = "veryLongTextForHoveringOnPlusSignSoIDontHaveToUseAnotherVariable"
                                                                                    }
                                                                                    else {
                                                                                        variables.hoverSpace = ""
                                                                                    }
                                                                                })
                                                                        })
                                                                    }
                                                                }
                                                                .padding(15)
                                                                .frame(width: 300)
                                                                .cornerRadius(10)
                                                            }
                                                        }
                                                }
                                                
                                                Spacer()
                                            }.padding(40)
                                                .padding(.leading, 30)
                                                .frame(width: variables.hoveringSidebar || variables.tapSidebarShown ? 350: 0)
                                                .offset(x: variables.hoveringSidebar || variables.tapSidebarShown ? 0: settings.sidebarLeft ? -350: 300)
                                                .clipped()
                                            
                                        }.onHover(perform: { hovering in
                                            if hovering {
                                                variables.hoveringSidebar = true
                                            }
                                            else {
                                                variables.hoveringSidebar = false
                                            }
                                        })
                                        
                                        if settings.sidebarLeft {
                                            Spacer()
                                        }
                                    }.animation(.default)
                                }
                            }
                            .onOpenURL { url in
                                if url.absoluteString.starts(with: "aura://") {
                                    //variables.navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: "https\(url.absoluteString.dropFirst(4))")!))
                                }
                                else {
                                    //variables.navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: url.absoluteString)!))
                                    
                                    spaces[selectedSpaceIndex].tabUrls.append(url.absoluteString)
                                }
                                print("Url:")
                                print(url)
                            }
                            //MARK: - Tabbar
                            if variables.tabBarShown {
                                CommandBar(commandBarText: $variables.newTabSearch, searchSubmitted: $variables.commandBarSearchSubmitted, collapseHeightAnimation: $variables.commandBarCollapseHeightAnimation, isBrowseForMe: $variables.isBrowseForMe)
                                    .onChange(of: variables.commandBarSearchSubmitted) {
                                        
                                        print("Search submitted")
                                        
                                        variables.browseForMeSearch = variables.newTabSearch
                                        
                                        if !variables.newTabSearch.starts(with: "aura://") {
                                            variables.auraTab = ""
                                            //variables.navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: formatURL(from: variables.newTabSearch))!))
                                            
                                            print(variables.newTabSearch)
                                            
                                            var temporaryUrls = spaces[selectedSpaceIndex].tabUrls
                                            
                                            print("temporaryUrls:")
                                            print(temporaryUrls)
                                            
                                            let formattedUrl = formatURL(from: variables.newTabSearch)
                                            
                                            print("formattedUrl:")
                                            print(formattedUrl)
                                            
                                            temporaryUrls.append(formattedUrl)
                                            
                                            print("temporaryUrls - changed:")
                                            print(temporaryUrls)
                                            spaces[selectedSpaceIndex].tabUrls = temporaryUrls
                                            
                                            print("tabUrls:")
                                            print(spaces[selectedSpaceIndex].tabUrls)
                                            
                                            do {
                                                try modelContext.save()
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                            print(spaces[selectedSpaceIndex].tabUrls)
                                        }
                                        else {
                                            if variables.newTabSearch.contains("dashboard") {
                                                variables.navigationState.selectedWebView = nil
                                                variables.pinnedNavigationState.selectedWebView = nil
                                                variables.favoritesNavigationState.selectedWebView = nil
                                                
                                                variables.auraTab = "dashboard"
                                                variables.selectedTabLocation = ""
                                            }
                                            if variables.newTabSearch.contains("settings") {
                                                variables.showSettings = true
                                            }
                                        }
                                        
                                        variables.tabBarShown = false
                                        variables.commandBarSearchSubmitted = false
                                        variables.newTabSearch = ""
                                        
                                        print("Saving Tabs")
                                        
                                        //saveSpaceData()
                                    }
                                //}
                            }
                            
                            //MARK: - Command Bar
                            else if variables.commandBarShown {
                                CommandBar(commandBarText: $variables.searchInSidebar, searchSubmitted: $variables.commandBarSearchSubmitted2, collapseHeightAnimation: $variables.commandBarCollapseHeightAnimation, isBrowseForMe: $variables.isBrowseForMe)
                                    .onChange(of: variables.navigationState.currentURL, {
                                        if let unwrappedURL = variables.navigationState.currentURL {
                                            variables.searchInSidebar = unwrappedURL.absoluteString
                                        }
                                        print("Changing searchInSidebar - 1")
                                    })
                                    .onChange(of: variables.pinnedNavigationState.currentURL, {
                                        if let unwrappedURL = variables.pinnedNavigationState.currentURL {
                                            variables.searchInSidebar = unwrappedURL.absoluteString
                                        }
                                        print("Changing searchInSidebar - 2")
                                    })
                                    .onChange(of: variables.favoritesNavigationState.currentURL, {
                                        if let unwrappedURL = variables.favoritesNavigationState.currentURL {
                                            variables.searchInSidebar = unwrappedURL.absoluteString
                                        }
                                        print("Changing searchInSidebar - 3")
                                    })
                                    .onChange(of: variables.commandBarSearchSubmitted2) { thing in
                                        
                                        //variables.navigationState.currentURL = URL(string: formatURL(from: newTabSearch))!
                                        //variables.navigationState.selectedWebView?.load(URLRequest(url: URL(formatURL(from: newTabSearch))!))
                                        Task {
                                            await variables.searchInSidebar = formatURL(from: variables.searchInSidebar)
                                            if let url = URL(string: variables.searchInSidebar) {
                                                // Create a URLRequest object
                                                let request = URLRequest(url: url)
                                                
                                                if variables.selectedTabLocation == "tabs" {
                                                    await variables.navigationState.selectedWebView?.load(request)
                                                }
                                                if variables.selectedTabLocation == "pinnedTabs" {
                                                    await variables.pinnedNavigationState.selectedWebView?.load(request)
                                                }
                                                if variables.selectedTabLocation == "favoriteTabs" {
                                                    await variables.favoritesNavigationState.selectedWebView?.load(request)
                                                }
                                                
                                                print("Updated URL String")
                                            } else {
                                                print("Invalid URL string")
                                            }
                                        }
                                        
                                        
                                        variables.commandBarShown = false
                                        variables.tabBarShown = false
                                        variables.commandBarSearchSubmitted2 = false
                                        variables.newTabSearch = ""
                                    }
                            }
                            
                            
                            if launchingAnimation && settings.launchAnimation {
                                Launch_Animation()
                            }
                        }
                        /*.sheet(isPresented: $isBrowseForMe, content: {
                         VStack {
                         if UIDevice.current.userInterfaceIdiom != .phone {
                         BrowseForMe(searchText: newTabSearch, searchResponse: "", closeSheet: $isBrowseForMe)
                         .frame(width: geo.size.width * 0.7, height: geo.size.height * 0.9)
                         .onDisappear() {
                         isBrowseForMe = false
                         newTabSearch = ""
                         commandBarShown = false
                         tabBarShown = false
                         commandBarSearchSubmitted = false
                         commandBarSearchSubmitted2 = false
                         }
                         }
                         else {
                         BrowseForMe(searchText: newTabSearch, searchResponse: "", closeSheet: $isBrowseForMe)
                         .onDisappear() {
                         isBrowseForMe = false
                         newTabSearch = ""
                         commandBarShown = false
                         tabBarShown = false
                         commandBarSearchSubmitted = false
                         commandBarSearchSubmitted2 = false
                         }
                         }
                         }
                         .interactiveDismissDisabled(true)
                         })*/
                        .onAppear() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4.6, execute: {
                                
                            })
                        }
                        .onChange(of: selectedSpaceIndex, {
                            if variables.initialLoadDone {
                                variables.navigationState.webViews.removeAll()
                                
                                var reloadAuraTabs = variables.auraTab
                                variables.auraTab = ""
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.00001) {
                                    variables.auraTab = reloadAuraTabs
                                }
                                
                                if selectedSpaceIndex < spaces.count {
                                    if !spaces[selectedSpaceIndex].startHex.isEmpty && !spaces[selectedSpaceIndex].endHex.isEmpty {
                                        startHex = spaces[selectedSpaceIndex].startHex
                                        endHex = spaces[selectedSpaceIndex].startHex
                                        
                                        variables.startColor = Color(hex: spaces[selectedSpaceIndex].startHex)
                                        variables.endColor = Color(hex: spaces[selectedSpaceIndex].endHex)
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
                                    
                                    variables.startColor = Color(hex: spaces[selectedSpaceIndex].startHex)
                                    variables.endColor = Color(hex: spaces[selectedSpaceIndex].endHex)
                                }
                            }
                            
                            variables.initialLoadDone = true
                        }
                        
                        
                        .ignoresSafeArea()
                    }
                }.task {
                    if spaces.count <= 0 {
                        await modelContext.insert(SpaceStorage(spaceIndex: spaces.count, spaceName: "Untitled", spaceIcon: "circle.fill", favoritesUrls: [], pinnedUrls: [], tabUrls: []))
                    }
                }
            }
            else {
                NavigationStack {
                    TabOverview(selectedSpaceIndex: $selectedSpaceIndex)
                }
            }

            
        }.environmentObject(variables)
            .environmentObject(manager)
            .environmentObject(settings)
        
    }
    
    func saveSpaceData() {
        Task {
            do {
                try await modelContext.save()
                print("modelContext Saved")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    func validateHTMLResult(thing: String) {
        if removeHeadContent(from: thing) == "<html><body></body></html>" {
            if htmlInspectTimeoutCounter <= 5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    htmlInspectTimeoutCounter += 1
                    validateHTMLResult(thing: thing)
                })
            }
        }
        else {
            inspectCodeString = removeHeadContent(from: thing)
        }
    }
    
    private func loadingIndicators(for isLoading: Bool?) -> some View {
        Group {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .trim(from: 0.25 + variables.offset, to: 0.5 + variables.offset)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundColor(selectedSpaceIndex < spaces.count ? Color(hex: spaces[selectedSpaceIndex].startHex) : .blue)
                .opacity(isLoading ?? false ? 1.0 : 0.0)
                .animation(.default, value: isLoading ?? false)
                .blur(radius: 5)
            
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .trim(from: 0.25 + variables.offset, to: 0.5 + variables.offset)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotation(Angle(degrees: 180))
                .foregroundColor(selectedSpaceIndex < spaces.count ? Color(hex: spaces[selectedSpaceIndex].startHex) : .blue)
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
                .fill(variables.navigationArrowColor ? Color(.systemBlue) : Color.gray)
                .shadow(color: Color(.systemBlue), radius: variables.navigationArrowColor ? 10 : 0, x: 0, y: 0)
            
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .padding(12)
                .scaleEffect(variables.navigationArrowColor ? 1.0 : 0.7)
                .foregroundStyle(Color.white)
            
        }.frame(width: 50, height: 50)
            .gesture(TapGesture().onEnded(action))
    }
    
    private func handleDragChange(_ value: DragGesture.Value) {
        let newOffset = value.translation.width
        if abs(newOffset) <= 150 {
            variables.navigationOffset = newOffset
        } else {
            variables.navigationOffset = newOffset > 0 ? 150 : -150
        }
        if abs(newOffset) > 100 {
            withAnimation(.linear(duration: 0.3)) {
                variables.navigationArrowColor = true
            }
        } else {
            withAnimation(.linear(duration: 0.3)) {
                variables.navigationArrowColor = false
            }
        }
    }
    
    private func handleDragEnd() {
        if variables.navigationOffset >= 100 {
            goBack()
        } else if variables.navigationOffset < -100 {
            goForward()
        }
        
        withAnimation(.linear(duration: 0.25)) {
            variables.navigationOffset = 0
            variables.navigationArrowColor = false
        }
    }
    
    private func handleRotation() {
        if variables.offset == 0.5 {
            variables.offset = 0.0
            withAnimation(.linear(duration: 1.5)) {
                variables.offset = 0.5
            }
        } else {
            withAnimation(.linear(duration: 1.5)) {
                variables.offset = 0.5
            }
        }
    }
    
    private func goBack() {
        manager.selectedWebView?.webView.goBack()
    }
    
    private func goForward() {
        manager.selectedWebView?.webView.goForward()
    }
    
    func favoriteRemoveTab(at index: Int) {
        var temporaryUrls = spaces[manager.selectedSpaceIndex].favoritesUrls
        
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
        
        spaces[manager.selectedSpaceIndex].favoritesUrls = temporaryUrls
        
        do {
            try modelContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func pinnedRemoveTab(at index: Int) {
        var temporaryUrls = spaces[manager.selectedSpaceIndex].pinnedUrls
        
        temporaryUrls.remove(at: index)
        
        spaces[manager.selectedSpaceIndex].pinnedUrls = temporaryUrls
        
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
        var temporaryUrls = spaces[manager.selectedSpaceIndex].tabUrls
        
        print("Removing Tab:")
        print(temporaryUrls)
        
        temporaryUrls.remove(at: index)
        
        print(temporaryUrls)
        
        spaces[manager.selectedSpaceIndex].tabUrls = temporaryUrls
        
        print(spaces[manager.selectedSpaceIndex].tabUrls)
        
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
        
        //saveSpaceData()
    }
}
