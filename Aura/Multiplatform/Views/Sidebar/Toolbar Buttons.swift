//
//  Toolbar Buttons.swift
//  iPad browser
//
//  Created by Reyna Myers on 19/4/24.
//

import SwiftUI
import WebKit
import SwiftData

struct ToolbarButtonsView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \SpaceStorage.spaceIndex) var spaces: [SpaceStorage]
    
    @EnvironmentObject var variables: ObservableVariables
    @EnvironmentObject var manager: WebsiteManager
    @EnvironmentObject var settings: SettingsVariables
    
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
    
//    @Binding var commandBarShown: Bool
//    @Binding var tabBarShown: Bool
    
    @State var showColorSheet = false
    
//    @Binding var startColor: Color
//    @Binding var endColor: Color
//    @Binding var textColor: Color
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = true
    @AppStorage("sidebarLeft") var sidebarLeft = true
    
    @AppStorage("selectedSpaceIndex") var selectedSpaceIndex = 0
    
    @State var geo: GeometryProxy
    var body: some View {
        GeometryReader { geo2 in
            HStack {
                if ProcessInfo.processInfo.isMacCatalystApp && !variables.hideSidebar && settings.sidebarLeft {
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
                            variables.hideSidebar.toggle()
                        }
                    }, label: {
                        ZStack {
                            HoverButtonDisabledVision(hoverInteraction: $hoverSidebarButton)
                            
                            Image(systemName: "sidebar.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .foregroundStyle(variables.textColor)
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
                
                    Spacer()
                
                
                Button(action: {
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
                }, label: {
                    ZStack {
                        HoverButtonDisabledVision(hoverInteraction: $hoverBackwardButton)
                        
                        Image(systemName: "arrow.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(variables.textColor)
                            .opacity(hoverBackwardButton ? 1.0: 0.5)
                            .offset(x: variables.backArrowPulse ? -8: 0)
                        
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
                    .disabled((manager.selectedWebView?.webView.canGoBack ?? true) ? false: true)
                
                Button(action: {
                    if manager.selectedWebView?.webView.canGoForward ?? true {
                        withAnimation(.bouncy, {
                            variables.forwardArrowPulse = true
                        })
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                            withAnimation(.bouncy, {
                                variables.forwardArrowPulse = false
                            })
                        })
                        
                        manager.selectedWebView?.webView.goForward()
                    }
                }, label: {
                    ZStack {
                        HoverButtonDisabledVision(hoverInteraction: $hoverForwardButton)
                        
                        Image(systemName: "arrow.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(variables.textColor)
                            .opacity(hoverForwardButton ? 1.0: 0.5)
                            .offset(x: variables.forwardArrowPulse ? 8: 0)
                        
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
                    .disabled((manager.selectedWebView?.webView.canGoForward ?? true) ? false: true)
                
                Button(action: {
                    withAnimation(.bouncy, {
                        variables.reloadRotation += 360
                    })
                    
                    variables.searchInSidebar = manager.selectedWebView?.webView.url?.absoluteString ?? variables.searchInSidebar
                    manager.selectedWebView?.reload()
                }, label: {
                    ZStack {
                        HoverButtonDisabledVision(hoverInteraction: $hoverReloadButton)
                        
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(variables.textColor)
                            .opacity(hoverReloadButton ? 1.0: 0.5)
                            .rotationEffect(Angle(degrees: Double(variables.reloadRotation)))
                        
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
                    variables.hideSidebar = true
                }
                #endif
                }
        }
        .onAppear() {
            let spaceForColor = spaces[selectedSpaceIndex]
            variables.startColor = Color(hex: spaceForColor.startHex)
            variables.endColor = Color(hex: spaceForColor.endHex)
        }
    }
}


