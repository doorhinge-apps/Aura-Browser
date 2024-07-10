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
                withAnimation(.bouncy, {
                    variables.reloadRotation += 360
                })
                
                manager.selectedWebView?.reload()
            }
        }
    }
}


