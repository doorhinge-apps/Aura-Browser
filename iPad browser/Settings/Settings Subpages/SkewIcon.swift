//
//  SkewIcon.swift
//  Aura
//
//  Created by Caedmon Myers on 23/6/24.
//

import SwiftUI

struct SkewIcon: View {
    
    @ObservedObject var motionManager = MotionManager()
    private let maxDegrees: Double = 30
    private let rotationScale: Double = 0.5
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .padding()
                    .foregroundColor(.blue)
                    .frame(width: 300, height: 600)
                    .rotation3DEffect(
                        max(min(Angle.radians(motionManager.magnitude * rotationScale), Angle.degrees(maxDegrees)), Angle.degrees(-maxDegrees))
                        ,
                        axis: (x: CGFloat(motionManager.x), y: CGFloat(motionManager.y), z: 0.0)
                    )
                    .shadow(radius: 10)
            }
        }
    }
}


#Preview {
    SkewIcon()
}
