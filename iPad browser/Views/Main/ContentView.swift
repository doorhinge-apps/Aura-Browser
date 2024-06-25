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
    @StateObject private var boostStore = BoostStore()
    
    @AppStorage("currentSpace") var currentSpace = "Untitled"

        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        let rotationTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()

        @AppStorage("startColorHex") var startHex = "8A3CEF"
        @AppStorage("endColorHex") var endHex = "84F5FE"
        @AppStorage("textColorHex") var textHex = "ffffff"

        
    @State var boostEditor = false
    
    @AppStorage("hideSidebar") var hideSidebar = false
    
    
    @FocusState private var focusedField: FocusedField?
    
    @AppStorage("selectedSpaceIndex") var selectedSpaceIndex = 0
    
    enum FocusedField {
        case commandBar, tabBar, none
    }
    
    @State var browseForMeSearch = ""
    
    @State var launchingAnimation = true
    
    var body: some View {
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
                            if settings.sidebarLeft {
                                if settings.showBorder {
                                    ThreeDots(hoverTinySpace: $variables.hoverTinySpace, hideSidebar: $hideSidebar)
                                        .disabled(true)
                                }
                                
                                if settings.swipingSpaces {
                                    PagedSidebar(selectedTabLocation: $variables.selectedTabLocation, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $variables.searchInSidebar, commandBarShown: $variables.commandBarShown, tabBarShown: $variables.tabBarShown, startColor: $variables.startColor, endColor: $variables.endColor, textColor: $variables.textColor, hoverSpace: $variables.hoverSpace, showSettings: $variables.showSettings, fullGeo: geo)
                                        .environmentObject(variables)
                                }
                                else {
                                    VStack {
                                        ToolbarButtonsView(selectedTabLocation: $variables.selectedTabLocation, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $variables.searchInSidebar, commandBarShown: $variables.commandBarShown, tabBarShown: $variables.tabBarShown, startColor: $variables.startColor, endColor: $variables.endColor, textColor: $variables.textColor, geo: geo).frame(height: 40)
                                            .padding([.top, .horizontal], 5)
                                        
                                        Sidebar(selectedTabLocation: $variables.selectedTabLocation, hideSidebar: $hideSidebar, searchInSidebar: $variables.searchInSidebar, commandBarShown: $variables.commandBarShown, tabBarShown: $variables.tabBarShown, startColor: $variables.startColor, endColor: $variables.endColor, textColor: $variables.textColor, hoverSpace: $variables.hoverSpace, showSettings: $variables.showSettings, geo: geo)
                                            .environmentObject(variables)
                                        
                                        HStack {
                                            Button {
                                                variables.showSettings.toggle()
                                            } label: {
                                                ZStack {
                                                    HoverButtonDisabledVision(hoverInteraction: variables.settingsButtonHover)
                                                    
                                                    Image(systemName: "gearshape")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 20, height: 20)
                                                        .foregroundStyle(variables.textColor)
                                                        .opacity(variables.settingsButtonHover ? 1.0: 0.5)
                                                    
                                                }.frame(width: 40, height: 40).cornerRadius(7)
#if !os(visionOS)
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
                                                NewSettings(presentSheet: $variables.showSettings, startHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].startHex: startHex, endHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].endHex: endHex)
                                                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? .infinity: geo.size.width - 200,
                                                           height: UIDevice.current.userInterfaceIdiom == .phone ? .infinity: geo.size.height - 100)
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
#if !os(visionOS)
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
                                    }.frame(width: 300)
                                }
                            }
                            
                            HStack {
                                GeometryReader { webGeo in
                                    ZStack {
                                        Color.white
                                            .opacity(0.4)
                                            .cornerRadius(10)
                                        
                                        
                                        //MARK: - WebView
                                        if variables.selectedTabLocation == "favoriteTabs" {
                                            ScrollView(showsIndicators: false) {
                                                WebView(navigationState: variables.favoritesNavigationState, variables: variables)
                                                    .frame(width: webGeo.size.width, height: webGeo.size.height)
                                            }
                                            
                                            loadingIndicators(for: variables.favoritesNavigationState.selectedWebView?.isLoading)
                                        }
                                        if variables.selectedTabLocation == "tabs" {
                                            ScrollView(showsIndicators: false) {
                                                WebView(navigationState: variables.navigationState, variables: variables)
                                                    .frame(width: webGeo.size.width, height: webGeo.size.height)
                                            }
                                            .refreshable {
                                                variables.reloadRotation += 360
                                                
                                                variables.navigationState.selectedWebView?.reload()
                                            }
                                            
                                            
                                            loadingIndicators(for: variables.navigationState.selectedWebView?.isLoading)
                                        }
                                        if variables.selectedTabLocation == "pinnedTabs" {
                                            ScrollView(showsIndicators: false) {
                                                WebView(navigationState: variables.pinnedNavigationState, variables: variables)
                                                    .frame(width: webGeo.size.width, height: webGeo.size.height)
                                            }
                                            
                                            
                                            loadingIndicators(for: variables.pinnedNavigationState.selectedWebView?.isLoading)
                                        }
                                        
                                        if !settings.swipeNavigationDisabled {
                                            if (variables.selectedTabLocation == "favoriteTabs" && variables.favoritesNavigationState.selectedWebView != nil) ||
                                                (variables.selectedTabLocation == "pinnedTabs" && variables.pinnedNavigationState.selectedWebView != nil) ||
                                                (variables.selectedTabLocation == "tabs" && variables.navigationState.selectedWebView != nil) {
                                                HStack(alignment: .center, spacing: 0) {
                                                    navigationButton(imageName: "arrow.left", action: goBack)
                                                        .padding(.trailing, 30)
                                                    
                                                    Spacer()
                                                        .frame(width: webGeo.size.width)
                                                    
                                                    navigationButton(imageName: "arrow.right", action: goForward)
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
                                                    await hideSidebar.toggle()
                                                }
                                                
                                                withAnimation {
                                                    if !hideSidebar {
                                                        if variables.selectedTabLocation == "tabs" {
                                                            Task {
                                                                await variables.navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                                            }
                                                        }
                                                        else if variables.selectedTabLocation == "pinnedTabs" {
                                                            Task {
                                                                await variables.pinnedNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                                            }
                                                        }
                                                        else if variables.selectedTabLocation == "favoriteTabs" {
                                                            Task {
                                                                await variables.favoritesNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                                            }
                                                        }
                                                    } else {
                                                        if variables.selectedTabLocation == "tabs" {
                                                            Task {
                                                                await variables.navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-340, height: geo.size.height))
                                                            }
                                                        }
                                                        else if variables.selectedTabLocation == "pinnedTabs" {
                                                            Task {
                                                                await variables.pinnedNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-340, height: geo.size.height))
                                                            }
                                                        }
                                                        else if variables.selectedTabLocation == "favoriteTabs" {
                                                            Task {
                                                                await variables.favoritesNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-340, height: geo.size.height))
                                                            }
                                                        }
                                                    }
                                                }
                                            } label: {

                                            }.keyboardShortcut("s", modifiers: .command)
                                                .buttonStyle(.plain)
                                            
                                            Button {
                                                if variables.selectedTabLocation == "tabs" {
                                                    variables.navigationState.selectedWebView?.goBack()
                                                }
                                                else if variables.selectedTabLocation == "pinnedTabs" {
                                                    variables.pinnedNavigationState.selectedWebView?.goBack()
                                                }
                                                else if variables.selectedTabLocation == "favoriteTabs" {
                                                    variables.favoritesNavigationState.selectedWebView?.goBack()
                                                }
                                            } label: {
                                                
                                            }.keyboardShortcut("[", modifiers: .command)
                                                .buttonStyle(.plain)
                                            
                                            Button {
                                                if variables.selectedTabLocation == "tabs" {
                                                    variables.navigationState.selectedWebView?.goForward()
                                                }
                                                else if variables.selectedTabLocation == "pinnedTabs" {
                                                    variables.pinnedNavigationState.selectedWebView?.goForward()
                                                }
                                                else if variables.selectedTabLocation == "favoriteTabs" {
                                                    variables.favoritesNavigationState.selectedWebView?.goForward()
                                                }
                                            } label: {

                                            }.keyboardShortcut("]", modifiers: .command)
                                                .buttonStyle(.plain)
                                            
                                            
                                            Button {
                                                variables.reloadRotation += 360
                                                
                                                if variables.selectedTabLocation == "tabs" {
                                                    variables.navigationState.selectedWebView?.reload()
                                                    variables.navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                                    
                                                    variables.navigationState.selectedWebView = variables.navigationState.selectedWebView
                                                    //navigationState.currentURL = navigationState.currentURL
                                                    
                                                    if let unwrappedURL = variables.navigationState.currentURL {
                                                        variables.searchInSidebar = unwrappedURL.absoluteString
                                                    }
                                                }
                                                else if variables.selectedTabLocation == "pinnedTabs" {
                                                    variables.pinnedNavigationState.selectedWebView?.reload()
                                                    variables.pinnedNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                                    
                                                    variables.pinnedNavigationState.selectedWebView = variables.pinnedNavigationState.selectedWebView
                                                    
                                                    if let unwrappedURL = variables.pinnedNavigationState.currentURL {
                                                        variables.searchInSidebar = unwrappedURL.absoluteString
                                                    }
                                                }
                                                else if variables.selectedTabLocation == "favoriteTabs" {
                                                    variables.favoritesNavigationState.selectedWebView?.reload()
                                                    variables.favoritesNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                                    
                                                    variables.favoritesNavigationState.selectedWebView = variables.favoritesNavigationState.selectedWebView
                                                    
                                                    if let unwrappedURL = variables.favoritesNavigationState.currentURL {
                                                        variables.searchInSidebar = unwrappedURL.absoluteString
                                                    }
                                                }
                                            } label: {

                                            }.keyboardShortcut("r", modifiers: .command)
                                                .buttonStyle(.plain)
                                            
                                            
                                            Button {
                                                if (variables.navigationState.selectedWebView == nil) && (variables.pinnedNavigationState.selectedWebView == nil) && (variables.favoritesNavigationState.selectedWebView == nil) {
                                                    variables.tabBarShown.toggle()
                                                    variables.commandBarShown = false
                                                    print("Showing Tab Bar")
                                                }
                                                else {
                                                    if variables.selectedTabLocation == "pinnedTabs" {
                                                        variables.searchInSidebar = unformatURL(url: variables.pinnedNavigationState.selectedWebView?.url?.absoluteString ?? variables.searchInSidebar)
                                                    }
                                                    else if variables.selectedTabLocation == "favoriteTabs" {
                                                        variables.searchInSidebar = unformatURL(url: variables.favoritesNavigationState.selectedWebView?.url?.absoluteString ?? variables.searchInSidebar)
                                                    }else {
                                                        variables.searchInSidebar = unformatURL(url: variables.navigationState.selectedWebView?.url?.absoluteString ?? variables.searchInSidebar)
                                                    }
                                                    variables.commandBarShown.toggle()
                                                    variables.tabBarShown = false
                                                    print("Showing Command Bar")
                                                }
                                            } label: {
                                                
                                            }.keyboardShortcut("l", modifiers: .command)
                                                .buttonStyle(.plain)
                                            
                                            
                                            Button {
                                                if variables.selectedTabLocation == "favoriteTabs" {
                                                    if let index = variables.favoritesNavigationState.webViews.firstIndex(of: variables.favoritesNavigationState.selectedWebView ?? WKWebView()) {
                                                        favoriteRemoveTab(at: index)
                                                    }
                                                }
                                                else if variables.selectedTabLocation == "pinnedTabs" {
                                                    if let index = variables.pinnedNavigationState.webViews.firstIndex(of: variables.pinnedNavigationState.selectedWebView ?? WKWebView()) {
                                                        pinnedRemoveTab(at: index)
                                                    }
                                                }
                                                else if variables.selectedTabLocation == "tabs" {
                                                    if let index = variables.navigationState.webViews.firstIndex(of: variables.navigationState.selectedWebView ?? WKWebView()) {
                                                        removeTab(at: index)
                                                    }
                                                }
                                            } label: {
                                                
                                            }.keyboardShortcut("w", modifiers: .command)
                                                .buttonStyle(.plain)
                                            
                                            
                                            Button {
                                                variables.tabBarShown.toggle()
                                                variables.commandBarShown = false
                                            } label: {
                                                
                                            }.keyboardShortcut("t", modifiers: .command)
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
#if !os(visionOS)
                                                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                                                #endif
                                                                variables.arrowImpactOnce = true
                                                            }
                                                            
                                                            withAnimation(.linear(duration: 0.3)) {
                                                                variables.navigationArrowColor = true
                                                            }
                                                        } else {
                                                            if variables.arrowImpactOnce {
#if !os(visionOS)
                                                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                                                #endif
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
                                    BrowseForMe(searchText: browseForMeSearch, searchResponse: "", closeSheet: $variables.isBrowseForMe)
                                        .frame(width: variables.isBrowseForMe ? 400: 0)
                                        .cornerRadius(10)
                                        .clipped()
                                        .onDisappear() {
                                            variables.isBrowseForMe = false
                                            variables.newTabSearch = ""
                                            variables.commandBarShown = false
                                            variables.tabBarShown = false
                                            variables.commandBarSearchSubmitted = false
                                            variables.commandBarSearchSubmitted2 = false
                                        }
                                        .onChange(of: variables.navigationState.selectedWebView, {
                                            withAnimation(.linear, {
                                                variables.isBrowseForMe = false
                                                browseForMeSearch = ""
                                            })
                                        })
                                        .onChange(of: variables.pinnedNavigationState.selectedWebView, {
                                            withAnimation(.linear, {
                                                variables.isBrowseForMe = false
                                                browseForMeSearch = ""
                                            })
                                        })
                                        .onChange(of: variables.favoritesNavigationState.selectedWebView, {
                                            withAnimation(.linear, {
                                                variables.isBrowseForMe = false
                                                browseForMeSearch = ""
                                            })
                                        })
                                }
                            }.onChange(of: variables.isBrowseForMe, {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                    withAnimation(.linear, {
                                        variables.delayedBrowseForMe = true
                                    })
                                })
                            })
                            .onChange(of: browseForMeSearch, {
                                variables.delayedBrowseForMe = false
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                    withAnimation(.linear, {
                                        variables.delayedBrowseForMe = true
                                    })
                                })
                            })
                            
                            if !settings.sidebarLeft {
                                if settings.showBorder {
                                    ThreeDots(hoverTinySpace: $variables.hoverTinySpace, hideSidebar: $hideSidebar)
                                        .disabled(true)
                                }
                                
                                if settings.swipingSpaces {
                                    PagedSidebar(selectedTabLocation: $variables.selectedTabLocation, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $variables.searchInSidebar, commandBarShown: $variables.commandBarShown, tabBarShown: $variables.tabBarShown, startColor: $variables.startColor, endColor: $variables.endColor, textColor: $variables.textColor, hoverSpace: $variables.hoverSpace, showSettings: $variables.showSettings, fullGeo: geo)
                                        .environmentObject(variables)
                                }
                                else {
                                    VStack {
                                        ToolbarButtonsView(selectedTabLocation: $variables.selectedTabLocation, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $variables.searchInSidebar, commandBarShown: $variables.commandBarShown, tabBarShown: $variables.tabBarShown, startColor: $variables.startColor, endColor: $variables.endColor, textColor: $variables.textColor, geo: geo).frame(height: 40)
                                            .padding([.top, .horizontal], 5)
                                        
                                        Sidebar(selectedTabLocation: $variables.selectedTabLocation, hideSidebar: $hideSidebar, searchInSidebar: $variables.searchInSidebar, commandBarShown: $variables.commandBarShown, tabBarShown: $variables.tabBarShown, startColor: $variables.startColor, endColor: $variables.endColor, textColor: $variables.textColor, hoverSpace: $variables.hoverSpace, showSettings: $variables.showSettings, geo: geo)
                                            .environmentObject(variables)
                                        
                                        HStack {
                                            Button {
                                                variables.showSettings.toggle()
                                            } label: {
                                                ZStack {
                                                    HoverButtonDisabledVision(hoverInteraction: variables.settingsButtonHover)
                                                    
                                                    Image(systemName: "gearshape")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 20, height: 20)
                                                        .foregroundStyle(variables.textColor)
                                                        .opacity(variables.settingsButtonHover ? 1.0: 0.5)
                                                    
                                                }.frame(width: 40, height: 40).cornerRadius(7)
#if !os(visionOS)
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
                                                NewSettings(presentSheet: $variables.showSettings, startHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].startHex: startHex, endHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].endHex: endHex)
                                                    .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? .infinity: geo.size.width - 200,
                                                           height: UIDevice.current.userInterfaceIdiom == .phone ? .infinity: geo.size.height - 100)
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
#if !os(visionOS)
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
                                    }.frame(width: 300)
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
                                .hoverEffectDisabled(true)
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
                                        if UIDevice.current.userInterfaceIdiom != .phone {
                                            VStack {
                                                ToolbarButtonsView(selectedTabLocation: $variables.selectedTabLocation, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $variables.searchInSidebar, commandBarShown: $variables.commandBarShown, tabBarShown: $variables.tabBarShown, startColor: $variables.startColor, endColor: $variables.endColor, textColor: $variables.textColor, geo: geo).frame(height: 40)
                                                    .padding([.top, .horizontal], 5)
                                                
                                                //Sidebar(selectedTabLocation: $selectedTabLocation, navigationState: variables.navigationState, pinnedNavigationState: variables.pinnedNavigationState, favoritesNavigationState: variables.favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, hoverSpace: $hoverSpace, showSettings: $showSettings, geo: geo)
                                                Sidebar(selectedTabLocation: $variables.selectedTabLocation, hideSidebar: $hideSidebar, searchInSidebar: $variables.searchInSidebar, commandBarShown: $variables.commandBarShown, tabBarShown: $variables.tabBarShown, startColor: $variables.startColor, endColor: $variables.endColor, textColor: $variables.textColor, hoverSpace: $variables.hoverSpace, showSettings: $variables.showSettings, geo: geo)
                                                    .environmentObject(variables)
                                                
                                                HStack {
                                                    Button {
                                                        variables.showSettings.toggle()
                                                    } label: {
                                                        ZStack {
                                                            HoverButtonDisabledVision(hoverInteraction: variables.settingsButtonHover)
                                                            
                                                            Image(systemName: "gearshape")
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 20, height: 20)
                                                                .foregroundStyle(variables.textColor)
                                                                .opacity(variables.settingsButtonHover ? 1.0: 0.5)
                                                            
                                                        }.frame(width: 40, height: 40).cornerRadius(7)
#if !os(visionOS)
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
                                                        NewSettings(presentSheet: $variables.showSettings, startHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].startHex: startHex, endHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].endHex: endHex)
                                                            .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? .infinity: geo.size.width - 200,
                                                                   height: UIDevice.current.userInterfaceIdiom == .phone ? .infinity: geo.size.height - 100)
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
        #if !os(visionOS)
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
                                                            
                                                            Sidebar(selectedTabLocation: $variables.selectedTabLocation, hideSidebar: $hideSidebar, searchInSidebar: $variables.searchInSidebar, commandBarShown: $variables.commandBarShown, tabBarShown: $variables.tabBarShown, startColor: $variables.startColor, endColor: $variables.endColor, textColor: $variables.textColor, hoverSpace: $variables.hoverSpace, showSettings: $variables.showSettings, geo: geo)
                                                                .environmentObject(variables)
                                                            
                                                            HStack {
                                                                Button {
                                                                    variables.showSettings.toggle()
                                                                } label: {
                                                                    ZStack {
                                                                        HoverButtonDisabledVision(hoverInteraction: variables.settingsButtonHover)
                                                                        
                                                                        Image(systemName: "gearshape")
                                                                            .resizable()
                                                                            .scaledToFit()
                                                                            .frame(width: 20, height: 20)
                                                                            .foregroundStyle(variables.textColor)
                                                                            .opacity(variables.settingsButtonHover ? 1.0: 0.5)
                                                                        
                                                                    }.frame(width: 40, height: 40).cornerRadius(7)
#if !os(visionOS)
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
                                                                    NewSettings(presentSheet: $variables.showSettings, startHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].startHex: startHex, endHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].endHex: endHex)
                                                                        .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? .infinity: geo.size.width - 200,
                                                                               height: UIDevice.current.userInterfaceIdiom == .phone ? .infinity: geo.size.height - 100)
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
                    #if !os(visionOS)
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
                            variables.navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: "https\(url.absoluteString.dropFirst(4))")!))
                        }
                        else {
                            variables.navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: url.absoluteString)!))
                        }
                        print("Url:")
                        print(url)
                    }
                    //MARK: - Tabbar
                    if variables.tabBarShown {
                        CommandBar(commandBarText: $variables.newTabSearch, searchSubmitted: $variables.commandBarSearchSubmitted, collapseHeightAnimation: $variables.commandBarCollapseHeightAnimation, isBrowseForMe: $variables.isBrowseForMe)
                            .onChange(of: variables.commandBarSearchSubmitted) { thing in
                                
                                browseForMeSearch = variables.newTabSearch
                                
                                if !variables.newTabSearch.starts(with: "aura://") {
                                    variables.auraTab = ""
                                    variables.navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: formatURL(from: variables.newTabSearch))!))
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
                                
                                saveSpaceData()
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
                                    
                                    saveSpaceData()
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
                    
                    variables.initialLoadDone = true
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
        if variables.selectedTabLocation == "tabs" {
            variables.navigationState.selectedWebView?.goBack()
        } else if variables.selectedTabLocation == "pinnedTabs" {
            variables.pinnedNavigationState.selectedWebView?.goBack()
        } else if variables.selectedTabLocation == "favoriteTabs" {
            variables.favoritesNavigationState.selectedWebView?.goBack()
        }
    }

    private func goForward() {
        if variables.selectedTabLocation == "tabs" {
            variables.navigationState.selectedWebView?.goForward()
        } else if variables.selectedTabLocation == "pinnedTabs" {
            variables.pinnedNavigationState.selectedWebView?.goForward()
        } else if variables.selectedTabLocation == "favoriteTabs" {
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
