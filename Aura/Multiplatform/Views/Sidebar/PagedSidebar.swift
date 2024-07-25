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
    @EnvironmentObject var settings: SettingsVariables
    
    @AppStorage("currentSpace") var currentSpace = "Untitled"
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var startHex = "ffffff"
    @State private var endHex = "000000"
    
    @State private var settingsButtonHover = false
    
    @AppStorage("selectedSpaceIndex") var selectedSpaceIndex = 0
    
    @State var scrollLimiter = false
    @State var scrollPositionOffset = 0.0
    
    @State var appearOffset = 0.0
    
    @State private var scrollPosition: CGPoint = .zero
    @State private var horizontalScrollPosition: CGPoint = .zero
    
    @State var hasSetThing = false
    
    var fullGeo: GeometryProxy
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                ToolbarButtonsView(geo: geo)
                    .frame(height: 40)
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
                                .frame(width: variables.hideSidebar ? 0: 300)
                            }
                        }.scrollTargetLayout()
                            .onAppear() {
                                appearOffset = scrollPositionOffset
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    proxy.scrollTo(selectedSpaceIndex.description)
                                }
                            }
                            .onChange(of: selectedSpaceIndex, {
                                proxy.scrollTo(selectedSpaceIndex.description)
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
                        variables.showSettings.toggle()
                    } label: {
                        ZStack {
                            HoverButtonDisabledVision(hoverInteraction: $settingsButtonHover)
                            
                            Image(systemName: "gearshape")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(variables.textColor)
                                .opacity(settingsButtonHover ? 1.0: 0.5)
                            
                        }.frame(width: 40, height: 40).cornerRadius(7)
#if !os(visionOS) && !os(macOS)
                            .hoverEffect(.lift)
                            .hoverEffectDisabled(!settings.hoverEffectsAbsorbCursor)
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
                        .sheet(isPresented: $variables.showSettings) {
                        if #available(iOS 18.0, visionOS 2.0, *) {
                            NewSettings(presentSheet: $variables.showSettings, startHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].startHex: startHex, endHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].endHex: endHex)
                                .presentationSizing(.form)
                        } else {
                            NewSettings(presentSheet: $variables.showSettings, startHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].startHex: startHex, endHex: (!spaces[selectedSpaceIndex].startHex.isEmpty) ? spaces[selectedSpaceIndex].endHex: endHex)
                        }
                    }
                    
                    Spacer()
                    
                    SpacePicker(currentSpace: $currentSpace, selectedSpaceIndex: $selectedSpaceIndex)
                    
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
            .frame(width: variables.hideSidebar ? 0: 300)
            .offset(x: variables.hideSidebar ? 320 * (settings.sidebarLeft ? -1: 1): 0)
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .scrollIndicators(.hidden)
    }
}
