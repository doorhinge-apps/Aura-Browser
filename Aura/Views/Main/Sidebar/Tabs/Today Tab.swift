//
//  Sidebar Tab.swift
//  Aura
//
//  Created by Caedmon Myers on 28/4/24.
//

import SwiftUI
import WebKit
import SDWebImage
import SDWebImageSwiftUI



struct TodayTab: View {
    @Binding var reloadTitles: Bool
    @State var tab: WKWebView
    @Binding var hoverTab: WKWebView
    @Binding var faviconLoadingStyle: Bool
    @Binding var searchInSidebar: String
    @Binding var hoverCloseTab: WKWebView
    @Binding var selectedTabLocation: String
    @Binding var draggedTab: WKWebView?
    
    @EnvironmentObject var manager: WebsiteManager
    
    @AppStorage("faviconShape") var faviconShape = "circle"
    
    @ObservedObject var navigationState: NavigationState
    @ObservedObject var pinnedNavigationState: NavigationState
    @ObservedObject var favoritesNavigationState: NavigationState
    
    @EnvironmentObject var variables: ObservableVariables
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            if reloadTitles {
                Color.white.opacity(0.0)
            }
            
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color(.white).opacity(tab == navigationState.selectedWebView ? 0.5 : hoverTab == tab ? 0.2: 0.0001))
                .frame(height: 50)
            
            HStack {
                if faviconLoadingStyle {
                    WebImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(tab.url?.absoluteString)&sz=\(128)".replacingOccurrences(of: "https://www.google.com/s2/favicons?domain=Optional(", with: "https://www.google.com/s2/favicons?domain=").replacingOccurrences(of: ")&sz=", with: "&sz=").replacingOccurrences(of: "\"", with: ""))) { image in
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
                            .frame(width: 25, height: 25)
                            .cornerRadius(faviconShape == "square" ? 0: faviconShape == "squircle" ? 5: 100)
                            .padding(.leading, 5)
                        
                    } placeholder: {
                        LoadingAnimations(size: 25, borderWidth: 5.0)
                            .padding(.leading, 5)
                    }
                    
                }
                
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
                
                Spacer() // Pushes the delete button to the edge
                
                Button(action: {
                    if let index = navigationState.webViews.firstIndex(of: tab) {
                        removeTab(at: index)
                    }
                }) {
                    if (hoverTab == tab || navigationState.selectedWebView == tab) {
                        ZStack {
#if !os(visionOS)
                            Color(.white)
                                .opacity(hoverCloseTab == tab ? 0.3: 0.0)
                            #endif
                            
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(Color.white)
                                .opacity(hoverCloseTab == tab ? 1.0: 0.8)
                            
                        }.frame(width: 35, height: 35)
#if !os(visionOS)
                            .cornerRadius(7)
                            .padding(.trailing, 10)
#if !os(macOS)
                            .hoverEffect(.lift)
                        #endif
                        #endif
                            .onHover(perform: { hovering in
                                if hovering {
                                    hoverCloseTab = tab
                                }
                                else {
                                    hoverCloseTab = WKWebView()
                                }
                            })
                        
                    }
                }.buttonStyle(.plain)
            }
        }
        .contextMenu {
            Button {
                variables.browseForMeSearch = tab.url?.absoluteString ?? ""
                variables.isBrowseForMe = true
            } label: {
                Label("Browse for Me", systemImage: "globe.desk")
            }
#if !os(macOS)
            Button {
                UIPasteboard.general.string = tab.url?.absoluteString ?? ""
            } label: {
                Label("Copy URL", systemImage: "link")
            }
            #endif
            Button {
                navigationState.createNewWebView(withRequest: URLRequest(url: URL(string: formatURL(from: tab.url?.absoluteString ?? ""))!))
            } label: {
                Label("Duplicate", systemImage: "plus.square.on.square")
            }
            
            Button {
                pinnedNavigationState.webViews.append(tab)
                
                if let index = navigationState.webViews.firstIndex(of: tab) {
                    removeTab(at: index)
                }
            } label: {
                Label("Pin Tab", systemImage: "pin")
            }
            
            Button {
                favoritesNavigationState.webViews.append(tab)
                
                if let index = navigationState.webViews.firstIndex(of: tab) {
                    removeTab(at: index)
                }
            } label: {
                Label("Favorite", systemImage: "star")
            }
            
            Button {
                if let index = navigationState.webViews.firstIndex(of: tab) {
                    removeTab(at: index)
                }
            } label: {
                Label("Close Tab", systemImage: "xmark")
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
            pinnedNavigationState.selectedWebView = nil
            pinnedNavigationState.currentURL = nil
            
            favoritesNavigationState.selectedWebView = nil
            favoritesNavigationState.currentURL = nil
            
            selectedTabLocation = "tabs"
            
            manager.selectedTabLocation = .tabs
            
            Task {
                await navigationState.selectedWebView = tab
                await navigationState.currentURL = tab.url
            }
            
            if let unwrappedURL = tab.url {
                searchInSidebar = unwrappedURL.absoluteString
            }
        }
        .onDrag {
            self.draggedTab = tab
            return NSItemProvider()
        }
        .onDrop(of: [.text], delegate: DropViewDelegate(destinationItem: tab, allTabs: $navigationState.webViews, draggedItem: $draggedTab))
    }
    
    func removeTab(at index: Int) {
        // If the deleted tab is the currently selected one
        if navigationState.selectedWebView == navigationState.webViews[index] {
            if navigationState.webViews.count > 1 { // Check if there's more than one tab
                if index == 0 { // If the first tab is being deleted, select the next one
                    navigationState.selectedWebView = navigationState.webViews[1]
                } else { // Otherwise, select the previous one
                    navigationState.selectedWebView = navigationState.webViews[index - 1]
                }
            } else { // If it's the only tab, set the selectedWebView to nil
                navigationState.selectedWebView = nil
            }
        }
        
        navigationState.webViews.remove(at: index)
    }
}

