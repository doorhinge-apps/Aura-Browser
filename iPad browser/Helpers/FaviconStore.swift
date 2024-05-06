//
//  FaviconStore.swift
//  Aura
//
//  Created by Quinn O'Donnell on 4/27/24.
//

import Foundation
import WebKit
import FaviconFinder

class FaviconStore: ObservableObject {
    @Published var favicons: [String: FaviconImage] = [:]
    
    func fetchFavicon(for webView: WKWebView) {
        guard let urlString = webView.url?.absoluteString else { return }
        
        // Avoid refetching if we already have the favicon.
        if favicons[urlString] != nil { return }
        
        Task {
            do {
                let favicon = try await FaviconFinder(url: webView.url!)
                    .fetchFaviconURLs()
                    .download()
                    .largest ()
                
                // Update the favicons dictionary.
                DispatchQueue.main.async {
                    self.favicons[urlString] = favicon.image
                }
            } catch {
                print("Failed to fetch favicon for \(urlString): \(error)")
            }
            
        }
    }
}
