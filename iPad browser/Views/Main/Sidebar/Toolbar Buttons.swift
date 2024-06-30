//
//  Toolbar Buttons.swift
//  iPad browser
//
//  Created by Caedmon Myers on 19/4/24.
//

import SwiftUI
import WebKit
import SwiftData

struct ToolbarButtonsView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    
    @StateObject var variables = ObservableVariables()
    
    @Binding var selectedTabLocation: String
    @ObservedObject var navigationState: NavigationState
    @ObservedObject var pinnedNavigationState: NavigationState
    @ObservedObject var favoritesNavigationState: NavigationState
    @Binding var hideSidebar: Bool
    @Binding var searchInSidebar: String
    
    @State var hoverSidebarButton = false
    @State var hoverPaintbrush = false
    @State var hoverNewTab = false
    @State var hoverBackwardButton = false
    @State var hoverForwardButton = false
    @State var hoverReloadButton = false
    @State var hoverSidebarSearchField = false
    @State var reloadRotation = 0
    @State var newTabSearch = ""
    
    
    @State var reloadTitles = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var changeColorSheet = false
    
    @Binding var commandBarShown: Bool
    @Binding var tabBarShown: Bool
    
    @State var showColorSheet = false
    
    @Binding var startColor: Color
    @Binding var endColor: Color
    @Binding var textColor: Color
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = true
    @AppStorage("sidebarLeft") var sidebarLeft = true
    
    @AppStorage("selectedSpaceIndex") var selectedSpaceIndex = 0
    
    @State var geo: GeometryProxy
    var body: some View {
        GeometryReader { geo2 in
            HStack {
                if ProcessInfo.processInfo.isMacCatalystApp && !hideSidebar && sidebarLeft {
                    Spacer()
                        .frame(width: 65)
                }
                
                #if os(macOS)
                if !hideSidebar && sidebarLeft {
                    Spacer()
                        .frame(width: 65)
                }
                #endif
                

                    Button(action: {
                        Task {
                            await hideSidebar.toggle()
                        }
                        
                        withAnimation {
                            if !hideSidebar {
                                if selectedTabLocation == "tabs" {
                                    Task {
                                        await navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                    }
                                }
                                else if selectedTabLocation == "pinnedTabs" {
                                    Task {
                                        await pinnedNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                    }
                                }
                                else if selectedTabLocation == "favoriteTabs" {
                                    Task {
                                        await favoritesNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                                    }
                                }
                            } else {
                                if selectedTabLocation == "tabs" {
                                    Task {
                                        await navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-340, height: geo.size.height))
                                    }
                                }
                                else if selectedTabLocation == "pinnedTabs" {
                                    Task {
                                        await pinnedNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-340, height: geo.size.height))
                                    }
                                }
                                else if selectedTabLocation == "favoriteTabs" {
                                    Task {
                                        await favoritesNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-340, height: geo.size.height))
                                    }
                                }
                            }
                        }
                    }, label: {
                        ZStack {
                            HoverButtonDisabledVision(hoverInteraction: $hoverSidebarButton)
                            
                            Image(systemName: "sidebar.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundStyle(textColor)
                                .opacity(hoverSidebarButton ? 1.0: 0.5)
                            
                        }.frame(width: 40, height: 40).cornerRadius(7)
#if !os(visionOS) && !os(macOS)
                            .hoverEffect(.lift)
                            .hoverEffectDisabled(!hoverEffectsAbsorbCursor)
                        #endif
                            .onHover(perform: { hovering in
                                if hovering {
                                    hoverSidebarButton = true
                                }
                                else {
                                    hoverSidebarButton = false
                                }
                            })
                    }).buttonStyle(.plain)
                
                    
                
                
                /*
                Button(action: {
                    changeColorSheet.toggle()
                }, label: {
                    ZStack {
                        Color(.white)
                            .opacity(hoverPaintbrush ? 0.5: 0.0)
                        
                        Image(systemName: hoverPaintbrush ? "paintbrush.pointed.fill": "paintbrush.pointed")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(textColor)
                            .opacity(hoverPaintbrush ? 1.0: 0.5)
                        
                    }.frame(width: 40, height: 40).cornerRadius(7)
                        .hoverEffect(.lift)
                        .hoverEffectDisabled(!hoverEffectsAbsorbCursor)
                        .onHover(perform: { hovering in
                            if hovering {
                                hoverPaintbrush = true
                            }
                            else {
                                hoverPaintbrush = false
                            }
                        })
                }).keyboardShortcut("e", modifiers: .command)
                    .popover(isPresented: $changeColorSheet, content: {
                        VStack(spacing: 20) {
                            LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .bottomLeading, endPoint: .topTrailing)
                                .frame(width: 200, height: 200)
                                .cornerRadius(10)
                                .ignoresSafeArea()
                                .offset(y: -10)
                            
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
                
                
                
                Button(action: {
                    //navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: "https://www.google.com")!))
                    tabBarShown.toggle()
                    commandBarShown = false
                }, label: {
                    ZStack {
                        Color(.white)
                            .opacity(hoverNewTab ? 0.5: 0.0)
                        
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(textColor)
                            .opacity(hoverNewTab ? 1.0: 0.5)
                        
                    }.frame(width: 40, height: 40).cornerRadius(7)
                        .hoverEffect(.lift)
                        .hoverEffectDisabled(!hoverEffectsAbsorbCursor)
                        .onHover(perform: { hovering in
                            if hovering {
                                hoverNewTab = true
                            }
                            else {
                                hoverNewTab = false
                            }
                        })
                }).keyboardShortcut("t", modifiers: .command)
                */
                //if UIDevice.current.userInterfaceIdiom != .mac {
                //if ProcessInfo.processInfo.isMacCatalystApp {
                    Spacer()
                //}
                
                
                
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
                }, label: {
                    ZStack {
                        HoverButtonDisabledVision(hoverInteraction: $hoverBackwardButton)
                        
                        Image(systemName: "arrow.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(textColor)
                            .opacity(hoverBackwardButton ? 1.0: 0.5)
                        
                    }.frame(width: 40, height: 40).cornerRadius(7)
#if !os(visionOS) && !os(macOS)
                        .hoverEffect(.lift)
                        .hoverEffectDisabled(!hoverEffectsAbsorbCursor)
                    #endif
                        .onHover(perform: { hovering in
                            if hovering {
                                hoverBackwardButton = true
                            }
                            else {
                                hoverBackwardButton = false
                            }
                        })
                }).buttonStyle(.plain)
                
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
                }, label: {
                    ZStack {
                        HoverButtonDisabledVision(hoverInteraction: $hoverForwardButton)
                        
                        Image(systemName: "arrow.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(textColor)
                            .opacity(hoverForwardButton ? 1.0: 0.5)
                        
                    }.frame(width: 40, height: 40).cornerRadius(7)
#if !os(visionOS) && !os(macOS)
                        .hoverEffect(.lift)
                        .hoverEffectDisabled(!hoverEffectsAbsorbCursor)
                    #endif
                        .onHover(perform: { hovering in
                            if hovering {
                                hoverForwardButton = true
                            }
                            else {
                                hoverForwardButton = false
                            }
                        })
                }).buttonStyle(.plain)
                
                
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
                }, label: {
                    ZStack {
                        HoverButtonDisabledVision(hoverInteraction: $hoverReloadButton)
                        
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(textColor)
                            .opacity(hoverReloadButton ? 1.0: 0.5)
                            .rotationEffect(Angle(degrees: Double(reloadRotation)))
                            .animation(.bouncy, value: reloadRotation)
                        
                    }.frame(width: 40, height: 40).cornerRadius(7)
#if !os(visionOS) && !os(macOS)
                        .hoverEffect(.lift)
                        .hoverEffectDisabled(!hoverEffectsAbsorbCursor)
                    #endif
                        .onHover(perform: { hovering in
                            if hovering {
                                hoverReloadButton = true
                            }
                            else {
                                hoverReloadButton = false
                            }
                        })
                }).buttonStyle(.plain)
            }
            .onAppear() {
#if os(iOS)
                if UIDevice.current.userInterfaceIdiom == .phone {
                    hideSidebar = true
                }
                #endif
                }
        }/*.onAppear {
            if let savedStartColor = getColor(forKey: "startColorHex") {
                startColor = savedStartColor
            }
            if let savedEndColor = getColor(forKey: "endColorHex") {
                endColor = savedEndColor
            }
        }*/
        .onAppear() {
            let spaceForColor = spaces[selectedSpaceIndex]
            startColor = Color(hex: spaceForColor.startHex)
            endColor = Color(hex: spaceForColor.endHex)
        }
    }
}


