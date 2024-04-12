//
//  iPad_browserApp.swift
//  iPad browser
//
//  Created by Caedmon Myers on 8/9/23.
//

import SwiftUI
import Firebase

@main
struct iPad_browserApp: App {
    
    //@StateObject var dataManager = DataManager()
    @State var newTabSearch = ""
    
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            //ContentView()
            LoginView()
            
//            VStack {
//                TextField(text: $newTabSearch) {
//                    Label("Search or Enter URL...", systemImage: "magnifyingglass")
//                }
//                .textInputAutocapitalization(.never)
//                
//                SuggestionsView(newTabSearch: $newTabSearch, suggestionUrls: suggestionUrls)
//            }
        }
    }
}
