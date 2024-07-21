//
//  WebViewUI.swift
//  Styling
//
//  Created by Mark C. Maxwell on The New Lux
//  Copyright © 2020. All rights reserved.


import Combine
import SwiftUI
import UIKit
import WebKit

public class WebViewStore: NSObject, ObservableObject,WKNavigationDelegate {
    public enum LinkReaction{
        case allow
        case openExternal
        case deny
    }
    private var initialLoad = true
    internal var linkHandler: ((URL) -> LinkReaction)?
    private var observers: [NSKeyValueObservation] = []
    @Published public var webView: WKWebView
    
    override public init(){
        self.webView = WKWebView()
        super.init()
        setupObservers()
    }
    deinit {
        invalidateObservers()
    }
    
    public func setLinkHandler(_ linkHandler:((URL) -> LinkReaction)?=nil){
        self.linkHandler = linkHandler
    }
}


extension WebViewStore{
    private func invalidateObservers(){
        observers.forEach {
            $0.invalidate()
        }
    }
    private func setupObservers() {
        func subscriber<Value>(for keyPath: KeyPath<WKWebView, Value>) -> NSKeyValueObservation {
            return webView.observe(keyPath, options: [.prior]) { _, change in
                if change.isPrior {
                    self.objectWillChange.send()
                }
            }
        }
        invalidateObservers()
        observers = [
            subscriber(for: \.title),
            subscriber(for: \.url),
            subscriber(for: \.isLoading),
            subscriber(for: \.estimatedProgress),
            subscriber(for: \.hasOnlySecureContent),
            subscriber(for: \.serverTrust),
            subscriber(for: \.canGoBack),
            subscriber(for: \.canGoForward),
        ]
        
        webView.navigationDelegate = self
    }


}

/// A container for using a WKWebView in SwiftUI
public struct WebView: UIViewRepresentable {
    public let webView: WKWebView

    public init(webView: WKWebView) {
        self.webView = webView
    }

    public func makeUIView(context: Context) -> UIViewContainerView<WKWebView> {
        let uiView = UIViewContainerView<WKWebView>()
        uiView.contentView = webView
        webView.uiDelegate = context.coordinator
        return uiView
    }

    public func updateUIView(_ uiView: UIViewContainerView<WKWebView>, context: Context) {
        // If it's the same content view we don't need to update.
        if uiView.contentView !== webView {
            uiView.contentView = webView

            webView.backgroundColor = .clear
            uiView.backgroundColor = .clear
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, WKUIDelegate {
        var parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }
        
        public func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
            
            let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                guard let url = elementInfo.linkURL else { return }
                let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                if let topVC = UIApplication.shared.windows.first?.rootViewController {
                    topVC.present(activityVC, animated: true, completion: nil)
                }
                
                guard let data = elementInfo.linkURL else { return }
                let av = UIActivityViewController(activityItems: [data], applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
            }
            
            let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                UIMenu(children: [shareAction])
            }
            completionHandler(configuration)
        }
    }
}

/// A UIView which simply adds some view to its view hierarchy
public class UIViewContainerView<ContentView: UIView>: UIView {
    var contentView: ContentView? {
        willSet {
            contentView?.removeFromSuperview()
        }
        didSet {
            if let contentView = contentView {
                addSubview(contentView)
                contentView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    contentView.topAnchor.constraint(equalTo: topAnchor),
                    contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
                ])
            }
        }
    }
}

extension WebViewStore {
    
    @objc public func load(url: URL) {
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: url))
        }
    }

    @objc public func reload() {
        guard let url = self.webView.url else{
            return
        }
        DispatchQueue.main.async {
            self.webView.load(URLRequest(url: url))
        }
    }

    @objc public func loadIfNeeded(url:URL) {
        guard initialLoad == true else {
            loadIfDisposed(url: url)
            return
        }
        initialLoad = false
        load(url: url)
    }

    @objc public func loadIfDisposed(url:URL?) {
        guard let url = url ?? webView.url else{
            return
        }
        
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript("document.querySelector('body').innerHTML") { [weak self] _, error in
                if error != nil {
                    self?.load(url: url)
                }
            }
        }
    }
}


