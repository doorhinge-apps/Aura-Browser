//
//  CommandBar.swift
//  Aura
//
//  Created by Caedmon Myers on 1/5/24.
//

import SwiftUI

struct CommandBar: View {
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var settings: SettingsVariables
    
    @AppStorage("startColorHex") var startHex = "8A3CEF"
    @AppStorage("endColorHex") var endHex = "84F5FE"
    @AppStorage("textColorHex") var textHex = "ffffff"
    
    @Binding var commandBarText: String
    @State var suggestedSearch = ""
    
    @State var selectedSuggestion = -1
    
    @State var xmlString = ""
    
    @State var suggestions = [] as [String]
    
    @State var hoverSuggestion = ""
    
    @Binding var searchSubmitted: Bool
    
    @Binding var collapseHeightAnimation: Bool
    
    enum FocusedField {
        case commandBar, tabBar, none
    }
    
    @FocusState private var focusedField: FocusedField?
    
    @Binding var isBrowseForMe: Bool
    
    var body: some View {
        ZStack {
            //LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
            
            if !searchSubmitted {
                ZStack {
#if !os(visionOS)
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.regularMaterial)
                    #endif
                    
                    ScrollViewReader { proxy in
#if os(visionOS)
                        Spacer()
                            .frame(height: 25)
                        #endif
                        ZStack {
                            ScrollView {
                                Spacer()
                                    .frame(height: 60)
                                if !commandBarText.isEmpty {
                                    ZStack {
                                        Button(action: {
                                            searchSubmitted = true
                                        }, label: {
                                            ZStack {
#if !os(visionOS)
                                                if selectedSuggestion == -1 {
                                                    Color(hex: averageHexColor(hex1: startHex, hex2: endHex))
                                                        .cornerRadius(10)
                                                        .padding(5)
                                                        .padding(.horizontal, 5)
                                                }
                                                #else
                                                if selectedSuggestion == -1 {
                                                    Color.white.opacity(0.4)
                                                        .cornerRadius(10)
                                                        .padding(5)
                                                        .padding(.horizontal, 5)
                                                        .blur(radius: 30)
                                                }
                                                #endif
                                                
                                                HStack {
                                                    Text(commandBarText)
                                                        .lineLimit(1)
                                                        .foregroundStyle(Color(hex: selectedSuggestion == -1 ? textHex: "000000"))
                                                        .padding(.vertical, 27)
                                                        .padding(.horizontal, 25)
                                                    
                                                    Spacer()
                                                    
                                                    if !settings.hideBrowseForMe {
                                                        Button {
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                                                withAnimation(.linear, {
                                                                    isBrowseForMe = true
                                                                })
                                                            })
                                                            searchSubmitted = true
                                                        } label: {
                                                            Text("Browse for me")
#if !os(visionOS)
                                                                .foregroundStyle(selectedSuggestion == -1 ? LinearGradient(colors: [Color.white], startPoint: .leading, endPoint: .trailing): LinearGradient(colors: [Color(hex: "EA96FF"), Color(hex: "7E7DD5"), Color(hex: "5957E5")], startPoint: .leading, endPoint: .trailing))
#else
                                                                .foregroundStyle(Color.white)
#endif
                                                            
                                                        }
                                                        .buttonStyle(.plain)
                                                        .animation(.linear)
                                                    }
                                                    
                                                    Image(systemName: "arrow.right")
                                                        .foregroundStyle(Color(hex: selectedSuggestion == -1 ? textHex: "000000"))
                                                        .frame(width: selectedSuggestion != -1 ? 00: 40, height: 40)
                                                        .bold()
#if !os(macOS)
                                                        .hoverEffect(.lift)
                                                    #endif
                                                        .background(.ultraThinMaterial)
                                                        .cornerRadius(10)
                                                        .padding(.trailing, 20)
                                                        .animation(.default)
                                                    
                                                }
                                            }
                                        }).buttonStyle(.plain)
                                    }.id("veryLongStringForUnlikelySearchID")
                                }
                                
                                ForEach(suggestions, id:\.self) { suggestion in
                                    Button(action: {
                                        commandBarText = suggestion
                                        searchSubmitted = true
                                    }, label: {
                                        ZStack {
                                            if hoverSuggestion == suggestion {
                                                Color.gray
                                                    .opacity(0.5)
                                                    .cornerRadius(10)
                                                    .padding(5)
                                                    .padding(.horizontal, 5)
                                            }
                                            
#if !os(visionOS)
                                            if selectedSuggestion != -1 {
                                                if suggestions[selectedSuggestion] == suggestion {
                                                    Color(hex: averageHexColor(hex1: startHex, hex2: endHex))
                                                        .cornerRadius(10)
                                                        .padding(5)
                                                        .padding(.horizontal, 5)
                                                }
                                            }
                                            #else
                                            if selectedSuggestion != -1 {
                                                if suggestions[selectedSuggestion] == suggestion {
                                                    Color.white.opacity(0.4)
                                                        .cornerRadius(10)
                                                        .padding(5)
                                                        .padding(.horizontal, 5)
                                                        .blur(radius: 30)
                                                }
                                            }
                                            #endif
                                            
                                            HStack {
                                                Text(suggestion)
                                                    .lineLimit(1)
#if !os(visionOS)
                                                    .foregroundStyle(colorScheme == .light ? Color(hex: selectedSuggestion != -1 ? (suggestions[selectedSuggestion] == suggestion ? textHex: "000000"): "000000"): Color(hex: "ffffff"))
#else
                                                    .foregroundStyle(Color.white)
                                                #endif
                                                    .padding(.vertical, 27)
                                                    .padding(.horizontal, 25)
                                                
                                                Spacer()
                                                
                                                if !settings.hideBrowseForMe {
                                                    Button {
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                                                            withAnimation(.linear, {
                                                                isBrowseForMe = true
                                                            })
                                                        })
                                                        commandBarText = suggestion
                                                        searchSubmitted = true
                                                    } label: {
                                                        Text("Browse for me")
#if !os(visionOS)
                                                            .foregroundStyle(selectedSuggestion != -1 ? (suggestions[selectedSuggestion] == suggestion ? LinearGradient(colors: [Color.white], startPoint: .leading, endPoint: .trailing): LinearGradient(colors: [Color(hex: "EA96FF"), Color(hex: "7E7DD5"), Color(hex: "5957E5")], startPoint: .leading, endPoint: .trailing)): LinearGradient(colors: [Color(hex: "EA96FF"), Color(hex: "7E7DD5"), Color(hex: "5957E5")], startPoint: .leading, endPoint: .trailing))
#else
                                                            .foregroundStyle(Color.white)
#endif
                                                    }
                                                    .buttonStyle(.plain)
                                                    .animation(.linear)
                                                }
                                                
                                                
                                                Image(systemName: "arrow.right")
                                                    .foregroundStyle(Color(hex: selectedSuggestion != -1 ? (suggestions[selectedSuggestion] == suggestion ? textHex: "000000"): "000000"))
                                                    .frame(width: selectedSuggestion != -1 ? (suggestions[selectedSuggestion] == suggestion ? 40: 0): 0, height: 40)
                                                    .bold()
                                                    .clipped()
#if !os(macOS)
                                                    .hoverEffect(.lift)
                                                #endif
                                                    .background(.ultraThinMaterial)
                                                    .cornerRadius(10)
                                                    .padding(.trailing, 20)
                                                    .animation(.default)
                                                
                                            }
                                        }.id(suggestion)
                                            .onHover(perform: { hovering in
                                                if hovering {
                                                    hoverSuggestion = suggestion
                                                }
                                                else {
                                                    hoverSuggestion = ""
                                                }
                                            })
                                    }).buttonStyle(.plain)
                                }
                            }.frame(width: 600)
                            
                            VStack {
                                ZStack {
                                    TextField(text: selectedSuggestion == -1 ? $commandBarText: $suggestedSearch) {
                                        Label(selectedSuggestion == -1 ? "Search or Enter URL": "", systemImage: "magnifyingglass")
                                    }.onKeyPress(.downArrow, action: {
                                        if selectedSuggestion <= (suggestions.count - 2) {
                                            selectedSuggestion += 1
                                            
                                            suggestedSearch = suggestions[selectedSuggestion]
                                            withAnimation {
                                                proxy.scrollTo(suggestedSearch, anchor: .center)
                                            }
                                        }
                                        else {
                                            selectedSuggestion = -1
                                            
                                            withAnimation {
                                                proxy.scrollTo("veryLongStringForUnlikelySearchID", anchor: .center)
                                            }
                                        }
                                        
                                        return KeyPress.Result.handled
                                    })
                                    .onKeyPress(.upArrow, action: {
                                        if selectedSuggestion >= 0 {
                                            selectedSuggestion -= 1
                                            
                                            if selectedSuggestion != -1 {
                                                suggestedSearch = suggestions[selectedSuggestion]
                                                
                                                withAnimation {
                                                    proxy.scrollTo(suggestedSearch, anchor: .center)
                                                }
                                            }
                                            else {
                                                withAnimation {
                                                    proxy.scrollTo("veryLongStringForUnlikelySearchID", anchor: .center)
                                                }
                                            }
                                        }
                                        else {
                                            selectedSuggestion = suggestions.count - 1
                                            suggestedSearch = suggestions[selectedSuggestion]
                                            
                                            withAnimation {
                                                proxy.scrollTo(suggestedSearch, anchor: .center)
                                            }
                                        }
                                        
                                        
                                        return KeyPress.Result.handled
                                    })
                                    .textFieldStyle(.plain)
                                    .focused($focusedField, equals: .tabBar)
                                    .autocorrectionDisabled(true)
#if !os(macOS)
                                    .textInputAutocapitalization(.never)
                                    #endif
                                    .padding(20)
                                    .onChange(of: commandBarText, perform: { value in
                                        if !searchSubmitted {
                                            Task {
                                                await fetchXML(searchRequest: commandBarText)
                                            }
                                            
                                            Task {
                                                await suggestions = formatXML(from: xmlString)
                                            }
                                        }
                                        
                                    })
                                    .onSubmit {
                                        var newHistory = UserDefaults.standard.stringArray(forKey: "commandBarHistory") ?? ["arc.net", "thebrowser.company", "notion.so", "figma.com", "google.com", "apple.com"]
                                        newHistory.insert((selectedSuggestion == -1 ? commandBarText: suggestedSearch), at: 0)
                                        
                                        if newHistory.count > 10 {
                                            newHistory.removeLast()
                                        }
                                        
                                        newHistory.removeDuplicates()
                                        newHistory = Array(newHistory.prefix(10))
                                        
                                        UserDefaults.standard.set(newHistory, forKey: "commandBarHistory")
                                        
                                        if selectedSuggestion != -1 {
                                            commandBarText = suggestedSearch
                                        }
                                        
                                        
                                        searchSubmitted = true
                                        
                                        //suggestions = newHistory
                                    }
                                    .onAppear() {
                                        suggestions = UserDefaults.standard.stringArray(forKey: "commandBarHistory") ?? ["arc.net", "thebrowser.company", "notion.so", "figma.com", "google.com", "apple.com"]
                                    }
                                }
#if !os(visionOS)
                                .background(.thinMaterial)
                                #else
                                .background(.thinMaterial)
                                .cornerRadius(100)
                                #endif
                                
                                
                                Spacer()
                            }
                            
                        }
                    }
                }.frame(width: 600, height: 300)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.7), radius: 75, x: 0, y: 0)
            }
        }
        .onAppear() {
            withAnimation {
                collapseHeightAnimation = true
            }
            focusedField = .tabBar
        }
    }
    
    func fetchXML(searchRequest: String) {
        guard let url = URL(string: "https://toolbarqueries.google.com/complete/search?q=\(searchRequest.replacingOccurrences(of: " ", with: "+"))&output=toolbar&hl=en") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let xmlContent = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.xmlString = xmlContent
                }
            } else {
                print("Unable to convert data to string")
            }
        }.resume()
    }
    
    func formatXML(from input: String) -> [String] {
        var results = [String]()
        
        // Find all occurrences of 'data="' in the XML string
        var currentIndex = xmlString.startIndex
        while let startIndex = xmlString[currentIndex...].range(of: "data=\"")?.upperBound {
            let remainingSubstring = xmlString[startIndex...]
            
            // Find the end of the attribute value enclosed in quotation marks
            if let endIndex = remainingSubstring.range(of: "\"")?.lowerBound {
                let attributeValue = xmlString[startIndex..<endIndex]
                results.append(String(attributeValue))
                
                // Move to the next character after the found attribute value
                currentIndex = endIndex
            } else {
                break
            }
        }
        
        return results
    }
}



//#Preview {
//    CommandBar()
//}
