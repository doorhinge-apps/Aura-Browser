//
//  CurrentWebView.swift
//  Aura
//
//  Created by Caedmon Myers on 27/6/24.
//

import SwiftUI
import WebViewSwiftUI

struct CurrentWebView: View {
    @EnvironmentObject var variables: ObservableVariables
    
    @EnvironmentObject var manager: WebsiteManager
    
    var webGeo: GeometryProxy
    
    var body: some View {
        if manager.selectedWebView != nil {
            ScrollView(showsIndicators: false) {
                BrowserView(webViewStore: manager.selectedWebView ?? WebViewStore())
                    .frame(width: webGeo.size.width, height: webGeo.size.height)
            }
            .refreshable {
                variables.reloadRotation += 360
                
                manager.selectedWebView?.reload()
            }
        }
        
        /*if manager.selectedTabLocation == .pinned || manager.selectedTabLocation == .tabs {
            ScrollView(showsIndicators: false) {
                BrowserView(webViewStore: manager.selectedWebView ?? WebViewStore())
                    .frame(width: webGeo.size.width, height: webGeo.size.height)
            }
            .refreshable {
                variables.reloadRotation += 360
                
                manager.selectedWebView?.reload()
            }
        }
        else {
            if variables.selectedTabLocation == "favoriteTabs" {
                ScrollView(showsIndicators: false) {
                    WebView(navigationState: variables.favoritesNavigationState, variables: variables)
                        .frame(width: webGeo.size.width, height: webGeo.size.height)
                }
                
                //loadingIndicators(for: variables.favoritesNavigationState.selectedWebView?.isLoading)
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
                
                
                //loadingIndicators(for: variables.navigationState.selectedWebView?.isLoading)
            }
            if variables.selectedTabLocation == "pinnedTabs" {
                ScrollView(showsIndicators: false) {
                    WebView(navigationState: variables.pinnedNavigationState, variables: variables)
                        .frame(width: webGeo.size.width, height: webGeo.size.height)
                }
                
                
                //loadingIndicators(for: variables.pinnedNavigationState.selectedWebView?.isLoading)
            }
        }*/
    }
}


