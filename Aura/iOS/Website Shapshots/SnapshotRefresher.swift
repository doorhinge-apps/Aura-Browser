import SwiftUI
import WebKit
import CryptoKit
import ObjectiveC.runtime

private var NavKey: UInt8 = 0

extension Notification.Name {
    static let snapshotDidUpdate = Notification.Name("SnapshotDidUpdate")
}

@MainActor
class SnapshotVM: ObservableObject {
    /// Call this to force a 1 s‐delayed snapshot & overwrite the cached PNG.
    func refresh(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        Task { @MainActor in
            let wv = WKWebView()
            do {
                try await load(url, in: wv)
                // 1 second grace for late‐painting pages
                try await Task.sleep(nanoseconds: 1_000_000_000)
                if let img = await snapshot(from: wv) {
                    saveDisk(img, for: url)
                }
            } catch {
                print("Snapshot refresh error:", error)
            }
        }
    }

    // ——— internal helpers ——————————————————————————————

    private func load(_ url: URL, in wv: WKWebView) async throws {
        try await withCheckedThrowingContinuation { cont in
            let nav = NavDelegate(cont) {
                // unpin when done
                objc_setAssociatedObject(wv, &NavKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            wv.navigationDelegate = nav
            // pin nav to keep it alive until finish or failure
            objc_setAssociatedObject(wv, &NavKey, nav, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            wv.load(URLRequest(url: url))
        }
    }

    private func snapshot(from wv: WKWebView) async -> UIImage? {
        await withCheckedContinuation { cont in
            let cfg = WKSnapshotConfiguration()
            // assume your off‐screen view is 400×600
            cfg.rect = CGRect(origin: .zero, size: CGSize(width: 400, height: 600))
            cfg.snapshotWidth = 200
            cfg.afterScreenUpdates = true
            wv.takeSnapshot(with: cfg) { img, _ in
                cont.resume(returning: img)
            }
        }
    }
    
    func deleteAllSnapshots() {
        let fm = FileManager.default
        guard let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        do {
            let files = try fm.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil)
            for file in files where file.pathExtension.lowercased() == "png" {
                try fm.removeItem(at: file)
            }
        } catch {
            print("Failed to delete snapshots:", error)
        }
    }

    private func digest(_ url: URL) -> String {
        SHA256.hash(data: Data(url.absoluteString.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }

    private func fileURL(for url: URL) -> URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(digest(url) + ".png")
    }

    private func saveDisk(_ img: UIImage, for url: URL) {
        guard let data = img.pngData() else { return }
        try? data.write(to: fileURL(for: url), options: .atomic)
        
        NotificationCenter.default.post(name: .snapshotDidUpdate, object: url.absoluteString)
    }

    private final class NavDelegate: NSObject, WKNavigationDelegate {
        private var cont: CheckedContinuation<Void, Error>?
        private let cleanup: () -> Void

        init(_ cont: CheckedContinuation<Void, Error>, _ cleanup: @escaping () -> Void) {
            self.cont = cont
            self.cleanup = cleanup
        }

        private func finish(_ err: Error? = nil) {
            if let e = err { cont?.resume(throwing: e) }
            else          { cont?.resume() }
            cont = nil
            cleanup()
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            finish()
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            finish(error)
        }
        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation navigation: WKNavigation!,
                     withError error: Error) {
            finish(error)
        }
    }
}

/// Easy wrapper so you can inject this into any SwiftUI view
@MainActor
class SnapshotRefresher: ObservableObject {
    private let vm = SnapshotVM()
    func force(_ urlString: String) {
        vm.refresh(urlString: urlString)
    }
    func deleteAllSnapshots() {
        vm.deleteAllSnapshots()
    }
}
