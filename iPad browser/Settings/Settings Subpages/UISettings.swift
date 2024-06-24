//
//  UISettings.swift
//  Aura
//
//  Created by Caedmon Myers on 23/6/24.
//

import SwiftUI

struct UISettings: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var settings: SettingsVariables
    
    @State var startHex: String
    @State var endHex: String
    
    @State private var selectedAppearance: String = "light"
    
    @State private var blackOverlayOpacity: Double = 0.0
    @State private var gradientStartPoint: UnitPoint = .bottomLeading
    @State private var gradientEndPoint: UnitPoint = .topTrailing
    @State private var halfOverlayOpacity: Double = 0.0
    
    @StateObject var motionManager = MotionManager()
    private let maxDegrees: Double = 30
    private let rotationScale: Double = 0.5
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
            
            
            Color.black.opacity((settings.prefferedColorScheme == "dark" || (settings.prefferedColorScheme == "automatic" && colorScheme == .dark)) ? 0.5: 0.0)
                    .ignoresSafeArea()
                    .animation(.default)
            
            
            ScrollView {
                VStack {
                    ZStack {
                        LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: gradientStartPoint, endPoint: gradientEndPoint)
                            .ignoresSafeArea()
                            .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 0)
                            .animation(.easeInOut(duration: 1), value: gradientStartPoint)
                            .animation(.easeInOut(duration: 1), value: gradientEndPoint)
                        
                            LinearGradient(colors: [settings.prefferedColorScheme != "dark" ? Color.clear: Color.black.opacity(0.5), settings.prefferedColorScheme != "dark" ? Color.clear: Color.black.opacity(0.5), settings.prefferedColorScheme == "light" ? Color.clear: Color.black.opacity(0.5), settings.prefferedColorScheme == "light" ? Color.clear: Color.black.opacity(0.5)], startPoint: .topLeading, endPoint: .bottom)
                                .ignoresSafeArea()
                                .animation(.easeInOut(duration: 1))
                        
                        HStack {
                            if !settings.sidebarLeft {
                                Image("Arc Website")
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(5)
                                    .padding([.top, .bottom, .leading], settings.showBorder ? 5: 0)
                                
                                Spacer()
                            }
                            
                            ScrollView(showsIndicators: false) {
                                VStack {
                                    Spacer()
                                        .frame(height: 10)
                                    HStack {
                                        ForEach(0...1, id:\.self) { thing in
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(Color.white.opacity(0.5))
                                                
                                                HStack {
                                                    Text("\(randomString(length: 3))")
                                                    
                                                }.font(.system(size: 7, weight: .regular, design: .rounded))
                                                    .padding(.horizontal, 5)
                                            }.frame(width: 29, height: 15)
                                        }
                                    }
                                    ForEach(0..<6, id:\.self) { fakeTab in
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.white.opacity(0.5))
                                            
                                            HStack {
                                                Text("\(randomString(length: 10))")
                                                
                                                Spacer()
                                                
                                                Image(systemName: "xmark")
                                                
                                            }.font(.system(size: 7, weight: .regular, design: .rounded))
                                                .padding(.horizontal, 5)
                                        }.frame(width: 65, height: 15)
                                    }
                                }.padding(settings.sidebarLeft ? .leading: .trailing, 10)
                            }
                            
                            if settings.sidebarLeft {
                                Spacer()
                                
                                Image("Arc Website")
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(5)
                                    .padding([.top, .bottom, .trailing], settings.showBorder ? 5: 0)
                            }
                        }
                    }.frame(width: 300, height: 200)
                        .cornerRadius(8)
                        .foregroundStyle(Color.white)
                        .rotation3DEffect(
                            max(min(Angle.radians(motionManager.magnitude * rotationScale), Angle.degrees(maxDegrees)), Angle.degrees(-maxDegrees)),
                            axis: (x: CGFloat(UIDevice.current.orientation == .portrait ? motionManager.x: -motionManager.y), y: CGFloat(UIDevice.current.orientation == .portrait ? -motionManager.y: -motionManager.x), z: 0.0)
                        )
                    
                    Spacer()
                        .frame(height: 30)
                    
                    Picker("Favicon Shape", selection: $selectedAppearance) {
                        Text("Automatic").tag("automatic")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedAppearance) { newValue in
                        withAnimation {
                            settings.prefferedColorScheme = newValue
                            updateAppearance()
                        }
                    }
                    .background(Color.white.opacity(0.5).cornerRadius(7))
                    .padding([.leading, .trailing, .bottom])
                    
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        HStack {
                            Text("Hover Effects Absorb Cursor")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.white)
                            
                            Spacer()
                            
                            CustomToggleSlider(toggle: $settings.hoverEffectsAbsorbCursor, startHex: startHex, endHex: endHex)
                                .scaleEffect(0.75)
                        }.padding(20)
                        
                        Divider()
                    }
                    
                    HStack {
                        Text("Show Border")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $settings.showBorder, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    HStack {
                        Text("Show the border around the screen.")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Sidebar Left")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $settings.sidebarLeft, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    
                    HStack {
                        Text("Switch between left and right sidebar location")
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
        }.toolbarBackground(.hidden, for: .navigationBar)
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


func randomString(length: Int) -> String {
  let letters = "abcd efghijkl mnopqrstuvwxyz ABCDEFGHIJK LMNOPQRSTUVWXYZ "
  return String((0..<length).map{ _ in letters.randomElement()! })
}


#Preview {
    UISettings(settings: SettingsVariables(), startHex: "8A3CEF", endHex: "84F5FE")
}

