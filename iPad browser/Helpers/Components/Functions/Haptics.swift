//
//  Haptics.swift
//  Aura
//
//  Created by Caedmon Myers on 27/6/24.
//

import SwiftUI
#if canImport(AppKit)
import AppKit
#endif


func heavyHaptics() {
#if !os(visionOS) && !os(macOS)
    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
#endif
}


func softHaptics() {
#if !os(visionOS) && !os(macOS)
    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    #elseif os(macOS)
    NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .now)
#endif
}
