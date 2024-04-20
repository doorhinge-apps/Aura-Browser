////
////  FavoriteTabs.swift
////  iPad browser
////
////  Created by Caedmon Myers on 19/4/24.
////
//
//import SwiftUI
//import WebKit
//
//
//struct FavoriteTabs: View {
//    @ObservedObject var navigationState: NavigationState
//    @ObservedObject var pinnedNavigationState: NavigationState
//    @ObservedObject var favoritesNavigationState: NavigationState
//    
//    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    
//    @State var hoverTab: WKWebView
//    @Binding var reloadTitles: Bool
//    
//    @Binding var selectedTabLocation: String
//    @Binding var searchInSidebar: String
//    @State var draggedTab: WKWebView
//    
//    var body: some View {
//        LazyVGrid(columns: [GridItem(), GridItem()]) {
//            ForEach(favoritesNavigationState.webViews, id:\.self) { tab in
//                ZStack {
//                    RoundedRectangle(cornerRadius: 20)
//                        .stroke(Color.white.opacity(tab == favoritesNavigationState.selectedWebView ? 1.0 : hoverTab == tab ? 0.6: 0.2), lineWidth: 3)
//                        .fill(Color(.white).opacity(tab == favoritesNavigationState.selectedWebView ? 0.5 : hoverTab == tab ? 0.15: 0.0001))
//                        .frame(height: 75)
//                    
//                    
//                    HStack {
//                        if tab.title == "" {
//                            Text(tab.url?.absoluteString ?? "Tab not found.")
//                                .lineLimit(1)
//                                .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
//                                .padding(.leading, 5)
//                                .onReceive(timer) { _ in
//                                    reloadTitles.toggle()
//                                }
//                        }
//                        else {
//                            Text(tab.title ?? "Tab not found.")
//                                .lineLimit(1)
//                                .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
//                                .padding(.leading, 5)
//                                .onReceive(timer) { _ in
//                                    reloadTitles.toggle()
//                                }
//                        }
//                    }
//                    
//                    
//                }
//                .contextMenu {
//                    Button {
//                        pinnedNavigationState.webViews.append(tab)
//                        
//                        if let index = favoritesNavigationState.webViews.firstIndex(of: tab) {
//                            favoriteRemoveTab(at: index)
//                        }
//                    } label: {
//                        Label("Pin Tab", systemImage: "pin")
//                    }
//                    
//                    Button {
//                        navigationState.webViews.append(tab)
//                        
//                        if let index = favoritesNavigationState.webViews.firstIndex(of: tab) {
//                            favoriteRemoveTab(at: index)
//                        }
//                    } label: {
//                        Label("Unfavorite", systemImage: "star.fill")
//                    }
//                    
//                    Button {
//                        if let index = favoritesNavigationState.webViews.firstIndex(of: tab) {
//                            favoriteRemoveTab(at: index)
//                        }
//                    } label: {
//                        Label("Close Tab", systemImage: "xmark")
//                    }
//                    
//                }
//                .onAppear() {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                        hoverTab = WKWebView()
//                    }
//                }
//                .onHover(perform: { hovering in
//                    if hovering {
//                        hoverTab = tab
//                    }
//                    else {
//                        hoverTab = WKWebView()
//                    }
//                })
//                .onTapGesture {
//                    
//                    navigationState.selectedWebView = nil
//                    navigationState.currentURL = nil
//                    
//                    pinnedNavigationState.selectedWebView = nil
//                    pinnedNavigationState.currentURL = nil
//                    
//                    selectedTabLocation = "favoriteTabs"
//                    
//                    Task {
//                        await favoritesNavigationState.selectedWebView = tab
//                        await favoritesNavigationState.currentURL = tab.url
//                    }
//                    
//                    if let unwrappedURL = tab.url {
//                        searchInSidebar = unwrappedURL.absoluteString
//                    }
//                }
//                .onDrag {
//                    self.draggedTab = tab
//                    return NSItemProvider()
//                }
//                .onDrop(of: [.text], delegate: DropViewDelegate(destinationItem: tab, allTabs: $favoritesNavigationState.webViews, draggedItem: $draggedTab))
//            }
//        }
//    }
//    
//    func removeTab(at index: Int) {
//        // If the deleted tab is the currently selected one
//        if navigationState.selectedWebView == navigationState.webViews[index] {
//            if navigationState.webViews.count > 1 { // Check if there's more than one tab
//                if index == 0 { // If the first tab is being deleted, select the next one
//                    navigationState.selectedWebView = navigationState.webViews[1]
//                } else { // Otherwise, select the previous one
//                    navigationState.selectedWebView = navigationState.webViews[index - 1]
//                }
//            } else { // If it's the only tab, set the selectedWebView to nil
//                navigationState.selectedWebView = nil
//            }
//        }
//        
//        navigationState.webViews.remove(at: index)
//    }
//    
//    func pinnedRemoveTab(at index: Int) {
//        // If the deleted tab is the currently selected one
//        if pinnedNavigationState.selectedWebView == pinnedNavigationState.webViews[index] {
//            if pinnedNavigationState.webViews.count > 1 { // Check if there's more than one tab
//                if index == 0 { // If the first tab is being deleted, select the next one
//                    pinnedNavigationState.selectedWebView = pinnedNavigationState.webViews[1]
//                } else { // Otherwise, select the previous one
//                    pinnedNavigationState.selectedWebView = pinnedNavigationState.webViews[index - 1]
//                }
//            } else { // If it's the only tab, set the selectedWebView to nil
//                pinnedNavigationState.selectedWebView = nil
//            }
//        }
//        
//        pinnedNavigationState.webViews.remove(at: index)
//    }
//    
//    func favoriteRemoveTab(at index: Int) {
//        // If the deleted tab is the currently selected one
//        if favoritesNavigationState.selectedWebView == favoritesNavigationState.webViews[index] {
//            if favoritesNavigationState.webViews.count > 1 { // Check if there's more than one tab
//                if index == 0 { // If the first tab is being deleted, select the next one
//                    favoritesNavigationState.selectedWebView = favoritesNavigationState.webViews[1]
//                } else { // Otherwise, select the previous one
//                    favoritesNavigationState.selectedWebView = favoritesNavigationState.webViews[index - 1]
//                }
//            } else { // If it's the only tab, set the selectedWebView to nil
//                favoritesNavigationState.selectedWebView = nil
//            }
//        }
//        
//        favoritesNavigationState.webViews.remove(at: index)
//    }
//}
