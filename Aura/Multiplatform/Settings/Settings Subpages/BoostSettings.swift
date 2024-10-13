//
// Aura
// BoostSettings.swift
//
// Created by Reyna Myers on 12/10/24
//
// Copyright ©2024 DoorHinge Apps.
//


import SwiftUI

struct BoostSettings: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var settings: SettingsVariables
    
    @State var startHex: String
    @State var endHex: String
    
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
                        Text("Boost Timeout")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                    }.padding(20)
                    
                    HStack {
                        Text("\(settings.jsInjectionDelayBoosts, specifier: "%.2f")s")
                            .foregroundStyle(Color.white)
                        
                        Slider(value: $settings.jsInjectionDelayBoosts, in: 0...20, step: 0.01)
                    }
                    .padding(.horizontal, 10)
                    
                    HStack {
                        Text("Change the interval before injecting the JavaScript with the boost into the website. A lower value will apply the boost faster, but might fail if the website hasn't loaded yet. Use lower values on fast internet connections and higher on slower ones. Support for automatic injection when the page loads is coming soon.")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    Spacer()
                        .frame(height: 20)
                }
            }
        }
#if !os(macOS)
        .toolbarBackground(.hidden, for: .navigationBar)
#endif
    }
}
