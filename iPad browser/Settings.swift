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
    
    //@AppStorage("startColorHex") var startHex = "ffffff"
    //@AppStorage("endColorHex") var endHex = "000000"
    @State var startHex: String
    @State var endHex: String
    @AppStorage("email") var email = ""
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = false
    @AppStorage("favoritesStyle") var favoritesStyle = false
    @AppStorage("faviconLoadingStyle") var faviconLoadingStyle = true
    
    @AppStorage("showBorder") var showBorder = true
    
    @AppStorage("disableSidebarHover") var disableSidebarHover = true
    
    @AppStorage("sidebarLeft") var sidebarLeft = true
    
    @AppStorage("searchEngine") var searchEngine = "https://www.google.com/search?q="
    
    @AppStorage("prefferedColorScheme") var prefferedColorScheme = "automatic"
    
    //@AppStorage("launchDashboard") var launchDashboard = false
    
    @State var searchEngineOptions = ["Google", "Bing", "DuckDuckGo", "Yahoo!", "Ecosia"]
    @State var searchEngines = ["Google":"https://www.google.com/search?q=", "Bing":"https://www.bing.com/search?q=", "DuckDuckGo":"https://duckduckgo.com/?t=h_&q=", "Yahoo!":"https://search.yahoo.com/search?p=", "Ecosia": "https://www.ecosia.org/search?method=index&q=hello"]
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
            
            if prefferedColorScheme == "dark" || (prefferedColorScheme == "automatic" && colorScheme == .dark) {
                Color.black.opacity(0.5)
            }
            
            ScrollView {
                VStack {
                    Spacer()
                        .frame(height: 100)
                    
                    Menu {
                        ForEach(searchEngineOptions, id:\.self) { option in
                            Button(action: {
                                withAnimation {
                                    searchEngine = searchEngines[option] ?? "https://www.google.com/search?q="
                                }
                            }, label: {
                                Text(option)
                            })
                        }
                        
                    } label: {
                        Text("Search Engine: \(searchEngines.someKey(forValue: searchEngine).unsafelyUnwrapped)")
                    }.buttonStyle(NewButtonStyle(startHex: startHex, endHex: endHex))
                    
                    HStack {
                        Text("Hover Effects Absorb Cursor")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $hoverEffectsAbsorbCursor, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    
                    HStack {
                        Text("Favorites Show Website Names")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $favoritesStyle, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    
                    HStack {
                        Text("Load Favicons with SDWebImage")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $faviconLoadingStyle, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    HStack {
                        Text("This allows for caching images more efficiently.")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("Show Border")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        
                        CustomToggleSlider(toggle: $showBorder, startHex: startHex, endHex: endHex)
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
                        
                        CustomToggleSlider(toggle: $sidebarLeft, startHex: startHex, endHex: endHex)
                            .scaleEffect(0.75)
                    }.padding(20)
                    
                    
                    HStack {
                        Text("Switch between left and right sidebar location")
                            .foregroundStyle(Color.white)
                            .padding(.leading, 20)
                        
                        Spacer()
                    }
                    
                    Menu {
                        Button(action: {
                            prefferedColorScheme = "automatic"
                        }, label: {
                            Text("Automatic")
                        })
                        
                        Button(action: {
                            prefferedColorScheme = "light"
                        }, label: {
                            Text("Light")
                        })
                        
                        Button(action: {
                            prefferedColorScheme = "dark"
                        }, label: {
                            Text("Dark")
                        })
                        
                    } label: {
                        Text("Appearance: \(prefferedColorScheme.capitalized)")
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
                        email = ""
                    } label: {
                        Text("Sign Out")
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
