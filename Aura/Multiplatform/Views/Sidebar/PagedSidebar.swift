//
//  PagedSidebar.swift
//  Aura
//
//  Created by Reyna Myers on 24/5/24.
//

import SwiftUI
import SwiftData
import WebKit

struct PagedSidebar: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    
    @EnvironmentObject var variables: ObservableVariables
    @StateObject var settings = SettingsVariables()
    
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
    @Binding var textColor: Color
    @Binding var hoverSpace: String
    @Binding var showSettings: Bool
    //var geo: GeometryProxy
    
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
    
    //@State private var showSettings = false
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
    @AppStorage("sidebarLeft") var sidebarLeft = true
    
    @AppStorage("selectedSpaceIndex") var selectedSpaceIndex = 0
    
    @State var hoverPaintbrush = false
    
    // Selection States
    @State private var changingIcon = ""
    @State private var draggedTab: WKWebView?
    
    @State var showPaintbrush = false
    
    @State var scrollLimiter = false
    @State var scrollPositionOffset = 0.0
    
    @State var appearOffset = 0.0
    
    @State private var scrollPosition: CGPoint = .zero
    @State private var horizontalScrollPosition: CGPoint = .zero
    
    @AppStorage("showBorder") var showBorder = true
    
    @State var hasSetThing = false
    
    var fullGeo: GeometryProxy
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                ToolbarButtonsView(selectedTabLocation: $selectedTabLocation, navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, hideSidebar: $hideSidebar, searchInSidebar: $searchInSidebar, commandBarShown: $commandBarShown, tabBarShown: $tabBarShown, startColor: $startColor, endColor: $endColor, textColor: $textColor, geo: geo).frame(height: 40)
                    .padding([.top, .horizontal], 5)
                
                
                ScrollViewReader { proxy in
                    ScrollView(.horizontal) {
                        HStack(spacing: 0) {
                            ForEach(0..<spaces.count, id:\.self) { space in
                                VStack {
                                    SidebarSpaceParameter(currentSelectedSpaceIndex: space, geo: geo)
                                        .environmentObject(variables)
                                        .id(space.description)
                                        .padding(.horizontal, 10)
                                    
                                    // Variables to test offset of scrolling between spaces
                                    //Text(horizontalScrollPosition.x.description)
                                }
                                .containerRelativeFrame(.horizontal)
                                .animation(.easeOut)
                                .frame(width: hideSidebar ? 0: 300)
                            }
                        }.scrollTargetLayout()
                            .onAppear() {
                                appearOffset = scrollPositionOffset
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    proxy.scrollTo(selectedSpaceIndex.description)
                                }
                            }
                            .onChange(of: selectedSpaceIndex, {
                                withAnimation(.linear(duration: 10.0)) {
                                    proxy.scrollTo(selectedSpaceIndex.description)
                                }
                            })
                            .background(GeometryReader { geometry in
                                Color.clear
                                    .ignoresSafeArea()
                                    .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
                            })
                            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                if !hasSetThing {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                        scrollPositionOffset = value.x
                                    }
                                    hasSetThing = true
                                }
                                
                                //self.horizontalScrollPosition.x = value.x - 20
                                self.horizontalScrollPosition.x = ((Double(value.x - scrollPositionOffset).rounded(.toNearestOrAwayFromZero))/100) * 100
                                
                                
                                if ((Int((abs(horizontalScrollPosition.x)) / 10) * 10) % 300 == 0) && !scrollLimiter {
                                //if !scrollLimiter && spaces.count - 1 >= Int(abs(horizontalScrollPosition.x) / 300) {
                                    Task {
                                        await selectedSpaceIndex = Int((abs(horizontalScrollPosition.x) / 300))
                                    }
                                    
                                    currentSpace = String(spaces[Int(abs(horizontalScrollPosition.x) / 300)].spaceName)
                                    
                                    selectedSpaceIndex = Int((abs(horizontalScrollPosition.x)/100).rounded(.toNearestOrAwayFromZero) * 100 / 300)
                                    
                                    scrollLimiter = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        scrollLimiter = false
                                        selectedSpaceIndex = Int((abs(horizontalScrollPosition.x)/100).rounded(.toNearestOrAwayFromZero) * 100 / 300)
                                    }
                                    
                                }
                            }
                    }
                }
                
                HStack {
                    Button {
                        showSettings.toggle()
                    } label: {
                        ZStack {
                            HoverButtonDisabledVision(hoverInteraction: $settingsButtonHover)
                            
                            Image(systemName: "gearshape")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(textColor)
                                .opacity(settingsButtonHover ? 1.0: 0.5)
                            
                        }.frame(width: 40, height: 40).cornerRadius(7)
#if !os(visionOS) && !os(macOS)
                            .hoverEffect(.lift)
                            .hoverEffectDisabled(!hoverEffectsAbsorbCursor)
                        #endif
                            .onHover(perform: { hovering in
                                if hovering {
                                    settingsButtonHover = true
                                }
                                else {
                                    settingsButtonHover = false
                                }
                            })
                    }.buttonStyle(.plain)
                    .sheet(isPresented: $showSettings) {
                        if #available(iOS 18.0, visionOS 2.0, *) {
                            NewSettings(presentSheet: $showSettings, startHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].startHex: startHex, endHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].endHex: endHex)
                                .presentationSizing(.form)
                        } else {
                            NewSettings(presentSheet: $showSettings, startHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].startHex: startHex, endHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].endHex: endHex)
                        }
                    }
                    Spacer()
                    
                    SpacePicker(navigationState: navigationState, pinnedNavigationState: pinnedNavigationState, favoritesNavigationState: favoritesNavigationState, currentSpace: $currentSpace, selectedSpaceIndex: $selectedSpaceIndex)
                    
                    Menu(content: {
                        Button(action: {
                            modelContext.insert(SpaceStorage(spaceIndex: spaces.count, spaceName: "Untitled \(spaces.count)", spaceIcon: "scribble.variable", favoritesUrls: [], pinnedUrls: [], tabUrls: []))
                        }, label: {
                            Label("Add Space", systemImage: "square.badge.plus")
                        })
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
                    }).buttonStyle(.plain)
                }
            }
        }.ignoresSafeArea()
            .frame(width: hideSidebar ? 0: 300)
            .offset(x: hideSidebar ? 320 * (sidebarLeft ? -1: 1): 0)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .scrollIndicators(.hidden)
    }
}
