//
//  Themes.swift
//  iPad browser
//
//  Created by Caedmon Myers on 19/4/24.
//

import SwiftUI

func saveColor(color: Color, key: String) {
#if !os(macOS)
    let uiColor = UIColor(color)
    #else
    let uiColor = NSColor(color)
    #endif
    let hexString = uiColor.toHex()
    defaults.set(hexString, forKey: key)
}

func getColor(forKey key: String) -> Color? {
    guard let hexString = UserDefaults.standard.string(forKey: key) else {
        return nil
    }
    return Color(hex: hexString)
}
