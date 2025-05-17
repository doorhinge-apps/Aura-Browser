//
// Aura
// NewWebsiteManager.swift
//
// Created on 16/5/25
//
// Copyright ©2025 DoorHinge Apps.
//

import SwiftUI
import WebKit

final class NewWebsiteManager: ObservableObject {

    // # of live WebViews comes from user defaults
    @AppStorage("preloadingWebsites") private var preloadDouble: Double = 15

    /// insertion-order list so we can drop the oldest first
    @Published private var orderedIDs: [UUID] = []

    /// lookup table
    @Published private(set) var stores: [UUID: WebViewStore] = [:]

    /// currently focused page
    @Published var selectedID: UUID?

    var selectedStore: WebViewStore? { selectedID.flatMap { stores[$0] } }

    // MARK: public helpers ---------------------------------------------------

    func store(for id: UUID) -> WebViewStore? { stores[id] }

    /// opens `urlString`; re-uses an existing page if the URL already matches
    func open(urlString: String) {
        var raw = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !raw.hasPrefix("http://") && !raw.hasPrefix("https://") { raw = "https://" + raw }
        guard let url = URL(string: raw) else { return }
        open(url: url)
    }

    /// main create/reuse entry point
    func open(url: URL) {
        // reuse if already loaded
        if let (id, _) = stores.first(where: { $0.value.webView.url == url }) {
            selectedID = id
            return
        }

        // make a new WebViewStore
        let id    = UUID()
        let store = WebViewStore()
        store.webView.allowsBackForwardNavigationGestures = true
        store.loadIfNeeded(url: url)

        orderedIDs.append(id)
        stores[id]  = store
        selectedID  = id

        enforceLimit()
    }

    /// close a specific page
    func close(id: UUID) {
        stores.removeValue(forKey: id)
        orderedIDs.removeAll { $0 == id }
        if selectedID == id { selectedID = orderedIDs.last }
    }

    /// close them all
    func closeAll() {
        stores.removeAll()
        orderedIDs.removeAll()
        selectedID = nil
    }

    // MARK: internal ---------------------------------------------------------

    /// ensures we never exceed the user-defined limit
    private func enforceLimit() {
        let limit = max(1, Int(preloadDouble))
        while stores.count > limit, let oldest = orderedIDs.first {
            // never evict the active page
            if oldest == selectedID {
                orderedIDs.append(oldest)
                orderedIDs.removeFirst()
                continue
            }
            stores.removeValue(forKey: oldest)
            orderedIDs.removeFirst()
        }
    }
}
