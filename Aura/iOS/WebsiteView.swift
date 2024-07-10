//
//  WebsiteView.swift
//  Aura
//
//  Created by Caedmon Myers on 26/6/24.
//

import SwiftUI

struct WebsiteView: View {
    let namespace: Namespace.ID
    @Binding var url: String
    @State private var offset = CGSize.zero
    @State private var scale: CGFloat = 1.0
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var webViewManager: WebViewManager
    
    var parentGeo: GeometryProxy
    
    @State var gestureStarted = false
    @State var exponentialThing = 1.0
    
    @State private var webTitle: String = ""
    #if !os(macOS)
    @State var webViewBackgroundColor: UIColor? = UIColor.white
    #else
    @State var webViewBackgroundColor: NSColor? = NSColor.white
    #endif
    @Binding var webURL: String
    @Binding var fullScreenWebView: Bool
    
    @State var tab: (id: UUID, url: String)
    
    @Binding var browseForMeTabs: [String]
    
    @State var searchText = ""
    @State var searchResponse = ""
    
    var body: some View {
        GeometryReader { geo in
#if !os(macOS)
            ZStack {
                Color(uiColor: webViewBackgroundColor ?? UIColor(.white))
                    .ignoresSafeArea()
                
                if browseForMeTabs.contains(tab.id.description) {
                    BrowseForMeMobile(searchText: unformatURL(url: url), searchResponse: searchResponse)
                        .matchedGeometryEffect(id: tab.id, in: namespace)
                }
                else {
                    WebViewMobile(urlString: url, title: $webTitle, webViewBackgroundColor: $webViewBackgroundColor, currentURLString: $webURL, webViewManager: webViewManager)
                        .navigationBarBackButtonHidden(true)
                        .matchedGeometryEffect(id: tab.id, in: namespace)
                }
            }
            .ignoresSafeArea(.container, edges: [.leading, .trailing, .bottom])
#endif
        }
    }
}

