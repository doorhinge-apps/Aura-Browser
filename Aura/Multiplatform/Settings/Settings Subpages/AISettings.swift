//
//  AISettings.swift
//  Aura
//
//  Created by Caedmon Myers on 10/7/24.
//

import SwiftUI

struct AISettings: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var settings: SettingsVariables
    
    @State var startHex: String
    @State var endHex: String
    
    @State private var selectedAppearance: String = "light"
    
    @State private var blackOverlayOpacity: Double = 0.0
    @State private var gradientStartPoint: UnitPoint = .bottomLeading
    @State private var gradientEndPoint: UnitPoint = .topTrailing
    @State private var halfOverlayOpacity: Double = 0.0
    
#if !os(macOS)
    @StateObject var motionManager = MotionManager()
#endif
    private let maxDegrees: Double = 30
    private let rotationScale: Double = 0.5
    
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    let fastTimer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    
    @State var showCommandBar = false
    
    @State var typingString = ""
    
    var body: some View {
        ZStack {
#if !os(visionOS)
            LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
#endif
            
            Color.black.opacity((settings.prefferedColorScheme == "dark" || (settings.prefferedColorScheme == "automatic" && colorScheme == .dark)) ? 0.5: 0.0)
                .ignoresSafeArea()
                .animation(.default)
            
            
            ScrollView {
                VStack {
                    Spacer()
                        .frame(height: 30)
                    
                    HStack {
                        Text("Perplexity API Key")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                    }.padding(20)
                    
                    TextField("API Key", text: $settings.apiKey)
                        .textFieldStyle(.plain)
                        .padding(.leading, 20)
                        .foregroundStyle(Color.white)
                    
                    HStack {
                        Text("Enter your Perplexity API key to use Browse for Me")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("ChatGPT API Key")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                    }.padding(20)
                    
                    TextField("API Key", text: $settings.openAPIKey)
                        .textFieldStyle(.plain)
                        .padding(.leading, 20)
                        .foregroundStyle(Color.white)
                    
                    HStack {
                        Text("Enter your ChatGPT API key use AI powered features.")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    Spacer()
                        .frame(height: 20)
                }
            }
            .onAppear {
                selectedAppearance = settings.prefferedColorScheme
                updateAppearance()
            }
        }
#if !os(macOS)
        .toolbarBackground(.hidden, for: .navigationBar)
#endif
    }
    
    private func updateAppearance() {
        switch settings.prefferedColorScheme {
        case "dark":
            blackOverlayOpacity = 0.5
        case "automatic":
            if colorScheme == .dark {
                blackOverlayOpacity = 0.5
            } else {
                blackOverlayOpacity = 0.0
            }
        default:
            blackOverlayOpacity = 0.0
        }
        
        // Trigger the animation by changing the start and end points
        gradientStartPoint = .topLeading
        gradientEndPoint = .bottomTrailing
    }
}
