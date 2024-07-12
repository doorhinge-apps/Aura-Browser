//
//  iOS Webview.swift
//  Aura
//
//  Created by Reyna Myers on 25/6/24.
//

import SwiftUI
import WebKit

class WebViewCoordinator: NSObject, WKNavigationDelegate {
    @Binding var title: String
#if !os(macOS)
    @Binding var webViewBackgroundColor: UIColor?
    #else
    @Binding var webViewBackgroundColor: NSColor?
    #endif
    @Binding var currentURLString: String
    var webView: WKWebView?
    
#if !os(macOS)
    init(title: Binding<String>, webViewBackgroundColor: Binding<UIColor?>, currentURLString: Binding<String>) {
        _title = title
        _webViewBackgroundColor = webViewBackgroundColor
        _currentURLString = currentURLString
    }
    #else
    init(title: Binding<String>, webViewBackgroundColor: Binding<NSColor?>, currentURLString: Binding<String>) {
        _title = title
        _webViewBackgroundColor = webViewBackgroundColor
        _currentURLString = currentURLString
    }
    #endif
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let title = webView.title {
            self.title = title
        }
        if let webViewBackgroundColor = webView.underPageBackgroundColor {
            self.webViewBackgroundColor = webViewBackgroundColor
        }
        self.currentURLString = webView.url?.absoluteString ?? ""
    }
    
    func goBack() {
        webView?.goBack()
    }
    
    func goForward() {
        webView?.goForward()
    }
}

#if !os(macOS)
struct WebViewMobile: UIViewRepresentable {
    var urlString: String
    @Binding var title: String
    @Binding var webViewBackgroundColor: UIColor?
    @Binding var currentURLString: String
    @ObservedObject var webViewManager: WebViewManager
    
    func makeUIView(context: Context) -> WKWebView {
        webViewManager.webView.navigationDelegate = context.coordinator
        return webViewManager.webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        webViewManager.load(urlString: urlString)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewMobile
        
        init(_ parent: WebViewMobile) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.title = webView.title ?? ""
            parent.currentURLString = webView.url?.absoluteString ?? ""
            parent.webViewBackgroundColor = webView.backgroundColor
        }
    }
}
#endif



class WebViewManager: ObservableObject {
    @Published var webView: WKWebView = WKWebView()
    
    func goBack() {
        webView.goBack()
    }
    
    func goForward() {
        webView.goForward()
    }
    
    func reload() {
        webView.reload()
    }
    
    func canGoBack() -> Bool {
        return webView.canGoBack
    }
    
    func canGoForward() -> Bool {
        return webView.canGoForward
    }
    
    func load(urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
