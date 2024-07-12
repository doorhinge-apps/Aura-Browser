//
//  Hex.swift
//  Testing Weather App
//
//  Created by Reyna Myers on 5/10/23.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


extension Color {
    static func foregroundColor(forHex hex: String) -> Color {
        guard hex.count >= 6 else { return Color.white }

        let rString = hex.prefix(2)
        let gString = hex.dropFirst(2).prefix(2)
        let bString = hex.dropFirst(4).prefix(2)

        let r = Double(Int(rString, radix: 16) ?? 0) / 255.0
        let g = Double(Int(gString, radix: 16) ?? 0) / 255.0
        let b = Double(Int(bString, radix: 16) ?? 0) / 255.0

        let gammaCorrectedR = r <= 0.04045 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4)
        let gammaCorrectedG = g <= 0.04045 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4)
        let gammaCorrectedB = b <= 0.04045 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4)

        let luminance = 0.2126 * gammaCorrectedR + 0.7152 * gammaCorrectedG + 0.0722 * gammaCorrectedB

        return luminance > 0.5 ? Color.black : Color.white
    }
}
