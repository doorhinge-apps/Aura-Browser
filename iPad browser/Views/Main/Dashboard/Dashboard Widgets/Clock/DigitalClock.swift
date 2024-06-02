//
//  DigitalClock.swift
//  Aura
//
//  Created by Caedmon Myers on 31/5/24.
//

import SwiftUI

struct DigitalClock: View {
    @Binding var animating: Bool
    @Binding var format: String
    @Binding var monochrome: Bool
    
    @State private var currentTime = Time(hours: 0, minutes: 0, seconds: 0, period: "AM")
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                HStack(spacing: 5) {
                    LazyVGrid(columns: geo.size.width - geo.size.height < 50 ? [GridItem(), GridItem()]: [GridItem(), GridItem(), GridItem(), GridItem()], content: {
                        if format.contains("h") {
                            HStack {
                                if currentTime.hours / 10 != 0 {
                                    TimeDigitView(animating: $animating, number: currentTime.hours / 10)
                                }
                                TimeDigitView(animating: $animating, number: currentTime.hours % 10)
                                Text(":")
                            }.frame(width: geo.size.width/2, height: geo.size.width/2)
                                .foregroundStyle(!monochrome ? Color.green: Color.white)
                                .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 0)
                        }
                        if format.contains("m") {
                            HStack {
                                TimeDigitView(animating: $animating, number: currentTime.minutes / 10)
                                TimeDigitView(animating: $animating, number: currentTime.minutes % 10)
                                Text(":")
                            }.frame(width: geo.size.width/2, height: geo.size.width/2)
                                .foregroundStyle(!monochrome ? Color.blue: Color.white)
                                .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 0)
                        }
                        if format.contains("s") {
                            HStack {
                                TimeDigitView(animating: $animating, number: currentTime.seconds / 10)
                                TimeDigitView(animating: $animating, number: currentTime.seconds % 10)
                            }.frame(width: geo.size.width/2, height: geo.size.width/2)
                                .foregroundStyle(!monochrome ? Color.red: Color.white)
                                .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 0)
                        }
                        if format.contains("a") {
                            HStack {
                                Text(currentTime.period)
                                    .frame(height: 60)
                            }.frame(width: geo.size.width/2, height: geo.size.width/2)
                                .foregroundStyle(!monochrome ? Color.yellow: Color.white)
                                .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 0)
                        }
                    })
                }
                .foregroundStyle(Color.white)
                .font(.system(size: geo.size.height > 150 ? 50: 20, weight: geo.size.height > 150 ?  .black: .bold, design: .rounded))
                //.font(.system(size: 36, weight: .bold, design: .monospaced))
                .onReceive(timer) { _ in
                    let calendar = Calendar.current
                    let now = Date()
                    let hours = calendar.component(.hour, from: now) % 12
                    let minutes = calendar.component(.minute, from: now)
                    let seconds = calendar.component(.second, from: now)
                    let period = calendar.component(.hour, from: now) >= 12 ? "PM" : "AM"
                    
                    withAnimation(.easeInOut(duration: animating ? 0.25: 0.0)) {
                        currentTime = Time(hours: hours == 0 ? 12 : hours, minutes: minutes, seconds: seconds, period: period)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
struct TimeDigitView: View {
    @Binding var animating: Bool
    
    var number: Int
    @State private var previousNumber: Int = -1
    @State private var offset: CGFloat = -40
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            if previousNumber != -1 {
                Text("\(previousNumber)")
                //.font(.system(size: 36, weight: .bold, design: .monospaced))
                    .frame(height: 60)
                    .offset(y: offset)
                    .opacity(opacity)
            }
            
            Text("\(number)")
                //.font(.system(size: 36, weight: .bold, design: .monospaced))
                .frame(height: 60)
                .offset(y: offset == 0 ? 40 : 0)
        }
        .onChange(of: number) { newValue in
            if previousNumber != newValue {
                previousNumber = number
                offset = 0
                opacity = 1.0
                
                withAnimation(.easeInOut(duration: animating ? 0.25: 0.0)) {
                    offset = -40
                    opacity = 0.0
                }
            }
        }
    }
}

struct Time {
    var hours: Int
    var minutes: Int
    var seconds: Int
    var period: String
}

#Preview {
    DigitalClock(animating: .constant(true), format: .constant("hmsa"), monochrome: .constant(false))
}
