//
// Aura
// WebPreview.swift
//
// Created on 16/5/25
//
// Copyright ©2025 DoorHinge Apps.
//


import SwiftUI
import WebKit

// MARK: — Custom tab model
struct TabItem: Identifiable {
    let id: UUID
    let url: URL
}

// MARK: — Simple WebView bridge
struct WebViewWrapper: UIViewRepresentable {
    let webView: WKWebView
    func makeUIView(context: Context)  -> WKWebView { webView }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: — Demo view
struct TabManagerView: View {
    @StateObject private var manager = NewWebsiteManager()

    // three tabs, two of which deliberately share the same URL
    @State private var tabs: [TabItem] = [
        TabItem(id: UUID(), url: URL(string: "https://apple.com")!),
        TabItem(id: UUID(), url: URL(string: "https://google.com")!),
        TabItem(id: UUID(), url: URL(string: "https://apple.com")!)
    ]

    @State private var selectedTabID: UUID?

    var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(tabs) { tab in
                        Button(action: {
                            selectedTabID = tab.id
                            manager.open(url: tab.url)
                        }) {
                            Text(tab.url.host ?? tab.url.absoluteString)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    selectedTabID == tab.id
                                        ? Capsule().fill(Color.blue.opacity(0.2))
                                        : Capsule().fill(Color.clear)
                                )
                        }
                    }
                }
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
            }

            Divider()

            // Navigation controls
            HStack(spacing: 20) {
                Button("Back")    { manager.selectedStore?.webView.goBack() }
                    .disabled(!(manager.selectedStore?.webView.canGoBack ?? false))
                Button("Forward") { manager.selectedStore?.webView.goForward() }
                    .disabled(!(manager.selectedStore?.webView.canGoForward ?? false))
                Button("Reload")  { manager.selectedStore?.webView.reload() }
            }
            .buttonStyle(.bordered)
            .padding(.vertical, 6)

            Divider()

            // Content area
            if let store = manager.selectedStore {
                WebViewWrapper(webView: store.webView)
                    .transition(.opacity)
                    .id(store.webView)
            } else {
                Text("No tab selected")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            // Preload every tab once
            for tab in tabs {
                manager.open(url: tab.url)
            }
            selectedTabID = tabs.first?.id
        }
    }
}
