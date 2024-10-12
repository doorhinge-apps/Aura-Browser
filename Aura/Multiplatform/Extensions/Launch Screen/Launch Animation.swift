//
//  Launch Animation.swift
//  Aura
//
//  Created by Reyna Myers on 24/6/24.
//

import SwiftUI

let launchCircleSizeFactor = 0.5859375


struct Launch_Animation: View {
    @State var startHex = "8A3CEF"
    @State var endHex = "84F5FE"
    
    @State var keyframe = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var circleStrokeScale = 1.0
    @State var circleFillScale = 1.0
    @State var circleFillOpacity = 1.0
    @State var circleFillRotation = 0.0
    
    @State var allOpacity = 1.0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
                
                Image("Rectangle 2")
                    .resizable()
                    .scaledToFill()
                    .opacity(1.0)
                
                ZStack {
                    Image("Aura Middle")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(circleFillScale)
                        .opacity(circleFillOpacity)
                        .rotationEffect(Angle(degrees: circleFillRotation))
                    
                    Image("Aura Front")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(circleStrokeScale)
                    
                }.frame(width: geo.size.width - 200, height: geo.size.height - 200)
                    .blur(radius: 25)
                
            }
            .opacity(allOpacity)
            .ignoresSafeArea()
            .frame(width: geo.size.width, height: geo.size.height)
            .onAppear() {
                let durationFactor = 2.0
                
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    withAnimation(.bouncy(duration: 1 * durationFactor, extraBounce: 0.2)) {
                        circleFillScale = 2
                        circleFillRotation = -180
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1 * durationFactor) {
                            withAnimation(.linear(duration: 1 * durationFactor)) {
                                circleFillOpacity = 0.0
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 * durationFactor) {
                            withAnimation(.bouncy(duration: 0.5 * durationFactor, extraBounce: 0.4)) {
                                circleStrokeScale = 1.2
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25 * durationFactor) {
                                withAnimation(.linear(duration: 1 * durationFactor)) {
                                    circleStrokeScale = 5
                                    allOpacity = 0
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    Launch_Animation(startHex: "8A3CEF", endHex: "84F5FE")
}
