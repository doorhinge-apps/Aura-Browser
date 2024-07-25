//
//  CurrentWebView.swift
//  Aura
//
//  Created by Reyna Myers on 27/6/24.
//

import SwiftUI

struct CurrentWebView: View {
    @EnvironmentObject var variables: ObservableVariables
    
    @EnvironmentObject var manager: WebsiteManager
    
    var webGeo: GeometryProxy
    
    @State var readerView = false
    
    var body: some View {
        if manager.selectedWebView != nil {
                BrowserView(webViewStore: manager.selectedWebView ?? WebViewStore())
                    .frame(width: webGeo.size.width, height: webGeo.size.height)
        }
    }
}


