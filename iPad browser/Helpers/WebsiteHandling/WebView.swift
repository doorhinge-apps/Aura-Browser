//
//  WebView.swift
//  Aura
//
//  Created by Quinn O'Donnell on 4/28/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    @ObservedObject var navigationState : NavigationState
    
    func makeUIView(context: Context) -> UIView  {
        return UIView()
    }
    
    
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let webView = navigationState.selectedWebView else {
            return
        }
        webView.customUserAgent = "Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        
        // Set the frame again to ensure the webView resizes correctly
        webView.frame = CGRect(origin: .zero, size: uiView.bounds.size)
        
        
        if webView != uiView.subviews.first {
            uiView.subviews.forEach { $0.removeFromSuperview() }
            uiView.addSubview(webView)
        }
    }
}
