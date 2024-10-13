//
//  General.swift
//  Aura
//
//  Created by Reyna Myers on 23/6/24.
//

import SwiftUI

struct General: View {
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
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        Image(settings.commandBarOnLaunch ? "iOS Settings Image Keyboard": "iOS Settings Image")
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
                            
                            if !showCommandBar && settings.commandBarOnLaunch {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(.regularMaterial)
                                    
                                    VStack {
                                        ZStack {
                                            HStack {
                                                Text("\(typingString)")
                                                
                                                Spacer()
                                                
                                            }.font(.system(size: 7, weight: .regular, design: .rounded))
                                                .padding(.horizontal, 5)
                                        }.frame(height: 10)
                                        
                                        ForEach(0..<3, id:\.self) { fakeTab in
                                            ZStack {
                                                HStack {
                                                    Text("\(randomString(length: 15))")
                                                    
                                                    Spacer()
                                                    
                                                }.font(.system(size: 7, weight: .regular, design: .rounded))
                                                    .padding(.horizontal, 5)
                                            }.frame(height: 10)
                                        }
                                    }
                                }
                                .frame(width: 150, height: 75)
                            }
                            
                        }.frame(width: 300, height: 200)
                            .clipped()
                            .onReceive(timer, perform: { thing in
                                showCommandBar.toggle()
                                typingString = ""
                            })
                            .onReceive(fastTimer, perform: { thing in
                                if typingString.count == 0 {
                                    typingString = "a"
                                }
                                else if typingString.count == 1 {
                                    typingString = "au"
                                }
                                else if typingString.count == 2 {
                                    typingString = "aur"
                                }
                                else if typingString.count == 3 {
                                    typingString = "aura"
                                }
                                else {
                                    typingString = ""
                                }
                            })
                            .cornerRadius(8)
                            .foregroundStyle(Color.black)
#if !os(visionOS) && !os(macOS)
                            .rotation3DEffect(
                                max(min(Angle.radians(motionManager.magnitude * rotationScale), Angle.degrees(maxDegrees)), Angle.degrees(-maxDegrees)),
                                axis: (x: CGFloat(UIDevice.current.orientation == .portrait ? motionManager.x: -motionManager.y), y: CGFloat(UIDevice.current.orientation == .portrait ? -motionManager.y: -motionManager.x), z: 0.0)
                            )
#elseif os(macOS)
                        
#else
                            .hoverEffect(.lift)
#endif
                    }
                    
                    Spacer()
                        .frame(height: 30)
                    
                    
                    HStack {
                        Text("Command Bar on Launch")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $settings.commandBarOnLaunch, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    HStack {
                        Text("Show the command bar each time you open the app.")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    /*HStack {
                        Text("Swipe Between Spaces")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $settings.swipingSpaces, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                            //.disabled(true)
                            //.grayscale(1.0)
                    }.padding(20)
                    
                    HStack {
                        Text("Enables swiping between spaces beta. Only works for expanded sidebars.")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }*/
                    
                    HStack {
                        Text("Background Loading")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                    }.padding(20)
                    
                    HStack {
                        Text(Int(settings.preloadingWebsites).description)
                            .foregroundStyle(Color.white)
                        
                        Slider(value: $settings.preloadingWebsites, in: 1...30, step: 1)
                    }
                    .padding(.horizontal, 10)
                    
                    HStack {
                        Text("Change how many websites stay loaded in the background. Higher numbers mean faster website loading but could lower app performance.")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    Button(action: {
                        settings.shortcuts.resetShortcuts()
                    }, label: {
                        Text("Reset shortcuts")
                    })
                    
                    HStack {
                        Text("Ad Block")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $settings.adBlockEnabled, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    
                    HStack {
                        Text("Enable the built in ad blocker in Aura (beta)")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    
                    HStack {
                        Text("Swipe Navigation Disabled (touch)")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $settings.swipeNavigationDisabled, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    
                    HStack {
                        Text("Disable swipe to navigate forward/backward for the touchscreen. Does not disable it for the trackpad.")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    
                    HStack {
                        Text("Save History (beta)")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $settings.historyEnabled, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    
                    HStack {
                        Text("Disable to prevent saving search history.")
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

#Preview {
    General(settings: SettingsVariables(), startHex: "8A3CEF", endHex: "84F5FE")
}
