//
//  urlFormatter.swift
//  iPad browser
//
//  Created by Caedmon Myers on 15/4/24.
//

import SwiftUI

func formatURL(from input: String) -> String {
    // Check if it's already a URL with a scheme
    if let url = URL(string: input), url.scheme != nil {
        return url.absoluteString.hasPrefix("http") ? input : "https://\(input)"
    }
    
    // Check if it's a URL without a scheme
    if let url = URL(string: "https://\(input)"), url.host != nil {
        if url.absoluteString.contains(".") && !url.absoluteString.contains(" ") {
            return url.absoluteString
        }
    }
    
    // Assume it's a search term and format it for Google search
    let searchTerms = input.split(separator: " ").joined(separator: "+")
    return "\(UserDefaults.standard.string(forKey: "searchEngine") ?? "https://www.google.com/search?q=")\(searchTerms)"
}
