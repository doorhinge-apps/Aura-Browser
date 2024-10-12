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
import SwiftData

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
        webView.isFindInteractionEnabled = true
        webView.findInteraction?.presentFindNavigator(showingReplace: false)
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
        // Set the delegate when the view is initially created
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
//        webView.isFindInteractionEnabled = true
//        webView.findInteraction?.presentFindNavigator(showingReplace: false)
        return uiView
    }

    public func updateUIView(_ uiView: UIViewContainerView<WKWebView>, context: Context) {
        // Ensure the contentView is correctly set and the delegate is updated
        if uiView.contentView !== webView {
            uiView.contentView = webView

            // Re-assign the delegate every time the view is updated
            webView.uiDelegate = context.coordinator
            webView.navigationDelegate = context.coordinator

            webView.backgroundColor = .clear
            uiView.backgroundColor = .clear
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: WebView

        @StateObject var variables = ObservableVariables()
        @StateObject var manager = WebsiteManager()

        var spaces = [SpaceStorage]()

        var container: ModelContainer = {
            let schema = Schema([
                SpaceStorage.self,
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }()

        var context: ModelContext

        init(_ parent: WebView) {
            self.parent = parent
            
            context = ModelContext(container)
            
            do {
                let descriptor = FetchDescriptor<SpaceStorage>()
                spaces = try container.mainContext.fetch(descriptor)
            } catch {
                print("Failed to fetch spaces: \(error)")
            }
        }

        public func webView(_ webView: WKWebView, contextMenuConfigurationForElement elementInfo: WKContextMenuElementInfo, completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
            let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                guard let url = elementInfo.linkURL else { return }
                
                let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                
                if let popoverController = activityController.popoverPresentationController {
                    popoverController.sourceView = UIApplication.shared.windows.first?.rootViewController?.view
                    
                    popoverController.permittedArrowDirections = [.up]
                    popoverController.permittedArrowDirections = []
                }
                
                UIApplication.shared.windows.first?.rootViewController!.present(activityController, animated: true, completion: nil)
            }
            
            let copyAction = UIAction(title: "Copy", image: UIImage(systemName: "document.on.clipboard")) { _ in
                guard let url = elementInfo.linkURL else { return }
                
                UIPasteboard.general.string = url.absoluteString
            }
            
            let findAction = UIAction(title: "Find", image: UIImage(systemName: "magnifyingglass")) { _ in
                webView.findInteraction?.presentFindNavigator(showingReplace: false)
            }
            

            var openIn: [UIMenuElement] = []
            for space in spaces {
                let moveAction = UIAction(title: space.spaceName, image: UIImage(systemName: space.spaceIcon)) { _ in
                    guard let url = elementInfo.linkURL else { return }
                    space.tabUrls.append(url.absoluteString)
                    
                    do {
                        try self.container.mainContext.save()
                    } catch {
                        print("Failed to save space updates: \(error)")
                    }
                }
                openIn.append(moveAction)
            }
            
            let openInMenu = UIMenu(title: "Open In", image: UIImage(systemName: "arrow.up.forward.app"), children: openIn)
            
            let previewProvider: () -> UIViewController? = {
                guard let url = elementInfo.linkURL else { return nil }
                let previewVC = UIViewController()
                let previewWebView = WKWebView(frame: previewVC.view.bounds)
                previewWebView.load(URLRequest(url: url))
                previewWebView.navigationDelegate = self

                previewVC.view.addSubview(previewWebView)
                previewWebView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    previewWebView.topAnchor.constraint(equalTo: previewVC.view.topAnchor),
                    previewWebView.bottomAnchor.constraint(equalTo: previewVC.view.bottomAnchor),
                    previewWebView.leadingAnchor.constraint(equalTo: previewVC.view.leadingAnchor),
                    previewWebView.trailingAnchor.constraint(equalTo: previewVC.view.trailingAnchor)
                ])
                return previewVC
            }

            let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider) { _ in
                UIMenu(children: [shareAction, copyAction, findAction, openInMenu])
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


