//
//  MainMenu.swift
//  Styling
//
//  Created by Mark C. Maxwell on The New Lux
//  Copyright © 2020. All rights reserved.
//

import SwiftUI


public struct BrowserView: View {
    @ObservedObject var webViewStore: WebViewStore

    public init(webViewStore: WebViewStore) {
        self.webViewStore = webViewStore
    }
    public var body: some View {
        WebView(webView: self.webViewStore.webView)
//        I have absolutely no idea why I put an opacity modifier here. It's gone for now.
//            .opacity(self.webViewStore.webView.isLoading ? 0.8 : 1.0)
            .animation(.easeInOut,value:true)
    }
}

public struct LoaderNavBar: View {
    @ObservedObject var webViewStore: WebViewStore
    
    public init(webViewStore: WebViewStore) {
    self.webViewStore = webViewStore
    }
    
    public var body: some View {
        HStack {
            Spacer()
        }
        .frame(height: 2)
        .background(
            Rectangle()
                .fill(Color.white)
                .allowsHitTesting(false)
                .disabled(true)
        )
        .frame(height: 2)
        .clipped()
    }
}

public struct NavigatorNavBar: View {
    @ObservedObject var webViewStore: WebViewStore

    public init(webViewStore: WebViewStore) {
    self.webViewStore = webViewStore
    }
    
    var title: String {
        (webViewStore.webView.title ?? "Error")
    }

    public var body: some View {
        HStack {
            Button(action: { self.webViewStore.webView.goBack() }) {
                Image(systemName: "chevron.left")
            }

            Text(self.title)
                .bold()
                .lineLimit(1)
                .animation(.none)

            Button(action: { self.webViewStore.webView.goForward() }) {
                Image(systemName: "chevron.right")
            }
        }
    }
}
