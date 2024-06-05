//
//  Settings.swift
//  iPad browser
//
//  Created by Caedmon Myers on 13/4/24.
//

import SwiftUI


struct Settings: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var presentSheet: Bool
    
    @State var startHex: String
    @State var endHex: String
    
    @StateObject var settings = SettingsVariables()
    
    @State var searchEngineOptions = ["Google", "Bing", "DuckDuckGo", "Yahoo!", "Ecosia"]
    @State var searchEngines = ["Google":"https://www.google.com/search?q=", "Bing":"https://www.bing.com/search?q=", "DuckDuckGo":"https://duckduckgo.com/?t=h_&q=", "Yahoo!":"https://search.yahoo.com/search?p=", "Ecosia": "https://www.ecosia.org/search?method=index&q=hello"]
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
            
            if settings.prefferedColorScheme == "dark" || (settings.prefferedColorScheme == "automatic" && colorScheme == .dark) {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
            }
            
            ScrollView {
                VStack {
                    Spacer()
                        .frame(height: 100)
                    
                    Menu {
                        ForEach(searchEngineOptions, id:\.self) { option in
                            Button(action: {
                                withAnimation {
                                    settings.searchEngine = searchEngines[option] ?? "https://www.google.com/search?q="
                                }
                            }, label: {
                                Text(option)
                            })
                        }
                        
                    } label: {
                        Text("Search Engine: \(searchEngines.someKey(forValue: settings.searchEngine).unsafelyUnwrapped)")
                    }.buttonStyle(NewButtonStyle(startHex: startHex, endHex: endHex))
                    
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        HStack {
                            Text("Hover Effects Absorb Cursor")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.white)
                            
                            Spacer()
                            
                            CustomToggleSlider(toggle: $settings.hoverEffectsAbsorbCursor, startHex: startHex, endHex: endHex)
                                .scaleEffect(0.75)
                        }.padding(20)
                    }
                    
                    
                    HStack {
                        Text("Favorites Show Website Names")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $settings.favoritesStyle, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    
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
                    
                    
                    Menu {
                        Button(action: {
                            withAnimation {
                                settings.faviconShape = "circle"
                            }
                        }, label: {
                            Label("Circle", systemImage: "circle")
                        })
                        
                        Button(action: {
                            withAnimation {
                                settings.faviconShape = "squircle"
                            }
                        }, label: {
                            Label("Squircle", systemImage: "app")
                        })
                        
                        Button(action: {
                            withAnimation {
                                settings.faviconShape = "square"
                            }
                        }, label: {
                            Label("Square", systemImage: "square")
                        })
                        
                    } label: {
                        Text("Favicon Shape")
                    }.buttonStyle(NewButtonStyle(startHex: startHex, endHex: endHex))
                    
                    
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
                    
                    
                    HStack {
                        Text("Swipe Between Spaces")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $settings.swipingSpaces, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                            .disabled(true)
                            .grayscale(1.0)
                    }.padding(20)
                    
                    HStack {
                        Text("Enables swiping between spaces beta. Cannot be disabled currently. Only works for expanded sidebars for now.")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    Menu {
                        Button(action: {
                            settings.prefferedColorScheme = "automatic"
                        }, label: {
                            Text("Automatic")
                        })
                        
                        Button(action: {
                            settings.prefferedColorScheme = "light"
                        }, label: {
                            Text("Light")
                        })
                        
                        Button(action: {
                            settings.prefferedColorScheme = "dark"
                        }, label: {
                            Text("Dark")
                        })
                        
                    } label: {
                        Text("Appearance: \(settings.prefferedColorScheme.capitalized)")
                    }.buttonStyle(NewButtonStyle(startHex: startHex, endHex: endHex))
                    
                    /*
                    HStack {
                        Text("Launch Dashboard Beta")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $launchDashboard, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)*/
                    
                    Spacer()
                        .frame(height: 75)
                    
                    Button {
                        settings.email = ""
                        settings.onboardingDone = false
                    } label: {
                        Text("Reset Onboarding")
                    }.buttonStyle(NewButtonStyle(startHex: startHex, endHex: endHex))
                    
                    
                    Spacer()
                        .frame(height: 50)
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        presentSheet = false
                    } label: {
                        Text("Done")
                    }.buttonStyle(NewButtonStyle(startHex: startHex, endHex: endHex))
                        .padding(15)
                    
                }
                
                Spacer()
            }
        }
    }
}

extension Dictionary where Value: Equatable {
    func someKey(forValue val: Value) -> Key? {
        return first(where: { $1 == val })?.key
    }
}
