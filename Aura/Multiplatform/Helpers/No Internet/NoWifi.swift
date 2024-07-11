//
//  NoWifi.swift
//  Aura
//
//  Created by Caedmon Myers on 10/7/24.
//

import SwiftUI

struct NoWifi: View {
    @State var playGame = false
    
    @Binding var ignore: Bool
    var body: some View {
        ZStack {
            onboardingBackground
            
            VStack {
                Image(systemName: "wifi.slash")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .foregroundStyle(Color.white)
                
                Text("Uh oh, looks like you don’t have wifi")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                
                Text("(that’s kind of important for a web browser)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                
                Text("Anyway, you can play the tile game or try again later")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                
                ZStack {
                    Color.white
                        .cornerRadius(10)
                    
                    TileGame()
                        .cornerRadius(5)
                        .scaleEffect(1.85)
                        
                }.frame(width: 300, height: 300)
                
                Button(action: {
                    ignore = true
                }, label: {
                    Text("or Continue Anyway")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .underline(true, color: Color.white)
                        .foregroundStyle(Color.white)
                })
                
            }
        }
    }
    
    @State var circleOffsets = [[-0.7, -0.7], [0.0, 0.6], [0.8, 0.4]]
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    var onboardingBackground: some View {
        GeometryReader { geo in
            ZStack {
                Color(hex: "8880F5")
                    .ignoresSafeArea()
                
                Circle()
                    .fill(Color(hex: "84F5FE"))
                    .frame(height: 400)
                    .blur(radius: 100)
                    .opacity(0.7)
                    .offset(x: geo.size.width / 2 * circleOffsets[0][0], y: geo.size.height / 2 * circleOffsets[0][1])
                
                Circle()
                    .fill(Color(hex: "953EF6"))
                    .frame(height: 400)
                    .blur(radius: 100)
                    .opacity(0.5)
                    .offset(x: geo.size.width / 2 * circleOffsets[1][0], y: geo.size.height / 2 * circleOffsets[1][1])
                
                Circle()
                    .fill(Color(hex: "84F5FE"))
                    .frame(height: 400)
                    .blur(radius: 100)
                    .opacity(0.7)
                    .offset(x: geo.size.width / 2 * circleOffsets[2][0], y: geo.size.height / 2 * circleOffsets[2][1])
                
            }.onReceive(timer, perform: { _ in
                for circle in 0..<circleOffsets.count {
                    let randomValue = Double.random(in: -100...100)
                    let randomValue2 = Double.random(in: -100...100)
                    
                    withAnimation(.easeInOut(duration: 4.9), {
                        circleOffsets[circle][0] = randomValue / 100
                        circleOffsets[circle][1] = randomValue2 / 100
                    })
                }
            })
        }
    }
}
