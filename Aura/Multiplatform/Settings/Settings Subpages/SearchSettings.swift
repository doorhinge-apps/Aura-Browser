//
//  SearchEngine.swift
//  Aura
//
//  Created by Reyna Myers on 10/7/24.
//

import SwiftUI


struct SearchSettings: View {
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
    
    @State var searchEngineOptions = ["Google", "Bing", "DuckDuckGo", "Yahoo!", "Ecosia", "Custom"]
    @State var searchEngines = ["Google":"https://www.google.com/search?q=", "Bing":"https://www.bing.com/search?q=", "DuckDuckGo":"https://duckduckgo.com/?q=", "Yahoo!":"https://search.yahoo.com/search?q=", "Ecosia": "https://www.ecosia.org/search?q="]

    @State var searchEngineIconColors = ["Google":"FFFFFF", "Bing":"B5E3FF", "DuckDuckGo":"DE5833", "Yahoo!":"8A3CEF", "Ecosia": "9AD39E", "Custom":"FFFFFF"]
    
    @State var pickerSearchEngine = ""
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
                        ZStack {
                            Color(hex: searchEngineIconColors[searchEngines.someKey(forValue: settings.searchEngine) ?? "Custom"] ?? "ffffff")

                            Image("\(searchEngines.someKey(forValue: settings.searchEngine) ?? "Custom") Icon")
                                .resizable()
                                .scaledToFit()
                            
                        }.frame(width: 200, height: 200)
                        .cornerRadius(CGFloat(settings.faviconShape == "circle" ? 100: settings.faviconShape == "square" ? 0: 20))
                        .shadow(color: .black.opacity(0.25), radius: 5, x: 0, y: 0)
#if !os(visionOS) && !os(macOS)
                        .rotation3DEffect(
                            max(min(Angle.radians(motionManager.magnitude * rotationScale), Angle.degrees(maxDegrees)), Angle.degrees(-maxDegrees)),
                            axis: (x: CGFloat(UIDevice.current.orientation == .portrait ? motionManager.x: -motionManager.y), y: CGFloat(UIDevice.current.orientation == .portrait ? -motionManager.y: -motionManager.x), z: 0.0)
                        )
#elseif !os(macOS)
                        .hoverEffect(.lift)
                    #endif
                        
                    
                    Spacer()
                        .frame(height: 30)
                    
                    Picker("Search Engine", selection: $pickerSearchEngine) {
                        ForEach(searchEngineOptions, id:\.self) { searchEngineOption in
                            Text(searchEngineOption).tag(searchEngineOption)
                        }
                    }.pickerStyle(.segmented)
                        .onChange(of: pickerSearchEngine, {
                            withAnimation {
                                if let engine = searchEngines[pickerSearchEngine] {
                                    settings.searchEngine = engine
                                }
                            }
                        })
                        .onAppear() {
                            if let key = searchEngines.someKey(forValue: settings.searchEngine) {
                                pickerSearchEngine = key
                            } else {
                                pickerSearchEngine = "Custom"
                            }
                        }
                        .padding([.leading, .trailing, .bottom])

                    HStack {
                        Text("Custom Search Engine")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)

                        Spacer()
                    }.padding(20)

                    TextField("Search Engine URL", text: $settings.searchEngine)
                        .textFieldStyle(.plain)
                        .padding(.leading, 20)
                        .foregroundStyle(Color.white)

                    Divider()
                    
                    
                    HStack {
                        Text("Hide Browse for Me")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $settings.hideBrowseForMe, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    HStack {
                        Text("Hide the browse for me button in menus and the command bar.")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    
                    HStack {
                        Text("Hide Search Emoji")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $settings.hideMagnifyingGlassSearch, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    HStack {
                        Text("Hide the magnifying glass emoji that appears in Google Search tab names for some reason. (this setting will be applied to new tabs now and existing tabs when the app is closed and reopened)")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Custom User Agent")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                    }.padding(20)
                    
                    TextField("User Agent", text: $settings.userAgent)
                        .textFieldStyle(.plain)
                        .padding(.leading, 20)
                        .foregroundStyle(Color.white)
                    
                    HStack {
                        Text("You can edit the user agent of the browser to change how it appears to search engines.")
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
