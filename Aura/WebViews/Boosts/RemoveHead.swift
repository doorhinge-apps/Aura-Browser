//
//  RemoveHead.swift
//  Aura
//
//  Created by Caedmon Myers on 9/7/24.
//

import SwiftUI

func removeHeadContent(from htmlString: String) -> String {
    let pattern = "<head>.*?</head>"
    guard let regex = try? NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators) else {
        return htmlString
    }
    let range = NSRange(location: 0, length: htmlString.utf16.count)
    let modifiedString = regex.stringByReplacingMatches(in: htmlString, options: [], range: range, withTemplate: "")
    return modifiedString
}
