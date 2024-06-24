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
                                settings.email = ""
                                settings.onboardingDone = false
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
