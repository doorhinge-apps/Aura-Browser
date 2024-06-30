//import SwiftUI
//import WebKit
//
//class WebSnapshotManager: NSObject, ObservableObject {
//    private var webView: WKWebView = WKWebView()
//    private var cache = NSCache<NSURL, UIImage>()
//    
//    override init() {
//        super.init()
//        webView.navigationDelegate = self
//    }
//    
//    func snapshot(for url: URL) async -> UIImage? {
//        let nsURL = url as NSURL
//        
//        if let cachedImage = cache.object(forKey: nsURL) {
//            return cachedImage
//        }
//        
//        return await withCheckedContinuation { continuation in
//            DispatchQueue.main.async {
//                self.webView.load(URLRequest(url: url))
//            }
//            
//            // Set continuation to be used once snapshot is ready
//            self.continuation = continuation
//        }
//    }
//    
//    private func createImage(webView: WKWebView, completion: @escaping (UIImage?) -> ()) {
//        let originalFrame = webView.frame
//        let originalConstraints = webView.constraints
//        let originalScrollViewOffset = webView.scrollView.contentOffset
//
//        // Calculate the size to capture the full content width and a fixed height of 800
//        let contentWidth = webView.scrollView.contentSize.width
//        let fixedHeight: CGFloat = 800
//        let newSize = CGSize(width: contentWidth, height: fixedHeight)
//
//        webView.removeConstraints(originalConstraints)
//        webView.translatesAutoresizingMaskIntoConstraints = true
//        webView.frame = CGRect(origin: .zero, size: CGSize(width: contentWidth, height: max(fixedHeight, webView.scrollView.contentSize.height)))
//        webView.scrollView.contentOffset = .zero
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // You can adjust this delay as needed
//            let renderer = UIGraphicsImageRenderer(size: newSize)
//            let image = renderer.image { ctx in
//                webView.scrollView.layer.render(in: ctx.cgContext)
//            }
//            
//            // Restore the original state of the webView
//            webView.frame = originalFrame
//            webView.translatesAutoresizingMaskIntoConstraints = false
//            webView.addConstraints(originalConstraints)
//            webView.scrollView.contentOffset = originalScrollViewOffset
//            
//            completion(image)
//        }
//    }
//
//
//    
//    private var continuation: CheckedContinuation<UIImage?, Never>?
//}
//
//extension WebSnapshotManager: WKNavigationDelegate {
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        createImage(webView: webView) { [weak self] image in
//            guard let self = self, let image = image else {
//                self?.continuation?.resume(returning: nil)
//                return
//            }
//            
//            let nsURL = webView.url! as NSURL
//            self.cache.setObject(image, forKey: nsURL)
//            self.continuation?.resume(returning: image)
//        }
//    }
//}
//
//
//struct WebSnapshotView: View {
//    var url: URL
//    @ObservedObject var manager: WebSnapshotManager
//    @State private var image: UIImage?
//    @State private var isLoading = true
//    
//    var body: some View {
//        Group {
//            if let uiImage = image {
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .frame(alignment: .top)
//                    .aspectRatio(contentMode: .fill)
//            } else if isLoading {
//                ProgressView()
//                    .onAppear {
//                        Task {
//                            image = await manager.snapshot(for: url)
//                            isLoading = false
//                        }
//                    }
//            } else {
//                Text("Failed to load snapshot")
//            }
//        }
//    }
//}
//
