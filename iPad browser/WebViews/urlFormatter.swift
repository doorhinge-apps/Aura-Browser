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


func unformatURL(url: String) -> String {
    let searchEngine = UserDefaults.standard.string(forKey: "searchEngine") ?? "https://www.google.com/search?q="
    
    var formattedUrl = url
    if url.starts(with: searchEngine) {
        formattedUrl = formattedUrl.replacingOccurrences(of: searchEngine, with: "")
        //formattedUrl.removeEverythingAfter(str: "&")
        formattedUrl = formattedUrl.components(separatedBy: "&")[0]
        if formattedUrl.last == "/" {
            formattedUrl.removeLast()
        }
        formattedUrl = formattedUrl.replacingOccurrences(of: "+", with: " ")
        formattedUrl = formattedUrl.replacingOccurrences(of: "%20", with: " ")
    }
    else {
        formattedUrl = formattedUrl.replacingOccurrences(of: "https://", with: "")
        formattedUrl = formattedUrl.replacingOccurrences(of: "http://", with: "")
        formattedUrl = formattedUrl.replacingOccurrences(of: "www.", with: "")
        if formattedUrl.last == "/" {
            formattedUrl.removeLast()
        }
    }
    
    
    return formattedUrl
}
