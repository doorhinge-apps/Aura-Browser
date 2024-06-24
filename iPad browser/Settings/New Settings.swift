//
//  New Settings.swift
//  Aura
//
//  Created by Caedmon Myers on 22/6/24.
//

import SwiftUI

struct NewSettings: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var presentSheet: Bool
    
    @State var startHex: String
    @State var endHex: String
    //https://search.yahoo.com/search;_ylt=awrnoc_g6wnmmakqngbddwvh;_ylc=x1mdmte5nzgwndg2nwrfcgmybgzyawrmcjidcdpzlhy6c2zwlg06c2itdg9wbgdwcmlka1pobkfqtfvsuw4ubu1qb3hzvklir0eebl9yc2x0azaebl9zdwdnazewbg9yawdpbgnzzwfyy2guewfob28uy29tbhbvcwmwbhbxc3ryawrwcxn0cmwdmarxc3rybamybhf1zxj5a2hpbhrfc3rtcamxnze3odizotq0?p=
    //https://search.yahoo.com/search;_ylt=AwrNOC_G6WNmmAkQngBDDWVH;_ylc=X1MDMTE5NzgwNDg2NwRfcgMyBGZyAwRmcjIDcDpzLHY6c2ZwLG06c2ItdG9wBGdwcmlkA1pobkFqTFVSUW4ubU1Qb3hZVklIR0EEbl9yc2x0AzAEbl9zdWdnAzEwBG9yaWdpbgNzZWFyY2gueWFob28uY29tBHBvcwMwBHBxc3RyAwRwcXN0cmwDMARxc3RybAMyBHF1ZXJ5A2hpBHRfc3RtcAMxNzE3ODIzOTQ0?p=
    
    @StateObject var settings = SettingsVariables()
    
    @State var searchEngineOptions = ["Google", "Bing", "DuckDuckGo", "Yahoo!", "Ecosia"]
    @State var searchEngines = ["Google":"https://www.google.com/search?q=", "Bing":"https://www.bing.com/search?q=", "DuckDuckGo":"https://duckduckgo.com/?q=", "Yahoo!":"https://search.yahoo.com/search?q=", "Ecosia": "https://www.ecosia.org/search?q="]
    
    @State private var selectedFaviconShape: String = "circle"
    
    var body: some View {
        GeometryReader { geo in
            NavigationStack {
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
                            
                            NavigationLink(destination: {
                                General(settings: settings, startHex: startHex, endHex: endHex)
                            }, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                    
                                    HStack {
                                        Image("General Icon")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(2)
                                            .background(content: {
                                                ZStack {
                                                    LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                    
                                                    Color.black.opacity(0.3)
                                                        .ignoresSafeArea()
                                                }.cornerRadius(5)
                                            })
                                        
                                        Text("General")
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .padding(.trailing, 10)
                                        
                                    }.foregroundStyle(Color.black)
                                        .padding(10)
                                }.frame(height: 50)
                                    .padding([.leading, .trailing, .bottom], 10)
                            })
                            
                            NavigationLink(destination: {
                                UISettings(settings: settings, startHex: startHex, endHex: endHex)
                            }, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                    
                                    HStack {
                                        Image("Appearance Icon")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(2)
                                            .background(content: {
                                                ZStack {
                                                    LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                    
                                                    Color.black.opacity(0.3)
                                                        .ignoresSafeArea()
                                                }.cornerRadius(5)
                                            })
                                        
                                        Text("Appearance")
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .padding(.trailing, 10)
                                        
                                    }.foregroundStyle(Color.black)
                                        .padding(10)
                                }.frame(height: 50)
                                    .padding([.leading, .trailing, .bottom], 10)
                            })
                            
                            
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
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                    
                                    HStack {
                                        Image("Search Icon")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(2)
                                            .background(content: {
                                                ZStack {
                                                    LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                    
                                                    Color.black.opacity(0.3)
                                                        .ignoresSafeArea()
                                                }.cornerRadius(5)
                                            })
                                        
                                        Text("Search Engine: \(searchEngines.someKey(forValue: settings.searchEngine).unsafelyUnwrapped)")
                                        
                                        Spacer()
                                        
                                    }.foregroundStyle(Color.black)
                                        .padding(10)
                                }.frame(height: 50)
                                    .padding([.leading, .trailing, .bottom], 10)
                            }//.buttonStyle(NewButtonStyle(startHex: startHex, endHex: endHex))
                            
                            
                            NavigationLink(destination: {
                                Favicons(settings: settings, startHex: startHex, endHex: endHex)
                            }, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                    
                                    HStack {
                                        Image("Favicon Icon")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(2)
                                            .background(content: {
                                                ZStack {
                                                    LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                    
                                                    Color.black.opacity(0.3)
                                                        .ignoresSafeArea()
                                                }.cornerRadius(5)
                                            })
                                        
                                        Text("Favicons")
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .padding(.trailing, 10)
                                        
                                    }.foregroundStyle(Color.black)
                                        .padding(10)
                                }.frame(height: 50)
                                    .padding([.leading, .trailing, .bottom], 10)
                            })
                            
                            
                            Button(action: {
                                
                            }, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                    
                                    HStack {
                                        Image("Reset Icon")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(2)
                                            .background(content: {
                                                ZStack {
                                                    LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                                                    
                                                    Color.black.opacity(0.3)
                                                        .ignoresSafeArea()
                                                }.cornerRadius(5)
                                            })
                                        
                                        Text("Reset Onboarding")
                                        
                                        Spacer()
                                        
                                    }.foregroundStyle(Color.black)
                                        .padding(10)
                                }.frame(height: 50)
                                    .padding([.leading, .trailing, .bottom], 10)
                            })
                        }
                    }
                    
                    /*ScrollView {
                     VStack {
                     Spacer()
                     .frame(height: 100)
                     
                     NavigationLink(destination: {
                     Favicons(settings: settings, startHex: startHex, endHex: endHex)
                     }, label: {
                     Label("Favicons", systemImage: "chevron.right")
                     .environment(\.layoutDirection, .rightToLeft)
                     }).buttonStyle(NewButtonStyle(startHex: startHex, endHex: endHex))
                     
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
                     
                     
                     /*HStack {
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
                      }.padding(.bottom, 20)
                      
                      Divider()
                      
                      HStack {
                      Text("Favicon Shape")
                      .font(.system(.title3, design: .rounded, weight: .bold))
                      .foregroundStyle(Color.white)
                      
                      Spacer()
                      }.padding(20)
                      
                      Picker("Favicon Shape", selection: $selectedFaviconShape) {
                      Text("Circle").tag("circle")
                      Text("Squircle").tag("squircle")
                      Text("Square").tag("square")
                      }
                      .pickerStyle(.segmented)
                      .onChange(of: selectedFaviconShape) { newValue in
                      withAnimation {
                      settings.faviconShape = newValue
                      }
                      }
                      .background(Color.white.opacity(0.5).cornerRadius(7))
                      .padding()
                      */
                     
                     
                     //                    Menu {
                     //                        Button(action: {
                     //                            withAnimation {
                     //                                settings.faviconShape = "circle"
                     //                            }
                     //                        }, label: {
                     //                            Label("Circle", systemImage: "circle")
                     //                        })
                     //
                     //                        Button(action: {
                     //                            withAnimation {
                     //                                settings.faviconShape = "squircle"
                     //                            }
                     //                        }, label: {
                     //                            Label("Squircle", systemImage: "app")
                     //                        })
                     //
                     //                        Button(action: {
                     //                            withAnimation {
                     //                                settings.faviconShape = "square"
                     //                            }
                     //                        }, label: {
                     //                            Label("Square", systemImage: "square")
                     //                        })
                     //
                     //                    } label: {
                     //                        Text("Favicon Shape")
                     //                    }.buttonStyle(NewButtonStyle(startHex: startHex, endHex: endHex))
                     
                     
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
                     }*/
                    
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
    }
}

#Preview {
    NewSettings(presentSheet: .constant(true), startHex: "8A3CEF", endHex: "84F5FE")
}
