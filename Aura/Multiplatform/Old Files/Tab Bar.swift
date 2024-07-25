//
//  Tab Bar.swift
//  iPad browser
//
//  Created by Reyna Myers on 11/4/24.
//

import SwiftUI
import WebKit


/*
struct TabBar: View {
    @Binding var navigationState: NavigationState
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Binding var reloadTitles: Bool
    @Binding var hoverTab: WKWebView
    @Binding var searchInSidebar: String
    @Binding var hoverCloseTab: WKWebView
    
    @State var offsets: [String: CGFloat]? = [:]
    var body: some View {
        ScrollView {
            ForEach(navigationState.webViews, id: \.self) { tab in
                ZStack {
                    if reloadTitles {
                        Color.white.opacity(0.0)
                    }
                    
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(Color(.white).opacity(tab == navigationState.selectedWebView ? 0.5 : hoverTab == tab ? 0.2: 0.0))
                    //.foregroundStyle(navigationState.currentURL?.absoluteString ?? "(none)" == tab.url ? Color(.white).opacity(0.4): hoverTab == tab ? Color(.white).opacity(0.2): Color.clear)
                        .frame(height: 50)
                    
                    
                    HStack {
                        Text(tab.title ?? "Tab not found.")
                            .lineLimit(1)
                            .foregroundColor(Color.foregroundColor(forHex: UserDefaults.standard.string(forKey: "startColorHex") ?? "ffffff"))
                            .padding(.leading, 5)
                            .onReceive(timer) { _ in
                                reloadTitles.toggle()
                            }
                        
                        Spacer() // Pushes the delete button to the edge
                        
                        Button(action: {
                            if let index = navigationState.webViews.firstIndex(of: tab) {
                                removeTab(at: index)
                            }
                        }) {
                            if hoverTab == tab || navigationState.selectedWebView == tab {
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
#if !os(macOS)
                                    .hoverEffect(.lift)
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
                    }.contextMenu {
                        Button {
                            //
                        } label: {
                            Text("Close Tab")
                        }

                    }
                    
                    
                }//.hoverEffect(.lift)
                .onHover(perform: { hovering in
                    if hovering {
                        hoverTab = tab
                    }
                    else {
                        hoverTab = WKWebView()
                    }
                })
                .onTapGesture {
                    navigationState.selectedWebView = tab
                    navigationState.currentURL = tab.url
                    
                    if let unwrappedURL = tab.url {
                        searchInSidebar = unwrappedURL.absoluteString
                    }
                }
//                .offset(y: offsets[tab.url?.description] ?? 0)
//                .gesture(
//                    DragGesture()
//                        .onChanged { gesture in
//                            offsets[tab.url?.description] = gesture.translation.height
//                        }
//                        .onEnded { _ in
//                            self.offsets[tab.url?.description] = 0
//                        }
//                )
                
            }
        }
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
*/
