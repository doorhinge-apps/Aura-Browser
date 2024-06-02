//
//  Pinned Tab.swift
//  Aura
//
//  Created by Caedmon Myers on 28/4/24.
//

import SwiftUI
import WebKit
import SDWebImage
import SDWebImageSwiftUI

struct PinnedTab: View {
    @Binding var reloadTitles: Bool
    @State var tab: WKWebView
    @Binding var hoverTab: WKWebView
    @Binding var faviconLoadingStyle: Bool
    @Binding var searchInSidebar: String
    @Binding var hoverCloseTab: WKWebView
    @Binding var selectedTabLocation: String
    @Binding var draggedTab: WKWebView?
    
    @ObservedObject var navigationState: NavigationState
    @ObservedObject var pinnedNavigationState: NavigationState
    @ObservedObject var favoritesNavigationState: NavigationState
    
    @AppStorage("faviconShape") var faviconShape = "circle"
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            if reloadTitles {
                Color.white.opacity(0.0)
            }
            
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color(.white).opacity(tab == pinnedNavigationState.selectedWebView ? 0.5 : hoverTab == tab ? 0.2: 0.0001))
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
                    Text(tab.url?.absoluteString ?? "Tab not found.")
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
                
                Spacer()
                
                Button(action: {
                    if let index = pinnedNavigationState.webViews.firstIndex(of: tab) {
                        pinnedRemoveTab(at: index)
                    }
                }) {
                    if hoverTab == tab || pinnedNavigationState.selectedWebView == tab {
                        ZStack {
                            Color(.white)
                                .opacity(hoverCloseTab == tab ? 0.3: 0.0)
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15, height: 15)
                                .foregroundStyle(Color.white)
                                .opacity(hoverCloseTab == tab ? 1.0: 0.8)
                            
                        }.frame(width: 35, height: 35).cornerRadius(7).padding(.trailing, 10)
                            .hoverEffect(.lift)
                            .onHover(perform: { hovering in
                                if hovering {
                                    hoverCloseTab = tab
                                }
                                else {
                                    hoverCloseTab = WKWebView()
                                }
                            })
                        
                    }
                }
            }
        }
        .contextMenu {
            Button {
                pinnedNavigationState.createNewWebView(withRequest: URLRequest(url: URL(string: formatURL(from: tab.url?.absoluteString ?? ""))!))
            } label: {
                Label("Duplicate", systemImage: "plus.square.on.square")
            }
            
            Button {
                navigationState.webViews.append(tab)
                
                if let index = pinnedNavigationState.webViews.firstIndex(of: tab) {
                    pinnedRemoveTab(at: index)
                }
            } label: {
                Label("Unpin", systemImage: "pin.fill")
            }
            
            Button {
                favoritesNavigationState.webViews.append(tab)
                
                if let index = pinnedNavigationState.webViews.firstIndex(of: tab) {
                    pinnedRemoveTab(at: index)
                }
            } label: {
                Label("Favorite", systemImage: "star")
            }
            
            Button {
                if let index = pinnedNavigationState.webViews.firstIndex(of: tab) {
                    pinnedRemoveTab(at: index)
                }
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
                hoverTab = tab
            }
            else {
                hoverTab = WKWebView()
            }
        })
        .onTapGesture {
            navigationState.selectedWebView = nil
            navigationState.currentURL = nil
            
            favoritesNavigationState.selectedWebView = nil
            favoritesNavigationState.currentURL = nil
            
            selectedTabLocation = "pinnedTabs"
            
            Task {
                await pinnedNavigationState.selectedWebView = tab
                await pinnedNavigationState.currentURL = tab.url
            }
            
            if let unwrappedURL = tab.url {
                searchInSidebar = unwrappedURL.absoluteString
            }
        }
        .onDrag {
            self.draggedTab = tab
            return NSItemProvider()
        }
        .onDrop(of: [.text], delegate: DropViewDelegate(destinationItem: tab, allTabs: $pinnedNavigationState.webViews, draggedItem: $draggedTab))
    }
    
    func pinnedRemoveTab(at index: Int) {
        // If the deleted tab is the currently selected one
        if pinnedNavigationState.selectedWebView == pinnedNavigationState.webViews[index] {
            if pinnedNavigationState.webViews.count > 1 { // Check if there's more than one tab
                if index == 0 { // If the first tab is being deleted, select the next one
                    pinnedNavigationState.selectedWebView = pinnedNavigationState.webViews[1]
                } else { // Otherwise, select the previous one
                    pinnedNavigationState.selectedWebView = pinnedNavigationState.webViews[index - 1]
                }
            } else { // If it's the only tab, set the selectedWebView to nil
                pinnedNavigationState.selectedWebView = nil
            }
        }
        
        pinnedNavigationState.webViews.remove(at: index)
    }
}

