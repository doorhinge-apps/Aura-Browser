//
//  ScrollViewOffset.swift
//  Aura
//
//  Created by Caedmon Myers on 24/5/24.
//

import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}
