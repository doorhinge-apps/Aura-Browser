//
//  Favicons.swift
//  Aura
//
//  Created by Reyna Myers on 22/6/24.
//

import SwiftUI

struct Favicons: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var settings: SettingsVariables
    
    @State var startHex: String
    @State var endHex: String
    
    @State private var selectedFaviconShape: String = "circle"
    
    @State var iconRadius = 0
#if !os(macOS)
    @StateObject var motionManager = MotionManager()
    #endif
    private let maxDegrees: Double = 30
    private let rotationScale: Double = 0.5
    
    var body: some View {
        ZStack {
#if !os(visionOS)
            LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
            #endif
            
            if settings.prefferedColorScheme == "dark" || (settings.prefferedColorScheme == "automatic" && colorScheme == .dark) {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
            }
            
            ScrollView {
                VStack {
                    if settings.prefferedColorScheme == "dark" || (settings.prefferedColorScheme == "automatic" && colorScheme == .dark) {
                        Image("Aura Dark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .cornerRadius(CGFloat(iconRadius))
                            .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 0)
#if !os(visionOS) && !os(macOS)
                            .rotation3DEffect(
                                max(min(Angle.radians(motionManager.magnitude * rotationScale), Angle.degrees(maxDegrees)), Angle.degrees(-maxDegrees)),
                                axis: (x: CGFloat(UIDevice.current.orientation == .portrait ? motionManager.x: -motionManager.y), y: CGFloat(UIDevice.current.orientation == .portrait ? -motionManager.y: -motionManager.x), z: 0.0)
                            )
#elseif !os(macOS)
                            .hoverEffect(.lift)
                        #endif
                    }
                    else {
                        Image("Aura Light")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .cornerRadius(CGFloat(iconRadius))
                            .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 0)
#if !os(visionOS) && !os(macOS)
                            .rotation3DEffect(
                                max(min(Angle.radians(motionManager.magnitude * rotationScale), Angle.degrees(maxDegrees)), Angle.degrees(-maxDegrees)),
                                axis: (x: CGFloat(UIDevice.current.orientation == .portrait ? motionManager.x: -motionManager.y), y: CGFloat(UIDevice.current.orientation == .portrait ? -motionManager.y: -motionManager.x), z: 0.0)
                            )
#elseif !os(macOS)
                            .hoverEffect(.lift)
                        #endif
                    }
                    
                    HStack {
                        Text("Favicon Shape")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                    }.padding(20)
                    
                    Picker("Favicon Shape", selection: $selectedFaviconShape) {
                        Text("Square").tag("square")
                        Text("Squircle").tag("squircle")
                        Text("Circle").tag("circle")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedFaviconShape) { newValue in
                        withAnimation {
                            settings.faviconShape = newValue
                            
                            iconRadius = selectedFaviconShape == "square" ? 0: selectedFaviconShape == "squircle" ? 40: 100
                        }
                    }
#if !os(visionOS)
                    .background(Color.white.opacity(0.5).cornerRadius(7))
                    #endif
                    .padding([.leading, .trailing, .bottom])
                    
                    Divider()
                    
                    HStack {
                        Text("Favorites Show Website Names")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $settings.favoritesStyle, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    Divider()
                    
                    HStack {
                        Text("Load Favicons with SDWebImage")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $settings.faviconLoadingStyle, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    HStack {
                        Text("This allows for caching images more efficiently.")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    Spacer()
                        .frame(height: 20)
                }
            }.onAppear() {
                selectedFaviconShape = settings.faviconShape
                
                iconRadius = selectedFaviconShape == "square" ? 0: selectedFaviconShape == "squircle" ? 40: 100
            }
        }
#if !os(macOS)
        .toolbarBackground(.hidden, for: .navigationBar)
        #endif
    }
}

#Preview {
    Favicons(settings: SettingsVariables(), startHex: "8A3CEF", endHex: "84F5FE")
}
