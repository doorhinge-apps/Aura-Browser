//
//  SuggestionsData.swift
//  iPad browser
//
//  Created by Caedmon Myers on 3/4/24.
//

import SwiftUI

struct SuggestionsView: View {
    @Binding var newTabSearch: String
    @Binding var newTabSaveSearch: String
    @State var suggestionUrls2: [String] // Declaring suggestionUrls2 as a state variable
    
    @AppStorage("startColorHex") var startHex = "ffffff"
    @AppStorage("endColorHex") var endHex = "000000"
    
    @State var selectedIndex = 0

    init(newTabSearch: Binding<String>, newTabSaveSearch: Binding<String>, suggestionUrls: [String]) {
        self._newTabSearch = newTabSearch
        self._newTabSaveSearch = newTabSaveSearch
        self._suggestionUrls2 = State(initialValue: suggestionUrls) // Initializing suggestionUrls2
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                ForEach(suggestionUrls2.filter { $0.replacingOccurrences(of: "www.", with: "")
                        .replacingOccurrences(of: "https://", with: "")
                        .replacingOccurrences(of: "http://", with: "")
                        .lowercased()
                        .hasPrefix(newTabSearch.replacingOccurrences(of: "www.", with: "")
                            .replacingOccurrences(of: "https://", with: "")
                            .replacingOccurrences(of: "http://", with: "")
                            .lowercased()
                        )
                }.prefix(10), id: \.self) { suggestion in
                    ZStack {
                        if suggestionUrls2.filter({ $0.replacingOccurrences(of: "www.", with: "")
                                .replacingOccurrences(of: "https://", with: "")
                                .replacingOccurrences(of: "http://", with: "")
                                .lowercased()
                                .hasPrefix(newTabSearch.replacingOccurrences(of: "www.", with: "")
                                    .replacingOccurrences(of: "https://", with: "")
                                    .replacingOccurrences(of: "http://", with: "")
                                    .lowercased()
                                )
                        }).prefix(10)[selectedIndex] == suggestion && selectedIndex != 11 {
                            //LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .leading, endPoint: .trailing)
                            Color(hex: averageHexColor(hex1: startHex, hex2: endHex))
                                .cornerRadius(7)
                                .opacity(0.75)
                        }
                        
                        Text(suggestion)
                            .opacity(0.8)
                        
                    }.frame(width: 525, height: 60)
                        .id(suggestionUrls2.filter { $0.replacingOccurrences(of: "www.", with: "")
                                .replacingOccurrences(of: "https://", with: "")
                                .replacingOccurrences(of: "http://", with: "")
                                .lowercased()
                                .hasPrefix(newTabSearch.replacingOccurrences(of: "www.", with: "")
                                    .replacingOccurrences(of: "https://", with: "")
                                    .replacingOccurrences(of: "http://", with: "")
                                    .lowercased()
                                )
                        }.prefix(10).firstIndex(of: suggestion))
                }
                Button(action: {
                    if selectedIndex < suggestionUrls2.filter({ $0.replacingOccurrences(of: "www.", with: "")
                            .replacingOccurrences(of: "https://", with: "")
                            .replacingOccurrences(of: "http://", with: "")
                            .lowercased()
                            .hasPrefix(newTabSearch.replacingOccurrences(of: "www.", with: "")
                                .replacingOccurrences(of: "https://", with: "")
                                .replacingOccurrences(of: "http://", with: "")
                                .lowercased()
                            )
                    }).prefix(10).count - 1 {
                        selectedIndex += 1
                    } else {
                        selectedIndex = 0
                    }
                    
                    withAnimation {
                        proxy.scrollTo(selectedIndex)
                    }
                    
//                    newTabSearch = suggestionUrls2.filter { $0.replacingOccurrences(of: "www.", with: "")
//                            .replacingOccurrences(of: "https://", with: "")
//                            .replacingOccurrences(of: "http://", with: "")
//                            .lowercased()
//                            .hasPrefix(newTabSearch.replacingOccurrences(of: "www.", with: "")
//                                .replacingOccurrences(of: "https://", with: "")
//                                .replacingOccurrences(of: "http://", with: "")
//                                .lowercased()
//                            )
//                    }.prefix(10)[1]
                    
                }, label: {
                }).opacity(0.0)
                    .keyboardShortcut(.downArrow, modifiers: [.command, .option])
                    .keyboardShortcut(.downArrow)
                
                Button(action: {
                    if selectedIndex > 0 {
                        selectedIndex -= 1
                    } else {
                        selectedIndex = suggestionUrls2.filter { $0.replacingOccurrences(of: "www.", with: "")
                                .replacingOccurrences(of: "https://", with: "")
                                .replacingOccurrences(of: "http://", with: "")
                                .lowercased()
                                .hasPrefix(newTabSearch.replacingOccurrences(of: "www.", with: "")
                                    .replacingOccurrences(of: "https://", with: "")
                                    .replacingOccurrences(of: "http://", with: "")
                                    .lowercased()
                                )
                        }.prefix(10).count - 1
                    }
                    
                    withAnimation {
                        proxy.scrollTo(selectedIndex)
                    }
                    
                    newTabSearch = suggestionUrls2.filter({ $0.replacingOccurrences(of: "www.", with: "")
                            .replacingOccurrences(of: "https://", with: "")
                            .replacingOccurrences(of: "http://", with: "")
                            .lowercased()
                            .hasPrefix(newTabSearch.replacingOccurrences(of: "www.", with: "")
                                .replacingOccurrences(of: "https://", with: "")
                                .replacingOccurrences(of: "http://", with: "")
                                .lowercased()
                            )
                    }).prefix(10)[selectedIndex - 1]
                    
//                    newTabSearch = suggestionUrls2.filter { $0.replacingOccurrences(of: "www.", with: "")
//                            .replacingOccurrences(of: "https://", with: "")
//                            .replacingOccurrences(of: "http://", with: "")
//                            .lowercased()
//                            .hasPrefix(newTabSearch.replacingOccurrences(of: "www.", with: "")
//                                .replacingOccurrences(of: "https://", with: "")
//                                .replacingOccurrences(of: "http://", with: "")
//                                .lowercased()
//                            )
//                    }.prefix(10)[selectedIndex]
                }, label: {
                }).opacity(0.0)
                    .keyboardShortcut(.upArrow, modifiers: [.command, .option])
                    .keyboardShortcut(.upArrow)
            }
            .onChange(of: newTabSearch) { newValue in
                if suggestionUrls2.filter { $0.replacingOccurrences(of: "www.", with: "")
                        .replacingOccurrences(of: "https://", with: "")
                        .replacingOccurrences(of: "http://", with: "")
                        .lowercased()
                        .hasPrefix(newTabSearch.replacingOccurrences(of: "www.", with: "")
                            .replacingOccurrences(of: "https://", with: "")
                            .replacingOccurrences(of: "http://", with: "")
                            .lowercased()
                        )
                }.prefix(10).count > 10 {
                    
                }
                
                selectedIndex = 0
                
                withAnimation {
                    proxy.scrollTo(selectedIndex)
                }
            }
        }
    }
}






// Sample dataset of search queries
// Sample dataset of search queries
let sampleQueries = [
    "machine learning",
    "swift programming",
    "data science",
    "python tutorial",
    "deep learning",
    "web development",
    "computer science",
    "java programming",
    "artificial intelligence",
    "software engineering",
    "javascript tutorial",
    "data analysis",
    "android development",
    "iOS app development",
    "cloud computing",
    "network security",
    "computer vision",
    "natural language processing",
    "database management",
    "algorithm design",
    "mobile application development",
    "frontend development",
    "backend development",
    "game development",
    "user interface design",
    "graphic design",
    "digital marketing",
    "search engine optimization",
    "social media marketing",
    "e-commerce",
    "machine learning algorithms",
    "data visualization",
    "cybersecurity",
    "blockchain technology",
    "internet of things",
    "augmented reality",
    "virtual reality",
    "big data analytics",
    "cloud storage",
    "computer programming basics",
    "coding interview preparation",
    "online courses",
    "programming languages",
    "technology trends",
    "coding bootcamp",
    "software development tools",
    "version control systems",
    "agile methodology",
    "project management",
    "productivity tips",
    "remote work",
    "work-life balance",
    "health and wellness",
    "cooking recipes",
    "home workouts",
    "travel destinations",
    "financial planning",
    "personal finance",
    "self-improvement",
    "mindfulness meditation",
    "stress management",
    "relationship advice",
    "parenting tips",
    "pet care",
    "gardening tips",
    "DIY projects",
    "home decor ideas",
    "fashion trends",
    "beauty tips",
    "book recommendations",
    "movie reviews",
    "music playlists",
    "video game reviews",
    "sports news",
    "celebrity gossip",
    "political news",
    "current events"
]


// Function to preprocess the search queries
func preprocess(_ query: String) -> [String] {
    return query.lowercased().components(separatedBy: " ")
}

// Function to train a Naive Bayes classifier
func trainModel(_ queries: [String]) -> [String: Int] {
    var wordCounts: [String: Int] = [:]
    
    for query in queries {
        let tokens = preprocess(query)
        for token in tokens {
            wordCounts[token, default: 0] += 1
        }
    }
    
    return wordCounts
}

// Function to predict autocomplete suggestions with multiple words
func predict(_ prefix: String, model: [String: Int]) -> [String] {
    let prefixTokens = preprocess(prefix)
    var suggestions: [String] = []
    
    // Try to find suggestions starting from each token in the prefix
    for i in 0..<prefixTokens.count {
        var currentPrefix = ""
        for j in i..<prefixTokens.count {
            currentPrefix += prefixTokens[j] + " "
            let partialSuggestions = model.keys.filter { $0.hasPrefix(currentPrefix.trimmingCharacters(in: .whitespacesAndNewlines)) }
            suggestions += partialSuggestions
        }
    }
    
    // Remove duplicates and return top suggestions
    suggestions = Array(Set(suggestions).prefix(3))
    return suggestions
}


// Train the model
var model = trainModel(suggestionWordsData)

// Function to update model with user input
func updateModel(with userInput: String) {
    let tokens = preprocess(userInput)
    for token in tokens {
        model[token, default: 0] += 1
    }
}



