//
//  Toolbar Buttons.swift
//  iPad browser
//
//  Created by Caedmon Myers on 19/4/24.
//

import SwiftUI
import WebKit

struct ToolbarButtonsView: View {
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
    
    @State private var startColor: Color = Color.purple
    @State private var endColor: Color = Color.pink
    
    @Binding var commandBarShown: Bool
    @Binding var tabBarShown: Bool
    
    @State var showColorSheet = false
    var body: some View {
        GeometryReader { geo in
            HStack {
                Button(action: {
                    Task {
                        await hideSidebar.toggle()
                    }
                    
                    if selectedTabLocation == "tabs" {
                        navigationState.selectedWebView?.reload()
                        navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                        
                        navigationState.selectedWebView = navigationState.selectedWebView
                        
                        if let unwrappedURL = navigationState.currentURL {
                            searchInSidebar = unwrappedURL.absoluteString
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            navigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                        }
                    }
                    else if selectedTabLocation == "pinnedTabs" {
                        pinnedNavigationState.selectedWebView?.reload()
                        pinnedNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                        
                        pinnedNavigationState.selectedWebView = pinnedNavigationState.selectedWebView
                        
                        if let unwrappedURL = pinnedNavigationState.currentURL {
                            searchInSidebar = unwrappedURL.absoluteString
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            pinnedNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                        }
                    }
                    else if selectedTabLocation == "favoriteTabs" {
                        favoritesNavigationState.selectedWebView?.reload()
                        favoritesNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                        
                        favoritesNavigationState.selectedWebView = favoritesNavigationState.selectedWebView
                        
                        if let unwrappedURL = favoritesNavigationState.currentURL {
                            searchInSidebar = unwrappedURL.absoluteString
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            favoritesNavigationState.selectedWebView?.frame = CGRect(origin: .zero, size: CGSize(width: geo.size.width-40, height: geo.size.height))
                        }
                    }
                }, label: {
                    ZStack {
                        Color(.white)
                            .opacity(hoverSidebarButton ? 0.5: 0.0)
                        
                        Image(systemName: "sidebar.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                            .foregroundStyle(Color.white)
                            .opacity(hoverSidebarButton ? 1.0: 0.5)
                        
                    }.frame(width: 40, height: 40).cornerRadius(7)
                        .hoverEffect(.lift)
                        .onHover(perform: { hovering in
                            if hovering {
                                hoverSidebarButton = true
                            }
                            else {
                                hoverSidebarButton = false
                            }
                        })
                }).keyboardShortcut("s", modifiers: .command)
                
                
                
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
                            .foregroundStyle(Color.white)
                            .opacity(hoverPaintbrush ? 1.0: 0.5)
                        
                    }.frame(width: 40, height: 40).cornerRadius(7)
                        .hoverEffect(.lift)
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
                                        saveColor(color: newValue, key: "startColorHex")
                                    }
                                
                                ColorPicker("End Color", selection: $endColor)
                                    .onChange(of: endColor) { newValue in
                                        saveColor(color: newValue, key: "endColorHex")
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
                            .foregroundStyle(Color.white)
                            .opacity(hoverNewTab ? 1.0: 0.5)
                        
                    }.frame(width: 40, height: 40).cornerRadius(7)
                        .hoverEffect(.lift)
                        .onHover(perform: { hovering in
                            if hovering {
                                hoverNewTab = true
                            }
                            else {
                                hoverNewTab = false
                            }
                        })
                }).keyboardShortcut("t", modifiers: .command)
                
                
                
                
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
                        Color(.white)
                            .opacity(hoverBackwardButton ? 0.5: 0.0)
                        
                        Image(systemName: "arrow.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.white)
                            .opacity(hoverBackwardButton ? 1.0: 0.5)
                        
                    }.frame(width: 40, height: 40).cornerRadius(7)
                        .hoverEffect(.lift)
                        .onHover(perform: { hovering in
                            if hovering {
                                hoverBackwardButton = true
                            }
                            else {
                                hoverBackwardButton = false
                            }
                        })
                }).keyboardShortcut("[", modifiers: .command)
                
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
                        Color(.white)
                            .opacity(hoverForwardButton ? 0.5: 0.0)
                        
                        Image(systemName: "arrow.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.white)
                            .opacity(hoverForwardButton ? 1.0: 0.5)
                        
                    }.frame(width: 40, height: 40).cornerRadius(7)
                        .hoverEffect(.lift)
                        .onHover(perform: { hovering in
                            if hovering {
                                hoverForwardButton = true
                            }
                            else {
                                hoverForwardButton = false
                            }
                        })
                }).keyboardShortcut("]", modifiers: .command)
                
                
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
                        Color(.white)
                            .opacity(hoverReloadButton ? 0.5: 0.0)
                        
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.white)
                            .opacity(hoverReloadButton ? 1.0: 0.5)
                            .rotationEffect(Angle(degrees: Double(reloadRotation)))
                            .animation(.bouncy, value: reloadRotation)
                        
                    }.frame(width: 40, height: 40).cornerRadius(7)
                        .hoverEffect(.lift)
                        .onHover(perform: { hovering in
                            if hovering {
                                hoverReloadButton = true
                            }
                            else {
                                hoverReloadButton = false
                            }
                        })
                }).keyboardShortcut("r", modifiers: .command)
            }
        }.onAppear {
            if let savedStartColor = getColor(forKey: "startColorHex") {
                startColor = savedStartColor
            }
            if let savedEndColor = getColor(forKey: "endColorHex") {
                endColor = savedEndColor
            }
        }
    }
}


