import SwiftUI
import WebKit
import CryptoKit
import ObjectiveC.runtime

private var NavKey: UInt8 = 0

// This must be declared at file scope so both views and loader can use it
private func digest(_ url: URL) -> String {
    SHA256.hash(data: Data(url.absoluteString.utf8))
        .map { String(format: "%02x", $0) }.joined()
}

private func fileURL(for url: URL) -> URL {
    FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent(digest(url) + ".png")
}

private func loadDisk(for url: URL) -> UIImage? {
    guard let data = try? Data(contentsOf: fileURL(for: url)) else { return nil }
    return UIImage(data: data)
}

private func saveDisk(_ img: UIImage, for url: URL) {
    guard let data = img.pngData() else { return }
    try? data.write(to: fileURL(for: url), options: .atomic)
}

struct UrlSnapshotView: View {
    let urlString: String
    @State private var img: UIImage?

    var body: some View {
        ZStack {
            if let ui = img {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
            } else {
                Color(UIColor.secondarySystemBackground)
                ProgressView()
            }
        }
        .clipped()
        .background(
            HiddenLoader(urlString: urlString) { self.img = $0 }
                .frame(width: 400, height: 600)
                .opacity(0.001)
        )
        .onReceive(NotificationCenter.default.publisher(for: .snapshotDidUpdate)) { note in
            guard let s = note.object as? String,
                  s == urlString,
                  let url = URL(string: urlString),
                  let fresh = loadDisk(for: url) else { return }
            self.img = fresh
        }
    }
}

private struct HiddenLoader: UIViewRepresentable {
    let urlString: String
    let onSnapshot: (UIImage) -> Void

    func makeUIView(context: Context) -> WKWebView {
        let wv = WKWebView()
        Task { await startCapture(on: wv) }
        return wv
    }

    func updateUIView(_: WKWebView, context: Context) {}

    @MainActor
    private func startCapture(on wv: WKWebView) async {
        try? await Task.sleep(nanoseconds: 500_000_000)

        guard let url = URL(string: urlString) else { return }

        if let disk = loadDisk(for: url) {
            onSnapshot(disk)
            return
        }

        try? await load(url, in: wv)
        try? await Task.sleep(nanoseconds: 250_000_000)
        if let img = await snapshot(from: wv) {
            saveDisk(img, for: url)
            onSnapshot(img)
        }
    }

    private func load(_ url: URL, in wv: WKWebView) async throws {
        try await withCheckedThrowingContinuation { c in
            let nav = NavDelegate(c) {
                objc_setAssociatedObject(wv, &NavKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            wv.navigationDelegate = nav
            objc_setAssociatedObject(wv, &NavKey, nav, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            wv.load(URLRequest(url: url))
        }
    }

    private func snapshot(from wv: WKWebView) async -> UIImage? {
        await withCheckedContinuation { c in
            let cfg = WKSnapshotConfiguration()
            cfg.rect = CGRect(origin: .zero, size: .init(width: 400, height: 600))
            cfg.snapshotWidth = 400
            cfg.afterScreenUpdates = true
            wv.takeSnapshot(with: cfg) { img, _ in c.resume(returning: img) }
        }
    }

    private final class NavDelegate: NSObject, WKNavigationDelegate {
        private var cont: CheckedContinuation<Void, Error>?
        private let cleanup: () -> Void

        init(_ cont: CheckedContinuation<Void, Error>, _ cleanup: @escaping () -> Void) {
            self.cont = cont; self.cleanup = cleanup
        }

        private func finish(_ err: Error? = nil) {
            err == nil ? cont?.resume() : cont?.resume(throwing: err!)
            cont = nil; cleanup()
        }

        func webView(_ w: WKWebView, didFinish n: WKNavigation!) { finish() }
        func webView(_ w: WKWebView, didFail n: WKNavigation!, withError e: Error) { finish(e) }
        func webView(_ w: WKWebView, didFailProvisionalNavigation n: WKNavigation!, withError e: Error) { finish(e) }
    }
}
