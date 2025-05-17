//
// Aura
// NewWebView.swift
//
// Created on 16/5/25
//
// Copyright ©2025 DoorHinge Apps.
//


import SwiftUI
import WebKit
import Combine
import Observation
import SwiftData


@Observable
final class WebViewModel: NSObject {
    
    // UI-observable state
    var title: String = ""
    var url: URL?
    var isLoading = false
    var progress: Double = 0
    
    enum LinkReaction { case allow, openExternal, deny }
    var linkHandler: ((URL) -> LinkReaction)?
    
    // WKWebView must be a stored property, not lazy-computed
    let webView: WKWebView
    
    override init() {
        let cfg = WKWebViewConfiguration()
        cfg.defaultWebpagePreferences.allowsContentJavaScript = true
        
        webView = WKWebView(frame: .zero, configuration: cfg)   // ← fixed
        super.init()
        
        webView.navigationDelegate = self
        webView.uiDelegate         = self
        webView.isFindInteractionEnabled = true
        observeWebView()
    }
    
    // MARK: navigation helpers
    @MainActor func navigate(to raw: String) {
        var s = raw.trimmingCharacters(in: .whitespaces)
        if !s.hasPrefix("http://") && !s.hasPrefix("https://") { s = "https://" + s }
        guard let u = URL(string: s) else { return }
        load(u)
    }
    
    @MainActor func load(_ u: URL) { webView.load(.init(url: u)) }
    @MainActor func reload()       { if let u = webView.url { load(u) } }
}

// MARK: – KVO  ➜  @Observable
private extension WebViewModel {
    func observeWebView() {
        webView.publisher(for: \.title)
            .sink { [weak self] in self?.title = $0 ?? "" }.store(in: &bag)
        webView.publisher(for: \.url)
            .sink { [weak self] in self?.url = $0 }.store(in: &bag)
        webView.publisher(for: \.isLoading)
            .sink { [weak self] in self?.isLoading = $0 }.store(in: &bag)
        webView.publisher(for: \.estimatedProgress)
            .sink { [weak self] in self?.progress = $0 }.store(in: &bag)
    }
    var bag: Set<AnyCancellable> {
        get { objc_getAssociatedObject(self, &k) as? Set<AnyCancellable> ?? [] }
        set { objc_setAssociatedObject(self, &k, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
private var k: UInt8 = 0

// MARK: – Delegates ----------------------------------------------------------

extension WebViewModel: WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate {
    @MainActor
    func download(
        _ download: WKDownload,
        decideDestinationUsing response: URLResponse,
        suggestedFilename: String
    ) async -> URL? {
        let docs = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(suggestedFilename)
    }
    
    // helper
    private func downloadDestination(for name: String) -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(name)
    }
    
    
    // link-reaction gate
    func webView(_ wv: WKWebView,
                 decidePolicyFor nav: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let u = nav.request.url, let r = linkHandler?(u) else { decisionHandler(.allow); return }
        switch r { case .allow: decisionHandler(.allow)
        case .deny: decisionHandler(.cancel)
            case .openExternal: decisionHandler(.cancel); UIApplication.shared.open(u) }
    }
    
    // download stubs – satisfy WKDownloadDelegate conformance
    func webView(_ wv: WKWebView,
                 navigationResponse: WKNavigationResponse,
                 didBecome download: WKDownload) {}
    func webView(_ wv: WKWebView,
                 navigationAction: WKNavigationAction,
                 didBecome download: WKDownload) {}
    func webView(_ wv: WKWebView,
                 download _: WKDownload,
                 decideDestinationUsing response: URLResponse,
                 suggestedFilename fn: String,
                 completionHandler: @escaping (URL?) -> Void) {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        completionHandler(docs.appendingPathComponent(fn))
    }
    
    // context menu
    func webView(_ wv: WKWebView,
                 contextMenuConfigurationFor element: WKContextMenuElementInfo,
                 completionHandler: @escaping (UIContextMenuConfiguration?) -> Void) {
        
        let url = element.linkURL
        let cfg = UIContextMenuConfiguration(identifier: nil, previewProvider: {
            guard let u = url else { return nil }
            let vc = UIViewController()
            let pv = WKWebView(frame: vc.view.bounds)
            pv.load(URLRequest(url: u))
            vc.view.addSubview(pv)
            pv.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                pv.topAnchor.constraint(equalTo: vc.view.topAnchor),
                pv.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
                pv.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),
                pv.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor)
            ])
            return vc
        }, actionProvider: { [self] _ in        // ← explicit self capture
            var items: [UIMenuElement] = []
            
            if let u = url {
                items.append(UIAction(title: "Share",
                                      image: UIImage(systemName: "square.and.arrow.up")) { _ in
                    UIActivityViewController(activityItems: [u], applicationActivities: nil)
                        .presentFromRoot()
                })
                items.append(UIAction(title: "Copy",
                                      image: UIImage(systemName: "doc.on.doc")) { _ in
                    UIPasteboard.general.string = u.absoluteString
                })
            }
            items.append(UIAction(title: "Find",
                                  image: UIImage(systemName: "magnifyingglass")) { _ in
                wv.findInteraction?.presentFindNavigator(showingReplace: false)
            })
            items.append(spaceMenu(for: url))
            return UIMenu(children: items)
        })
        completionHandler(cfg)
    }
    
    // MARK: space-support
    @MainActor                                             // ← resolves main-actor warning
    private func spaceMenu(for url: URL?) -> UIMenu {
        guard let url else { return UIMenu(title: "") }
        let ctx    = try? ModelContainer(for: SpaceStorage.self).mainContext
        let spaces = (try? ctx?.fetch(FetchDescriptor<SpaceStorage>())) ?? []
        let acts   = spaces.map { space in
            UIAction(title: space.spaceName,
                     image: UIImage(systemName: space.spaceIcon)) { _ in
                space.tabUrls.append(url.absoluteString); try? ctx?.save()
            }
        }
        return UIMenu(title: "Open In", image: UIImage(systemName: "arrow.up.forward.app"), children: acts)
    }
}

// MARK: – SwiftUI wrapper ----------------------------------------------------

struct NewWebView: UIViewRepresentable {
    @Bindable var model: WebViewModel
    func makeUIView(context: Context) -> WKWebView { model.webView }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: – helpers ------------------------------------------------------------

private extension UIActivityViewController {
    func presentFromRoot() {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }
            .first?.present(self, animated: true)
    }
}
