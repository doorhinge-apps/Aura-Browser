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
    @Binding var webViewBackgroundColor: UIColor?
    
    init(title: Binding<String>, webViewBackgroundColor: Binding<UIColor?>) {
        _title = title
        _webViewBackgroundColor = webViewBackgroundColor
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let title = webView.title {
            self.title = title
        }
        if let webViewBackgroundColor = webView.underPageBackgroundColor {
            self.webViewBackgroundColor = webViewBackgroundColor
        }
    }
}
#if !os(macOS)
struct WebViewMobile: UIViewRepresentable {
    let urlString: String
    @Binding var title: String
    @Binding var webViewBackgroundColor: UIColor?
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(title: $title, webViewBackgroundColor: $webViewBackgroundColor)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.underPageBackgroundColor
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}
#endif
