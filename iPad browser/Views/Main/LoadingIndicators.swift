//
//  LoadingIndicators.swift
//  Aura
//
//  Created by Caedmon Myers on 27/6/24.
//

import SwiftUI

func loadingIndicators(for isLoading: Bool?) -> some View {
    Group {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .trim(from: 0.25 + variables.offset, to: 0.5 + variables.offset)
            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
            .foregroundColor(selectedSpaceIndex < spaces.count ? Color(hex: spaces[selectedSpaceIndex].startHex) : .blue)
            .opacity(isLoading ?? false ? 1.0 : 0.0)
            .animation(.default, value: isLoading ?? false)
            .blur(radius: 5)
        
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .trim(from: 0.25 + variables.offset, to: 0.5 + variables.offset)
            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
            .rotation(Angle(degrees: 180))
            .foregroundColor(selectedSpaceIndex < spaces.count ? Color(hex: spaces[selectedSpaceIndex].startHex) : .blue)
            .opacity(isLoading ?? false ? 1.0 : 0.0)
            .animation(.default, value: isLoading ?? false)
            .blur(radius: 5)
            .onReceive(rotationTimer) { _ in
                handleRotation()
            }
    }
}
