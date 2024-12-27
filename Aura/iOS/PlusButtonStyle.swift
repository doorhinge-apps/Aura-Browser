//
//  PlusButtonStyle.swift
//  Aura
//
//  Created by Reyna Myers on 29/6/24.
//

import SwiftUI

struct PlusButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 100, height: 50)
            .background(
                ZStack {
                    Capsule()
                        .fill(
                            .white.gradient.shadow(.inner(color: .black.opacity(configuration.isPressed ? 0.2: 0.0), radius: 10, x: 4, y: 3))
                        )
                        .animation(.default, value: configuration.isPressed)
                    
                }
            )
            .foregroundColor(Color(hex: "4D4D4D"))
            .font(.system(.headline, design: .rounded, weight: .bold))
            .shadow(color: .black.opacity(configuration.isPressed ? 0.2 : 0), radius: 8, x: 0, y: 0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
            
    }
}


struct ShadowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                ZStack {
                    Capsule()
                        .fill(
                            .white.gradient.shadow(.inner(color: .black.opacity(configuration.isPressed ? 0.2: 0.0), radius: 10, x: 4, y: 3))
                        )
                        .animation(.default, value: configuration.isPressed)
                }
            )
            .foregroundColor(Color(hex: "4D4D4D"))
            .font(.system(.headline, design: .rounded, weight: .bold))
            .shadow(color: .black.opacity(configuration.isPressed ? 0.2 : 0), radius: 8, x: 0, y: 0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}


struct BrowseForMeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            ZStack {
                Capsule()
                    .fill(
                        .white.gradient.shadow(.inner(color: .black.opacity(configuration.isPressed ? 0.2: 0.0), radius: 10, x: 4, y: 3))
                    )
                    .shadow(color: .black.opacity(configuration.isPressed ? 0.2 : 0), radius: 8, x: 0, y: 0)
                    .animation(.default)
            }
            
            HStack {
                Spacer()
                
                Text("Browse for Me")
                    .animation(.default)
                    .foregroundStyle(LinearGradient(colors: [Color(hex: "EA96FF"), Color(hex: "7E7DD5"), Color(hex: "5957E5")], startPoint: .leading, endPoint: .trailing))
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .padding(.horizontal, 2)
                
                Spacer()
            }
            
        }.frame(width: 140, height: 30)
            .padding(.trailing, 10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}
