//
//  ParseHTMLforAI.swift
//  Aura
//
//  Created by Reyna Myers on 9/7/24.
//

import SwiftUI

func parseHTMLAI(from htmlString: String) -> [String] {
    var results = [String]()
    
    // Regular expression to match HTML tags with class attributes
    let regexPattern = "<(\\w+)([^>]*)class\\s*=\\s*\"([^\"]+)\""
    
    do {
        let regex = try NSRegularExpression(pattern: regexPattern, options: [])
        let nsString = htmlString as NSString
        let resultsArray = regex.matches(in: htmlString, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in resultsArray {
            if match.numberOfRanges == 4 {
                let elementRange = match.range(at: 1)
                let classRange = match.range(at: 3)
                
                if let element = Range(elementRange, in: htmlString),
                   let classValue = Range(classRange, in: htmlString) {
                    let elementName = String(htmlString[element])
                    let className = String(htmlString[classValue])
                    let classArray = className.components(separatedBy: " ")
                    
                    for cls in classArray {
                        results.append("\(cls) - \(elementName)")
                    }
                }
            }
        }
        
        // If results are empty, extract all element types
        if results.isEmpty {
            let elementRegexPattern = "<(\\w+)"
            let elementRegex = try NSRegularExpression(pattern: elementRegexPattern, options: [])
            let elementResultsArray = elementRegex.matches(in: htmlString, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in elementResultsArray {
                if match.numberOfRanges == 2 {
                    let elementRange = match.range(at: 1)
                    
                    if let element = Range(elementRange, in: htmlString) {
                        let elementName = String(htmlString[element])
                        results.append(elementName)
                    }
                }
            }
        }
    } catch {
        print("Error creating regex: \(error)")
    }
    
    return results
}

