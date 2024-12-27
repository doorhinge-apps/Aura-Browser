//
// Aura
// ToolbarButtonStyle.swift
//
// Created by Reyna Myers on 26/10/24
//
// Copyright ©2024 DoorHinge Apps.
//


import SwiftUI

struct ToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 40, height: 40)
            .background(
                ZStack {
                    Circle()
                        .fill(.regularMaterial)
                        .stroke(Color(hex: "4D4D4D"), lineWidth: 1)
                        .animation(.default, value: configuration.isPressed)
                    
                }
            )
            .foregroundColor(Color(hex: "4D4D4D"))
            .font(.system(.body, design: .rounded, weight: .bold))
            .shadow(color: .black.opacity(configuration.isPressed ? 0.2 : 0), radius: 8, x: 0, y: 0)
            .scaleEffect(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
#if !os(visionOS) && !os(macOS)
            .onChange(of: configuration.isPressed, {
                if configuration.isPressed {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                else {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                }
            })
#endif
    }
}
