//
//  Clock.swift
//  Aura
//
//  Created by Caedmon Myers on 31/5/24.
//

import SwiftUI



struct Clock: View {
    @State private var currentTime = Time(hour: 0, minute: 0, second: 0)
    @State private var hourRotation: Double = 0
    @State private var minuteRotation: Double = 0
    @State private var secondRotation: Double = 0
    @State private var initialTime = Date()
    
    struct Time {
        let hour: Int
        let minute: Int
        let second: Int
    }
    
    private func updateCurrentTime() {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let second = calendar.component(.second, from: now)
        self.currentTime = Time(hour: hour, minute: minute, second: second)
        
        // Calculate the initial angles based on the current time
        self.secondRotation = Double(second) * 6
        self.minuteRotation = (Double(minute) + Double(second) / 60.0) * 6
        self.hourRotation = (Double(hour % 12) + Double(minute) / 60.0) * 30
        self.initialTime = now
    }
    
    private func updateRotation() {
        let elapsedTime = Date().timeIntervalSince(initialTime)
        self.secondRotation += elapsedTime * 6.0
        self.minuteRotation += elapsedTime * 0.1
        self.hourRotation += elapsedTime * (1.0 / 120.0)
        self.initialTime = Date()
    }
    
    private var hourAngle: Angle {
        return .degrees(hourRotation)
    }
    
    private var minuteAngle: Angle {
        return .degrees(minuteRotation)
    }
    
    private var secondAngle: Angle {
        return .degrees(secondRotation)
    }
    
    @AppStorage("analogClock") var analogClock = true
    
    @AppStorage("showTickmarks") var showTickmarks = true
    @AppStorage("animateTransitons") var animateTransitons = true
    
    @AppStorage("monochrome") var monochrome = false
    
    @AppStorage("clockFormat") var clockFormat = "hmsa"
    
    @State var showingHours = true
    @State var showingMinutes = true
    @State var showingSeconds = true
    @State var showingPeriod = true
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height)
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let clockRadius = size / 2
                
                if analogClock {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: size * 0.02)
                            .foregroundColor(.white)
                        
                        if showTickmarks {
                            ForEach(0..<60) { tick in
                                TickMark(tick: tick, size: size)
                            }
                        }
                        
                        ForEach(1..<13) { hour in
                            Text("\(hour)")
                                .foregroundStyle(Color.white)
                                .font(.system(size: size * 0.075))
                                .position(x: center.x + cos(CGFloat(hour) * .pi / 6 - .pi / 2) * (clockRadius - size * 0.1),
                                          y: center.y + sin(CGFloat(hour) * .pi / 6 - .pi / 2) * (clockRadius - size * 0.1))
                        }
                        
                        if clockFormat.contains("h") {
                            ClockHand(length: size * 0.25, thickness: size * 0.04, color: monochrome ? .white: .black, angle: hourAngle)
                        }
                        
                        if clockFormat.contains("m") {
                            ClockHand(length: size * 0.35, thickness: size * 0.02, color: monochrome ? .white: .black, angle: minuteAngle)
                        }
                        
                        if clockFormat.contains("s") {
                            ClockHand(length: size * 0.45, thickness: size * 0.01, color: monochrome ? .white: .red, angle: secondAngle)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .onAppear {
                        self.updateCurrentTime()
                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                            withAnimation(.linear(duration: animateTransitons ? 1: 0)) {
                                self.updateRotation()
                            }
                        }
                    }
                }
                
                else {
                    DigitalClock(animating: $animateTransitons, format: $clockFormat, monochrome: $monochrome)
                }
            }.padding(10)
            
            Color.white.opacity(0.001)
                .ignoresSafeArea()
        }
        .onChange(of: showingHours, {
            setFormat()
        })
        .onChange(of: showingMinutes, {
            setFormat()
        })
        .onChange(of: showingSeconds, {
            setFormat()
        })
        .onChange(of: showingPeriod, {
            setFormat()
        })
        .onAppear() {
            setFormatterToggles()
        }
        .contextMenu(ContextMenu(menuItems: {
            Menu {
                Button(action: {
                    analogClock = true
                }, label: {
                    Text("Analog")
                })
                Button(action: {
                    analogClock = false
                }, label: {
                    Text("Digital")
                })
            } label: {
                Text("Display")
            }
            
            Menu {
                Toggle(isOn: $showingHours, label: {
                    Text("Hours")
                })
                
                Toggle(isOn: $showingMinutes, label: {
                    Text("Minutes")
                })
                
                Toggle(isOn: $showingSeconds, label: {
                    Text("Seconds")
                })
                
                if !analogClock {
                    Toggle(isOn: $showingPeriod, label: {
                        Text("AM/PM")
                    })
                }
                
                Button(action: {
                    clockFormat = "hmsa"
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        setFormatterToggles()
                    }
                }, label: {
                    Label("Reset", systemImage: "arrow.clockwise")
                })
            } label: {
                Text("Format")
            }
            
            Toggle(isOn: $animateTransitons, label: {
                Text("Animate Transitions")
            })
            
            Toggle(isOn: $monochrome, label: {
                Text("Monochrome")
            })
            
            if analogClock {
                Toggle(isOn: $showTickmarks, label: {
                    Text("Show Tickmarks")
                })
            }
        }))
    }
    
    func setFormatterToggles() {
        showingHours = true
        showingMinutes = true
        showingSeconds = true
        showingPeriod = true
        
        if !clockFormat.contains("h") {
            showingHours = false
        }
        if !clockFormat.contains("m") {
            showingMinutes = false
        }
        if !clockFormat.contains("s") {
            showingSeconds = false
        }
        if !clockFormat.contains("a") {
            showingPeriod = false
        }
    }
    
    func setFormat() {
        var temporaryFormat = ""
        
        if showingHours {
            temporaryFormat.append("h")
        }
        if showingMinutes {
            temporaryFormat.append("m")
        }
        if showingSeconds {
            temporaryFormat.append("s")
        }
        if showingPeriod {
            temporaryFormat.append("a")
        }
        
        clockFormat = temporaryFormat
    }
}

struct ClockHand: View {
    var length: CGFloat
    var thickness: CGFloat
    var color: Color
    var angle: Angle
    
    var body: some View {
        RoundedRectangle(cornerRadius: thickness / 2)
            .fill(color)
            .frame(width: thickness, height: length)
            .offset(y: -length / 2)
            .rotationEffect(angle)
    }
}

struct TickMark: View {
    var tick: Int
    var size: CGFloat
    
    var body: some View {
        let tickLength: CGFloat = tick % 5 == 0 ? size * 0.05 : size * 0.02
        let tickThickness: CGFloat = tick % 5 == 0 ? size * 0.02 : size * 0.01
        let radius: CGFloat = size / 2
        
        return RoundedRectangle(cornerRadius: 50)
            .fill(Color.white)
            .frame(width: tickThickness, height: tickLength)
            .offset(y: -radius + tickLength / 2)
            .rotationEffect(.degrees(Double(tick) / 60.0 * 360.0))
    }
}




#Preview {
    Clock()
}


#Preview {
    Dashboard(startHexSpace: "631487", endHexSpace: "00aaff")
}
