//
//  WebView.swift
//  Aura
//
//  Created by Quinn O'Donnell on 4/28/24.
//

import SwiftUI
import WebKit

let testcss = """
html, body {
  overflow-x: hidden;
}

body {
  background-color: #333333;
  line-height: 1.5;
  color: white;
  padding: 10;
  font-weight: 600;
  font-family: -apple-system;
}
"""
#if !os(macOS)
struct WebView: UIViewRepresentable {
    
    @ObservedObject var navigationState : NavigationState
    
    @ObservedObject var variables = ObservableVariables()
    
    func makeUIView(context: Context) -> UIView  {
        return UIView()
    }
    
    
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let webView = navigationState.selectedWebView else {
            return
        }
        //webView.customUserAgent = "Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        //webView.customUserAgent = "Mozilla/5.0 (iPad; CPU OS 17_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Mobile/15E148 Safari/604.1"

        
        if UIDevice.current.userInterfaceIdiom == .phone {
            webView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Mobile/15E148 Safari/604.1"
        }
        else if UIDevice.current.userInterfaceIdiom == .pad {
            //webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
            webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"
        }
        else {
            webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_4_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Safari/605.1.15"
        }
        
        if UserDefaults.standard.bool(forKey: "adBlockEnabled") {
            loadContentBlockingRules(webView)
        }
        
        // Set the frame again to ensure the webView resizes correctly
        webView.frame = CGRect(origin: .zero, size: uiView.bounds.size)
        
        
        if webView != uiView.subviews.first {
            uiView.subviews.forEach { $0.removeFromSuperview() }
            uiView.addSubview(webView)
        }
    }
    
    private func loadContentBlockingRules(_ webView: WKWebView) {
        //guard let filePath = Bundle.main.path(forResource: "Adaway", ofType: "json") else {
        guard let filePath = Bundle.main.path(forResource: "adblock", ofType: "json") else {
            print("Error: Could not find rules.json file.")
            return
        }
        
        do {
            let jsonString = try String(contentsOfFile: filePath, encoding: .utf8)
            WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "ContentBlockingRules", encodedContentRuleList: jsonString) { ruleList, error in
                if let error = error {
                    print("Error compiling content rule list: \(error.localizedDescription)")
                    return
                }
                
                guard let ruleList = ruleList else {
                    print("Error: Rule list is nil.")
                    return
                }
                
                let configuration = webView.configuration
                configuration.userContentController.add(ruleList)
            }
        } catch {
            print("Error loading rules.json file: \(error.localizedDescription)")
        }
    }
}
#else
struct WebView: NSViewRepresentable {
    
    @ObservedObject var navigationState: NavigationState
    
    @ObservedObject var variables = ObservableVariables()
    
    func makeNSView(context: Context) -> NSView {
        return NSView()
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        guard let webView = navigationState.selectedWebView else {
            return
        }

        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_4_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Safari/605.1.15"
        
        if UserDefaults.standard.bool(forKey: "adBlockEnabled") {
            loadContentBlockingRules(webView)
        }
        
        // Set the frame again to ensure the webView resizes correctly
        webView.frame = CGRect(origin: .zero, size: nsView.bounds.size)
        
        if webView != nsView.subviews.first {
            nsView.subviews.forEach { $0.removeFromSuperview() }
            nsView.addSubview(webView)
        }
    }
    
    private func loadContentBlockingRules(_ webView: WKWebView) {
        guard let filePath = Bundle.main.path(forResource: "adblock", ofType: "json") else {
            print("Error: Could not find adblock.json file.")
            return
        }
        
        do {
            let jsonString = try String(contentsOfFile: filePath, encoding: .utf8)
            WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "ContentBlockingRules", encodedContentRuleList: jsonString) { ruleList, error in
                if let error = error {
                    print("Error compiling content rule list: \(error.localizedDescription)")
                    return
                }
                
                guard let ruleList = ruleList else {
                    print("Error: Rule list is nil.")
                    return
                }
                
                let configuration = webView.configuration
                configuration.userContentController.add(ruleList)
            }
        } catch {
            print("Error loading adblock.json file: \(error.localizedDescription)")
        }
    }
}

#endif
