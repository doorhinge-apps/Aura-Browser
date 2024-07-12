//
//  LoadingAnimations.swift
//  Aura
//
//  Created by Reyna Myers on 25/4/24.
//

import SwiftUI

struct LoadingAnimations: View {
    @State var size: Int
    @State var borderWidth: Double
    
    @State private var degree:Int = 270
    @State private var spinnerLength = 0.9
    var body: some View {
            Circle()
                .trim(from: 0.0,to: spinnerLength)
                .stroke(LinearGradient(colors: [.white,.white.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing),style: StrokeStyle(lineWidth: borderWidth,lineCap: .round,lineJoin:.round))
                
                .animation(Animation.easeIn(duration: 1.5).repeatForever(autoreverses: true), value: spinnerLength)
                .rotationEffect(Angle(degrees: Double(degree)))
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: degree)
                .frame(width: CGFloat(size), height: CGFloat(size))
                .onAppear{
                    degree = 270 + 360
                    spinnerLength = 0
                }
    }
}
