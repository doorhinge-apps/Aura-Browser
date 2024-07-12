//
//  BoostEditor.swift
//  Aura
//
//  Created by Reyna Myers on 23/6/24.
//

import SwiftUI

struct BoostEditor: View {
    @ObservedObject var boostStore: BoostStore
    
    var body: some View {
        VStack {
            TextField("Enter Website URL", text: $boostStore.boost.webUrl)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextEditor(text: $boostStore.boost.css)
                .border(Color.gray, width: 1)
                .padding()
            
            Button(action: {
                // Save action is handled automatically by @Published property in BoostStore
            }) {
                Text("Save CSS")
            }
            .padding()
        }
        .navigationTitle("Edit CSS")
    }
}
