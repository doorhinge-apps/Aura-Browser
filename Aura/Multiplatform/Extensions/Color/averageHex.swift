//
//  averageHex.swift
//  Aura
//
//  Created by Reyna Myers on 10/7/24.
//

import SwiftUI

func averageHexColor(hex1: String, hex2: String) -> String {
    // Convert hex strings to UIColor
#if !os(macOS)
    guard let color1 = UIColor(hexString: hex1), let color2 = UIColor(hexString: hex2) else {
        return "Invalid Hex Values"
    }
    #else
    guard let color1 = NSColor(hexString: hex1), let color2 = NSColor(hexString: hex2) else {
        return "Invalid Hex Values"
    }
    #endif
    
    // Get the RGB components of both colors
    var red1: CGFloat = 0, green1: CGFloat = 0, blue1: CGFloat = 0, alpha1: CGFloat = 0
    var red2: CGFloat = 0, green2: CGFloat = 0, blue2: CGFloat = 0, alpha2: CGFloat = 0
    
    color1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
    color2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
    
    // Calculate the average RGB components
    let averageRed = (red1 + red2) / 2
    let averageGreen = (green1 + green2) / 2
    let averageBlue = (blue1 + blue2) / 2
    
    // Create a new UIColor with the average RGB components
#if !os(macOS)
    let averageColor = UIColor(red: averageRed, green: averageGreen, blue: averageBlue, alpha: 1.0)
    #else
    let averageColor = NSColor(red: averageRed, green: averageGreen, blue: averageBlue, alpha: 1.0)
    #endif
    
    // Convert the average UIColor to hex string
    return averageColor.hexString
}
