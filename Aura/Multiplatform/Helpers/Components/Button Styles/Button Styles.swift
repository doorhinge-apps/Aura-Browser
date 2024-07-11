//
//  Button Styles.swift
//  iPad browser
//
//  Created by Caedmon Myers on 11/9/23.
//

import SwiftUI

struct NewButtonStyle: ButtonStyle {
    @State var startHex: String
    @State var endHex: String
    
    @State var isHovering = false
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if configuration.isPressed {
                Color.white.opacity(0.0)
                    .frame(width: 0, height: 0)
            }
            
            configuration.label
                .bold()
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: averageHexColor(hex1: startHex, hex2: endHex)))
                .offset(y: configuration.isPressed ? 3: 0)
                .offset(y: isHovering ? 1: 0)
                .padding(.horizontal, 50)
                .padding(.vertical, 15)
                .background(
                    ZStack {
                        if configuration.isPressed {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.white))
                                .modifier(InnerShadow())
                                .offset(y: 2)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(hex: "BEBEBE"))
                                    .offset(y: 2)
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.white))
                                    //.offset(y: isHovering ? 0: 0)
                                    .opacity(isHovering ? 0.8: 1.0)
                                    .modifier(InnerShadow())
                            }
                        }
                    }.shadow(color: Color(hex: "000").opacity(0.15), radius: 15, x: 0, y: 0)
                )
#if !os(visionOS) && !os(macOS)
                .onChange(of: configuration.isPressed, {
                    if configuration.isPressed {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    }
                    else {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                })
            #endif
                .onHover(perform: { hovering in
                    isHovering = hovering
                })
                .foregroundColor(.white)
        }
    }
}
