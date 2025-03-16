//
//  UISettings.swift
//  Aura
//
//  Created by Reyna Myers on 23/6/24.
//

import SwiftUI

struct UISettings: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var settings: SettingsVariables
    
    @State var startHex: String
    @State var endHex: String
    
    @State private var selectedAppearance: String = "light"
    @State private var forceDarkModeSelection: String = "advanced"
    @State private var forceDarkModeTimeSelection: String = "system"
    
    @State private var blackOverlayOpacity: Double = 0.0
    @State private var gradientStartPoint: UnitPoint = .bottomLeading
    @State private var gradientEndPoint: UnitPoint = .topTrailing
    @State private var halfOverlayOpacity: Double = 0.0
    
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
            
            
            Color.black.opacity((settings.prefferedColorScheme == "dark" || (settings.prefferedColorScheme == "automatic" && colorScheme == .dark)) ? 0.5: 0.0)
                    .ignoresSafeArea()
                    .animation(.default)
            
            
            ScrollView {
                VStack {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        Image("iOS Settings Image")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(15)
                            .frame(width: 150)
                        #if !os(visionOS)
                            .rotation3DEffect(
                                max(min(Angle.radians(motionManager.magnitude * rotationScale), Angle.degrees(maxDegrees)), Angle.degrees(-maxDegrees)),
                                axis: (x: CGFloat(UIDevice.current.orientation == .portrait ? motionManager.x: -motionManager.y), y: CGFloat(UIDevice.current.orientation == .portrait ? -motionManager.y: -motionManager.x), z: 0.0)
                            )
                        #endif
                    }
                    else {
                        ZStack {
#if !os(visionOS)
                            LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: gradientStartPoint, endPoint: gradientEndPoint)
                                .ignoresSafeArea()
                                .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 0)
                                .animation(.easeInOut(duration: 1), value: gradientStartPoint)
                                .animation(.easeInOut(duration: 1), value: gradientEndPoint)
#endif
                            
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
#if !os(visionOS) && !os(macOS)
                            .rotation3DEffect(
                                max(min(Angle.radians(motionManager.magnitude * rotationScale), Angle.degrees(maxDegrees)), Angle.degrees(-maxDegrees)),
                                axis: (x: CGFloat(UIDevice.current.orientation == .portrait ? motionManager.x: -motionManager.y), y: CGFloat(UIDevice.current.orientation == .portrait ? -motionManager.y: -motionManager.x), z: 0.0)
                            )
#elseif !os(macOS)
                            .hoverEffect(.lift)
#endif
                        
                    }
                    Spacer()
                        .frame(height: 30)
                    
                    Picker("", selection: $selectedAppearance) {
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
#if !os(visionOS)
                    .background(Color.white.opacity(0.5).cornerRadius(7))
                    #endif
                    .padding([.leading, .trailing, .bottom])
                    
                    VStack {
                        HStack {
                            Text("Force Dark Mode On Websites (beta)")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.white)
                        }
                        
                        Picker("", selection: $forceDarkModeSelection) {
                            Text("None").tag("none")
                            Text("Basic").tag("basic")
                            Text("Advanced").tag("advanced")
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: forceDarkModeSelection) { newValue in
                            withAnimation {
                                settings.forceDarkMode = newValue
                            }
                        }
#if !os(visionOS)
                        .background(Color.white.opacity(0.5).cornerRadius(7))
#endif
                        .padding([.leading, .trailing, .bottom])
                        
                        Picker("", selection: $forceDarkModeTimeSelection) {
                            Text("System").tag("system")
                            Text("Light").tag("light")
                            Text("Dark").tag("dark")
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: forceDarkModeTimeSelection) { newValue in
                            withAnimation {
                                settings.forceDarkModeTime = newValue
                            }
                        }
#if !os(visionOS)
                        .background(Color.white.opacity(0.5).cornerRadius(7))
#endif
                        .padding([.leading, .trailing, .bottom])
                        
                        
                        HStack {
                            Text("This will attempt to force dark mode on websites that don't support it. Selecting 'basic' will invert some colors that are very close to black and white. Selecting 'advanced' will apply a more advanced effect that will work on more websites, but may cause readability issues sometime (please report these as a bug and say what website had the issues). You can also decide if this is never enabled, always enabled, or matches system appearance.")
                                .foregroundStyle(Color.white)
                                .padding(.leading, 20)
                            
                            Spacer()
                        }
                    }
                    
#if os(iOS)
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
                    
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        HStack {
                            Text("Grid Columns")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.white)
                            
                            Spacer()
                            
                            Slider(value: $settings.gridColumnCount, in: 1...5, step: 1)
                                .scaleEffect(0.75)
                        }.padding(20)
                        
                        Divider()
                    }
                    
                    #endif
                    
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
                        Text("Favorite Tab Corner Radius")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                    }.padding(20)
                    
                    HStack {
                        Text(Int(settings.favoriteTabCornerRadius).description)
                            .foregroundStyle(Color.white)
                        
                        Slider(value: $settings.favoriteTabCornerRadius, in: 0...50, step: 1)
                    }
                    .padding(.horizontal, 10)
                    
                    HStack {
                        Text("Change the corner radius of the favorite tab capsules in the sidebar.")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    
                    HStack {
                        Text("Favorite Tab Border Width")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                    }.padding(20)
                    
                    HStack {
                        Text(Int(settings.favoriteTabBorderWidth).description)
                            .foregroundStyle(Color.white)
                        
                        Slider(value: $settings.favoriteTabBorderWidth, in: 0...10, step: 1)
                        
                    }
                    .padding(.horizontal, 10)
                    
                    HStack {
                        Text("Change the width of the favorite tabs borders.")
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
                    
                    Divider()
                    
                    HStack {
                        Text("Horizontal Sidebar")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $settings.horizontalTabBar, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    
                    HStack {
                        Text("Make the sidebar horizontal.")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Launch Animation")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $settings.launchAnimation, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    
                    HStack {
                        Text("Animate from the launch screen to the app when you open it.")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("This makes launch slightly slower, but the UI will be less buggy and more tabs will be loaded.")
                            .foregroundStyle(Color.white)
                            .font(Font.caption)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    
                    HStack {
                        Text("Share Button in Tab Bar")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $settings.shareButtonInTabBar, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    
                    HStack {
                        Text("Shows the button to share a website in the tab bar.")
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
                forceDarkModeSelection = settings.forceDarkMode
                forceDarkModeTimeSelection = settings.forceDarkModeTime
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


func randomString(length: Int) -> String {
  let letters = "abcd efghijkl mnopqrstuvwxyz ABCDEFGHIJK LMNOPQRSTUVWXYZ "
  return String((0..<length).map{ _ in letters.randomElement()! })
}


#Preview {
    UISettings(settings: SettingsVariables(), startHex: "8A3CEF", endHex: "84F5FE")
}

