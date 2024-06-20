//
//  ContentView.swift
//  Perplexity API
//
//  Created by Caedmon Myers on 19/6/24.
//

import SwiftUI

struct BrowseForMe: View {
    @State var searchText: String
    @State var searchResponse: String
    
    @Binding var closeSheet: Bool
    
    @State var searching = false
    
    @State var alternateColors = 1
    
    @State var colors1 = [
        Color.white, Color.white, Color.white,
        Color.white, Color.white, Color.white,
        Color.white, Color.white, Color.white
    ]
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ZStack {
                if #available(iOS 18.0, *) {
                    MeshGradient(width: 3, height: 3, points: [
                        .init(0, 0), .init(0.5, 0), .init(1, 0),
                        .init(0, 0.5), .init(0.5, 0.5), .init(1, 0.5),
                        .init(0, 1), .init(0.5, 1), .init(1, 1)
                    ], colors: colors1)
                }
                else {
                    LinearGradient(colors: Array(colors1.prefix(4)), startPoint: .top, endPoint: .bottom)
                }
                
                Color.white.opacity(searching ? 0.0: 0.5)
                
            }
            .ignoresSafeArea()
            .onReceive(timer) { _ in
                if searching {
                    withAnimation(.linear(duration: 1)) {
                        colors1.shuffle()
                    }
                }
            }
            
            ScrollView {
                VStack {
                    HStack {
                        TextField("Browse for me", text: $searchText, axis: .vertical)
                            .lineLimit(3)
                            .padding(15)
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .underline(!searchResponse.isEmpty)
                            .onSubmit {
                                if !searching {
                                    searchResponse = ""
                                    
                                    withAnimation(.linear(duration: 1)) {
                                        searching = true
                                    }
                                    
                                    Task {
                                        do {
                                            let response = try await getChatCompletion(prompt: searchText)
                                            searchResponse = response
                                            print("Response: \(response)")
                                        } catch {
                                            print("Error: \(error)")
                                        }
                                    }
                                }
                            }
                        
                        Button {
                            if !searching {
                                searchResponse = ""
                                
                                withAnimation(.linear(duration: 1)) {
                                    searching = true
                                }
                                
                                Task {
                                    do {
                                        let response = try await getChatCompletion(prompt: searchText)
                                        searchResponse = response
                                        print("Response: \(response)")
                                    } catch {
                                        print("Error: \(error)")
                                    }
                                }
                            }
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(LinearGradient(colors: [Color(hex: "EA96FF"), Color(hex: "7E7DD5"), Color(hex: "5957E5")], startPoint: .leading, endPoint: .trailing))
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 3)
                                
                                Text(searchResponse.isEmpty ? "Browse for me": "Search Again")
                                    .foregroundStyle(Color.white)
                                    .font(.system(.body, design: .rounded, weight: .bold))
                                
                            }
                                .frame(width: 150, height: 50)
                                .padding(.trailing, 10)
                        }
                        
                        Button {
                            closeSheet = false
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemRed))
                                    .opacity(0.5)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 3)
                                
                                Text("Close")
                                    .foregroundStyle(Color.white)
                                    .font(.system(.body, design: .rounded, weight: .bold))
                                
                            }
                                .frame(width: 100, height: 50)
                                .padding(.trailing, 20)
                        }

                    }
                    
                    if searching {
                        Text("Searching...")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .animation(.none)
                    }
                    
                    ParserView(markdownText: $searchResponse)
                    
                }
                
            }.onChange(of: searchResponse) {
                withAnimation(.linear(duration: 1)) {
                    searching = false
                }
            }
            .onChange(of: searching) {
                if searching {
                    withAnimation(.linear(duration: 1)) {
                        colors1 = [
                            Color(hex: "EA96FF"), .purple, .indigo,
                            Color(hex: "FAE8FF"), Color(hex: "F1C0FD"), Color(hex: "A6A6D6"),
                            .indigo, .purple, Color(hex: "EA96FF")
                        ]
                    }
                }
            }
        }.onAppear() {
            withAnimation(.linear(duration: 2)) {
                searching = true
            }
            
            Task {
                do {
                    let response = try await getChatCompletion(prompt: searchText)
                    searchResponse = response
                    print("Response: \(response)")
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
}

//#Preview {
//    BrowseForMe(searchText: .constant("How many stars in the galaxy?"), searchResponse: .constant(""))
//}
