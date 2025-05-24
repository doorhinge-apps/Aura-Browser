
import SwiftUI
import WebKit
import CryptoKit

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
// MARK: – Helpers for file caching

private func digest(of url: URL) -> String {
    SHA256.hash(data: Data(url.absoluteString.utf8))
        .map { String(format: "%02x", $0) }
        .joined()
}

private func fileURL(for url: URL) -> URL {
    let name = digest(of: url) + ".png"
    return FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent(name)
}

private func saveDisk(_ img: UIImage, for url: URL) {
    guard let data = img.pngData() else { return }
    try? data.write(to: fileURL(for: url), options: .atomic)
}

// MARK: – WebViewMobile with in-view snapshot on load

struct WebViewMobile: UIViewRepresentable {
    var urlString: String
    @Binding var title: String
    @Binding var webViewBackgroundColor: UIColor?
    @Binding var currentURLString: String
    @ObservedObject var webViewManager: WebViewManager

    func makeUIView(context: Context) -> WKWebView {
        let wv = webViewManager.webView
        wv.navigationDelegate = context.coordinator
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        webViewManager.load(urlString: urlString)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebViewMobile

        init(_ parent: WebViewMobile) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // update UI bindings
            parent.title = webView.title ?? ""
            parent.currentURLString = webView.url?.absoluteString ?? ""
            parent.webViewBackgroundColor = webView.backgroundColor

            // then snapshot *this* webView
            guard let url = URL(string: parent.currentURLString) else { return }
            Task { @MainActor in
                // 1s grace for late-loading content
                try? await Task.sleep(nanoseconds: 1_000_000_000)

                let config = WKSnapshotConfiguration()
                // snapshot the full rendered bounds
                config.rect = webView.bounds
                // scale down to 200px width (auto height)
                config.snapshotWidth = 200
                config.afterScreenUpdates = true

                webView.takeSnapshot(with: config) { image, _ in
                    if let img = image {
                        saveDisk(img, for: url)
                    }
                }
            }
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
