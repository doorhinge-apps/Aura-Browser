//
//  Settings.swift
//  iPad browser
//
//  Created by Caedmon Myers on 13/4/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct Settings: View {
    @Binding var presentSheet: Bool
    
    @AppStorage("startColorHex") var startHex = "ffffff"
    @AppStorage("endColorHex") var endHex = "000000"
    @AppStorage("email") var email = ""
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = true
    @AppStorage("favoritesStyle") var favoritesStyle = true
    @AppStorage("faviconLoadingStyle") var faviconLoadingStyle = true
    
    @AppStorage("searchEngine") var searchEngine = "https://www.google.com/search?q="
    
    @State var searchEngineOptions = ["Google", "Bing", "DuckDuckGo", "Yahoo!", "Ecosia"]
    @State var searchEngines = ["Google":"https://www.google.com/search?q=", "Bing":"https://www.bing.com/search?q=", "DuckDuckGo":"https://duckduckgo.com/?t=h_&q=", "Yahoo!":"https://search.yahoo.com/search?p=", "Ecosia": "https://www.ecosia.org/search?method=index&q=hello"]
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
            
            VStack {
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
                }.buttonStyle(MainButtonStyle())
                
                
                Toggle(isOn: $hoverEffectsAbsorbCursor) {
                    Text("Hover Effects Absorb Cursor")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.white)
                    
                }.tint(Color(hex: averageHexColor(hex1: startHex, hex2: endHex) ?? "8880F5"))
                    .padding(20)
                
                Toggle(isOn: $favoritesStyle) {
                    Text("Favorites Show Website Names")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.white)
                    
                }.tint(Color(hex: averageHexColor(hex1: startHex, hex2: endHex) ?? "8880F5"))
                    .padding(20)
                
                Toggle(isOn: $faviconLoadingStyle) {
                    Text("Load Favicons with SDWebImage")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.white)
                    
                }.tint(Color(hex: averageHexColor(hex1: startHex, hex2: endHex) ?? "8880F5"))
                    .padding(20)
                
                Text("This allows for caching images more efficiently.")
                    .foregroundStyle(Color.white)
                
                Spacer()
                    .frame(height: 75)
                
                Button {
                    email = ""
                    do {
                        try Auth.auth().signOut()
                    } catch let signOutError as NSError {
                        print("Error signing out: %@", signOutError)
                    }
                } label: {
                    Text("Sign Out")
                }.buttonStyle(GrowingButton(buttonText: "Sign Out", buttonWidth: 150, buttonHeight: 20))

            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        presentSheet = false
                    } label: {
                        //
                    }.buttonStyle(GrowingButton(buttonText: "Done", buttonWidth: 75, buttonHeight: 20))
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
