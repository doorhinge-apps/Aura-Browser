//
//  PlusButtonStyle.swift
//  Aura
//
//  Created by Caedmon Myers on 29/6/24.
//

import SwiftUI

struct PlusButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 100, height: 50)
            .background(
                ZStack {
                    Capsule()
                        //.fill(Color.white)
                        .fill(
                            .white.gradient.shadow(.inner(color: .black.opacity(configuration.isPressed ? 0.2: 0.0), radius: 10, x: 4, y: 3))
                        )
                        .animation(.default, value: configuration.isPressed)
                    
//                    Capsule()
//                        .stroke(Color(hex: "4D4D4D"), lineWidth: 1)
//                        .opacity(0.4)
                    
                }
            )
            .foregroundColor(Color(hex: "4D4D4D"))
            .font(.system(.headline, design: .rounded, weight: .bold))
            .shadow(color: .black.opacity(configuration.isPressed ? 0.2 : 0), radius: 8, x: 0, y: 0)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}
