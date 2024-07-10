//
//  CustomSlider.swift
//  Aura
//
//  Created by Caedmon Myers on 11/5/24.
//

import SwiftUI

struct CustomToggleSlider: View {
    @Binding var toggle: Bool
    
    @State var hoveringToggle = false
    
    @State var startHex: String
    @State var endHex: String
    
    var body: some View {
        ZStack {
            Color(hex: toggle ? averageHexColor(hex1: startHex, hex2: endHex): "B8B8B8")
                .frame(width: 75, height: 50)
                .cornerRadius(100)
                .overlay {
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color.white, lineWidth: 2)
                }
            
            HStack {
                Color.white
                    .frame(width: hoveringToggle ? 50: 40, height: 40)
                    .cornerRadius(100)
                    .offset(x: (toggle ? 12.5: -12.5) + (hoveringToggle ? 5: 0) * (toggle ? -1: 1))
                    //.hoverEffect(.lift)
                
            }
        }
        .animation(.default)
        .onTapGesture {
            withAnimation {
                withAnimation {
                    toggle.toggle()
                }
                #if os(visionOS) || os(macOS)
                
                #else
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                #endif
            }
        }.onHover(perform: { hovering in
            if hovering {
                withAnimation {
                    hoveringToggle = true
                }
            }
            else {
                withAnimation {
                    hoveringToggle = false
                }
            }
        })
    }
}
