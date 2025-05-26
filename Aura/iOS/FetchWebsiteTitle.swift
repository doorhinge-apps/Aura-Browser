//
// Aura
// FetchWebsiteTitle.swift
//
// Created on 26/5/25
//
// Copyright ©2025 DoorHinge Apps.
//


import Foundation

/// Fetches the <title> of the page at `urlString`, or returns `urlString` on failure.
func fetchTitle(from urlString: String) async -> String {
    // validate URL
    guard let url = URL(string: urlString) else {
        return urlString
    }
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let html = String(data: data, encoding: .utf8) else {
            return urlString
        }
        // extract <title>…</title>
        let regex = try NSRegularExpression(pattern: "<title>(.*?)</title>",
                                            options: .caseInsensitive)
        let range = NSRange(html.startIndex..., in: html)
        if let match = regex.firstMatch(in: html, range: range),
           let titleRange = Range(match.range(at: 1), in: html) {
            return String(html[titleRange])
        }
    } catch {
        // ignore network or parsing errors
    }
    return urlString
}
