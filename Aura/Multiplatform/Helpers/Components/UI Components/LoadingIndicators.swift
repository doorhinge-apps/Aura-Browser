//
//  LoadingIndicators.swift
//  Aura
//
//  Created by Reyna Myers on 27/6/24.
//

import SwiftUI

struct LoadingIndicators: View {
    @Binding var offset: CGFloat
    let isLoading: Bool?
    let startColor: Color
    
    @State private var rotationTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Group {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .trim(from: 0.25 + offset, to: 0.5 + offset)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .foregroundColor(startColor)
                .opacity(isLoading ?? false ? 1.0 : 0.0)
                .animation(.default, value: isLoading ?? false)
                .blur(radius: 5)
            
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .trim(from: 0.25 + offset, to: 0.5 + offset)
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotation(Angle(degrees: 180))
                .foregroundColor(startColor)
                .opacity(isLoading ?? false ? 1.0 : 0.0)
                .animation(.default, value: isLoading ?? false)
                .blur(radius: 5)
                .onReceive(rotationTimer) { _ in
                    handleRotation()
                }
        }
    }
    
    private func handleRotation() {
        if offset == 0.5 {
            offset = 0.0
            withAnimation(.linear(duration: 1.5)) {
                offset = 0.5
            }
        } else {
            withAnimation(.linear(duration: 1.5)) {
                offset = 0.5
            }
        }
    }
}
