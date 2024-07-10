//
//  MarkdownParser.swift
//  Perplexity API
//
//  Created by Caedmon Myers on 20/6/24.
//

import SwiftUI

// MARK: - Models

enum MarkdownElement {
    case heading(level: Int, text: String)
    case paragraph(text: String)
    case styledText(text: [StyledText])
    case bulletPoint(text: String)
    
    struct StyledText: Identifiable {
        let id = UUID()
        let text: String
        let style: TextStyle
        
        enum TextStyle {
            case normal
        }
    }
}

class MarkdownParser {
    func parse(_ text: String) -> [MarkdownElement] {
        var elements: [MarkdownElement] = []
        
        let lines = text.split(separator: "\n")
        for line in lines {
            if line.starts(with: "#") {
                let headingLevel = line.prefix(while: { $0 == "#" }).count
                let text = line.dropFirst(headingLevel).trimmingCharacters(in: .whitespaces)
                elements.append(.heading(level: headingLevel, text: String(text).replacingOccurrences(of: "**", with: "")))
            } else if line.starts(with: "- ") {
                let text = line.dropFirst(2).trimmingCharacters(in: .whitespaces)
                elements.append(.bulletPoint(text: String(text).replacingOccurrences(of: "**", with: "")))
            } else {
                elements.append(.styledText(text: parseStyledText(String(line).replacingOccurrences(of: "**", with: ""))))
            }
        }
        
        return elements
    }
    
    private func parseStyledText(_ text: String) -> [MarkdownElement.StyledText] {
        var styledTexts: [MarkdownElement.StyledText] = []
        var currentText = ""
        var isBold = false
        var isItalic = false
        
        var skipNext = false
        for (index, char) in text.enumerated() {
            if skipNext {
                skipNext = false
                continue
            }
            
            if char == "*" {
                if index + 1 < text.count, text[text.index(text.startIndex, offsetBy: index + 1)] == "*" {
                    isBold.toggle()
                    skipNext = true
                    if !currentText.isEmpty {
                        styledTexts.append(MarkdownElement.StyledText(text: currentText, style: .normal))
                        currentText = ""
                    }
                } else {
                    isItalic.toggle()
                    if !currentText.isEmpty {
                        styledTexts.append(MarkdownElement.StyledText(text: currentText, style: .normal))
                        currentText = ""
                    }
                }
            } else {
                currentText.append(char)
            }
        }
        
        if !currentText.isEmpty {
            styledTexts.append(MarkdownElement.StyledText(text: currentText, style: .normal))
        }
        
        return styledTexts
    }
}

// MARK: - Views

struct MarkdownView: View {
    let elements: [MarkdownElement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<elements.count, id: \.self) { index in
                switch elements[index] {
                case .heading(let level, let text):
                    HeadingView(level: level, text: text)
                case .paragraph(let text):
                    ParagraphView(text: text)
                case .styledText(let text):
                    StyledTextView(texts: text)
                case .bulletPoint(let text):
                    BulletPointView(text: text)
                }
            }
        }
        .padding()
    }
}

struct HeadingView: View {
    let level: Int
    let text: String
    
    var body: some View {
        switch level {
        case 1:
            Text(text).font(.largeTitle).bold()
        case 2:
            Text(text).font(.title).bold()
        case 3:
            Text(text).font(.title2).bold()
        default:
            Text(text).font(.headline).bold()
        }
    }
}

struct ParagraphView: View {
    let text: String
    
    var body: some View {
        Text(text).font(.body)
    }
}

struct StyledTextView: View {
    let texts: [MarkdownElement.StyledText]
    
    var body: some View {
        texts.reduce(Text(""), { result, styledText in
            let styledTextComponent: Text
            styledTextComponent = Text(styledText.text)
            return result + styledTextComponent
        })
    }
}

struct BulletPointView: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text("•").bold()
            Text(text).font(.body)
        }
    }
}

struct ParserView: View {
    @Binding var markdownText: String
    
    var body: some View {
        let parser = MarkdownParser()
        let elements = parser.parse(markdownText)
        
        return MarkdownView(elements: elements)
    }
}
