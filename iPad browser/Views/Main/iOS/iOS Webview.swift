//
//  iOS Webview.swift
//  Aura
//
//  Created by Caedmon Myers on 25/6/24.
//

import SwiftUI
import WebKit

class WebViewCoordinator: NSObject, WKNavigationDelegate {
    @Binding var title: String
    
    init(title: Binding<String>) {
        _title = title
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let title = webView.title {
            self.title = title
        }
    }
}

struct WebViewMobile: UIViewRepresentable {
    let urlString: String
    @Binding var title: String
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(title: $title)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}
