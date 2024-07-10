//
//  WebsiteManager.swift
//  Aura
//
//  Created by Caedmon Myers on 8/7/24.
//

import SwiftUI
import UIKit
import WebKit
import WebViewSwiftUI
import LinkPresentation

class WebsiteManager: ObservableObject {
    @Published var webViewStores: [String: WebViewStore] = [:]
    
    @Published var selectedWebView: WebViewStore?
    
    func addWebViewStore(id: String, webViewStore: WebViewStore) {
        webViewStores[id] = webViewStore
    }
    
    func getWebViewStore(id: String) -> WebViewStore? {
        return webViewStores[id]
    }
    
    func selectOrAddWebView(urlString: String) {
        if let existingStore = webViewStores.values.first(where: { $0.webView.url?.absoluteString == urlString }) {
            // Set the found WebViewStore as the selected WebView
            selectedWebView = existingStore
            selectedWebView?.webView.allowsBackForwardNavigationGestures = true
        } else {
            // Create a new WebViewStore if not found and add it to the dictionary
            let newWebViewStore = WebViewStore()
            newWebViewStore.webView.allowsBackForwardNavigationGestures = true
            newWebViewStore.webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15"
            
            newWebViewStore.loadIfNeeded(url: URL(string: urlString) ?? URL(string: "https://example.com")!)
            webViewStores[urlString] = newWebViewStore
            
            //selectedWebView?.webView.uiDelegate?.webView(<#T##WKWebView#>, contextMenuConfigurationForElement: <#T##WKContextMenuElementInfo#>, completionHandler: <#T##(UIContextMenuConfiguration?) -> Void#>)
            
//            var menuBuilder = UIMenuBuilder.self
            
//            selectedWebView?.webView.buildMenu { builder in
//                
//            }
            
            //var menuBuilder = UIMenuBuilder
            
            let customMenu = UIMenu(title: "Custom Actions", image: nil, identifier: UIMenu.Identifier("com.yourapp.customMenu"), options: .displayInline, children: [
                UIAction(title: "Custom Action 1", image: UIImage(systemName: "star"), handler: { _ in
                    // Handle custom action 1
                    print("Custom action 1 tapped")
                }),
                UIAction(title: "Custom Action 2", image: UIImage(systemName: "heart"), handler: { _ in
                    // Handle custom action 2
                    print("Custom action 2 tapped")
                })
            ])
            
            selectedWebView = newWebViewStore
            
            if UserDefaults.standard.bool(forKey: "adBlockEnabled") {
                loadContentBlockingRules(selectedWebView?.webView ?? WKWebView())
            }
        }
        
        if webViewStores.count > Int(UserDefaults.standard.double(forKey: "preloadingWebsites")) {
            webViewStores = Dictionary(webViewStores.keys.prefix(Int(UserDefaults.standard.double(forKey: "preloadingWebsites"))).map { ($0, webViewStores[$0]!) }, uniquingKeysWith: { first, _ in first })
        }
    }
    
    
    @Published var linksWithTitles: [String: String] = [:]
    
    func fetchTitles(for urls: [String]) {
        for urlString in urls {
            guard let url = URL(string: urlString) else { continue }
            
            let metadataProvider = LPMetadataProvider() // Create a new instance for each URL
            metadataProvider.startFetchingMetadata(for: url) { (metadata, error) in
                guard error == nil, let title = metadata?.title else {
                    print("Failed to fetch metadata for url: \(urlString)")
                    return
                }
                DispatchQueue.main.async {
                    self.linksWithTitles[urlString] = title
                }
            }
        }
    }
    
    func fetchTitlesIfNeeded(for urls: [String]) {
        for urlString in urls {
            if linksWithTitles[urlString] == nil {
                guard let url = URL(string: urlString) else { continue }
                
                let metadataProvider = LPMetadataProvider() // Create a new instance for each URL
                metadataProvider.startFetchingMetadata(for: url) { (metadata, error) in
                    guard error == nil, let title = metadata?.title else {
                        print("Failed to fetch metadata for url: \(urlString)")
                        return
                    }
                    DispatchQueue.main.async {
                        self.linksWithTitles[urlString] = title
                    }
                }
            }
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
    
    @AppStorage("selectedSpaceIndex") var selectedSpaceIndex = 0
    
    @Published var hoverTab = ""
    
    @Published var selectedTabIndex: Int = -1
    @Published var hoverTabIndex = -1
    @Published var hoverCloseTabIndex = -1
    
    @Published var draggedIndex: Int?
    
    @Published var selectedTabLocation: TabLocations = .tabs
    @Published var hoverTabLocation: TabLocations = .tabs
    @Published var dragTabLocation: TabLocations = .tabs
}
