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
    @AppStorage("startColorHex") var startHex = "ffffff"
    @AppStorage("endColorHex") var endHex = "000000"
    @AppStorage("email") var email = ""
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = false
    
    @AppStorage("searchEngine") var searchEngine = "https://www.google.com/search?q="
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
            
            VStack {
                Menu {
                    Button(action: {
                        searchEngine = "https://www.google.com/search?q="
                    }, label: {
                        Text("Google")
                    })
                    
                    Button(action: {
                        searchEngine = "https://www.bing.com/search?q="
                    }, label: {
                        Text("Bing")
                    })
                } label: {
                    Text("Search Engine: \(searchEngine)")
                }
                
                Toggle(isOn: $hoverEffectsAbsorbCursor) {
                    Text("Hover Effects Absorb Cursor")
                        .foregroundStyle(Color.white)
                    
                }.tint(Color(hex: startHex))
                    .padding(20)

                
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
        }
    }
}

#Preview {
    Settings()
}
