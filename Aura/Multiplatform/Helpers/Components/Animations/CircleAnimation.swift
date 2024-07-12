//
//  CircleAnimation.swift
//  iPad browser
//
//  Created by Reyna Myers on 15/4/24.
//

import SwiftUI

struct CircleAnimation: View {
    @State var keyframe1 = false
    @State var keyframe2 = false
    @State var rotation = 0
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "8A3CEF"), Color(hex: "84F5FE")], startPoint: .bottomLeading, endPoint: .topTrailing)
                .ignoresSafeArea()
            
            if #available(iOS 17.0, *) {
                Circle()
                    .trim(from: 0.0, to: keyframe2 ? 0.0: 1.0)
                    .fill(LinearGradient(colors: [Color(hex: "84F5FE"), Color(hex: "8A3CEF")], startPoint: .bottomLeading, endPoint: .topTrailing))
                    .stroke(Color.white, lineWidth: 20)
                    .frame(width: keyframe1 ? 300: 0)
                    .blur(radius: 20)
                    .rotationEffect(Angle(degrees: Double(rotation)))
            } else {
                // Fallback on earlier versions
            }
        }
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    keyframe1 = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation(.easeIn(duration: 1.25)) {
                    togglingKeyframes()
                }
            }
        }
    }
    
    func togglingKeyframes() {
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            withAnimation(.easeIn(duration: 1.25)) {
                keyframe2 = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            withAnimation(.bouncy(duration: 1.25)) {
                rotation += 450
                keyframe2 = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeIn(duration: 1.25)) {
                togglingKeyframes()
            }
        }
    }
}

#Preview {
    CircleAnimation()
}
