//
//  InnerShadow.swift
//  Aura
//
//  Created by Reyna Myers on 10/7/24.
//

import SwiftUI

struct InnerShadow: ViewModifier {
    @AppStorage("startColorHex") var startHex = "ffffff"
    @AppStorage("endColorHex") var endHex = "000000"
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(hex: averageHexColor(hex1: startHex, hex2: endHex)), lineWidth: 6)
                    .blur(radius: 10)
                    .mask(RoundedRectangle(cornerRadius: 15).fill(LinearGradient(gradient: Gradient(colors: [Color.black, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)))
            )
    }
}
