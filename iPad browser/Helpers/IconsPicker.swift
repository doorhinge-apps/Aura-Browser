//
//  IconsPicker.swift
//  iPad browser
//
//  Created by Caedmon Myers on 17/4/24.
//

import SwiftUI
import SwiftData


struct IconsPicker: View {
    @Environment(\.modelContext) var modelContext
    @Query var spaces: [SpaceStorage]
    @Binding var currentIcon: String
    
    @State var currentHoverIcon = ""
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem(), GridItem(), GridItem(), GridItem(), GridItem(), GridItem(), GridItem(), GridItem(), GridItem()]) {
                ForEach(sfIconOptions, id:\.self) { icon in
                    Button {
                        currentIcon = icon
                        print("Icon: \(icon)")
                        print("Current Icon: \(currentIcon)")
                    } label: {
                        ZStack {
                            Color(.white)
                                .opacity(currentIcon == icon ? 1.0: currentHoverIcon == icon ? 0.5: 0.0)
                            
                            Image(systemName: icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(currentIcon == icon ? Color.black: Color.white)
                                .opacity(currentHoverIcon == icon ? 1.0: 0.7)
                            
                        }.frame(width: 40, height: 40).cornerRadius(7)
                            .hoverEffect(.lift)
                            .onHover(perform: { hovering in
                                if hovering {
                                    currentHoverIcon = icon
                                }
                                else {
                                    currentHoverIcon = ""
                                }
                            })
                    }
                    
                }
            }
        }.scrollIndicators(.hidden)
    }
}

