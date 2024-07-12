//
//  Browse for Me Mobile.swift
//  Aura
//
//  Created by Reyna Myers on 30/6/24.
//

import SwiftUI
import MarkdownUI


struct BrowseForMeMobile: View {
    @State var searchText: String
    @State var searchResponse: String
    
    @AppStorage("apiKey") var apiKey = ""
    
    @State var searching = false
    
    @State var alternateColors = 1
    
    @State var colors1 = [
        Color.white, Color.white, Color.white,
        Color.white, Color.white, Color.white,
        Color.white, Color.white, Color.white
    ]
    
    @State var offset: Double = 0
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var waveTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ZStack {
                if #available(iOS 18.0, visionOS 2.0, *) {
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
                    TextField("Browse for me", text: $searchText, axis: .vertical)
                        .lineLimit(3)
                        .padding(15)
                        .textFieldStyle(.plain)
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
                    
                    HStack {
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
                    }
                    
                    if apiKey.isEmpty {
                        Text("Please enter your API key in settings to use Browse for Me")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                    }
                    else {
                        if searching {
                            if #available(iOS 18.0, visionOS 2.0, *) {
                                Text("Searching...")
                                    .font(.system(.title2, design: .rounded, weight: .bold))
                                    .textRenderer(AnimatedSineWaveOffsetRender(timeOffset: offset))
                                    .onReceive(waveTimer) { _ in
                                        withAnimation(.linear(duration: 0.5), {
                                            if offset > 1_000_000_000_000 {
                                                offset = 0
                                            }
                                            offset += 10
                                        })
                                    }
                            }
                            else {
                                Text("Searching...")
                                    .font(.system(.title2, design: .rounded, weight: .bold))
                            }
                        }
                    }
                    
                    Markdown(searchResponse)
                        .preferredColorScheme(.light)
                        .padding(10)
                    
                    Spacer()
                        .frame(height: 150)
                }.foregroundStyle(Color.black)
                
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
            if searchResponse.isEmpty {
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
}
