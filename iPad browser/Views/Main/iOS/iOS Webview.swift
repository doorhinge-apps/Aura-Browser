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
    @Binding var currentURLString: String

    init(title: Binding<String>, webViewBackgroundColor: Binding<UIColor?>, currentURLString: Binding<String>) {
        _title = title
        _webViewBackgroundColor = webViewBackgroundColor
        _currentURLString = currentURLString
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let title = webView.title {
            self.title = title
        }
        if let webViewBackgroundColor = webView.underPageBackgroundColor {
            self.webViewBackgroundColor = webViewBackgroundColor
        }
        self.currentURLString = webView.url?.absoluteString ?? ""
    }
}

#if !os(macOS)
struct WebViewMobile: UIViewRepresentable {
    let urlString: String
    @Binding var title: String
    @Binding var webViewBackgroundColor: UIColor?
    @Binding var currentURLString: String
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(title: $title, webViewBackgroundColor: $webViewBackgroundColor, currentURLString: $currentURLString)
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
