//
//  LoginView.swift
//  iPad browser
//
//  Created by Reyna Myers on 9/9/23.
//

import SwiftUI
import Network


struct OnboardingView: View {
    @State private var startColor: Color = Color.purple
    @State private var endColor: Color = Color.pink
    
    @State private var networkMonitor = NetworkMonitor()
    
    @State var email = ""
    @State var password = ""
    
    @State var resetPassword = false
    @State var resetEmail = ""
    @State var resetSent = false
    @State var invalidError = false
    
    @AppStorage("email") var appIsLoggedIn: String = ""
    @AppStorage("onboardingDone") var onboardingDone = false
    @State var onboardingComplete = false
    
    @State var incorrectPassword = false
    
    @State var onboarding = 1
    
    @FocusState var focusedShortcuts: Bool
    
    @State var ignoreNoWifi = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if networkMonitor.isConnected {
                    ContentView()
                }
                else {
                    NoWifi(ignore: $ignoreNoWifi)
                }
                    //SwiftUITabBar()
//                        .environmentObject(variables)
                
                //if !onboardingDone && !onboardingComplete {
                if !onboardingDone {
                    HStack(spacing: 0) {
                        page1
                            .frame(width: geo.size.width, height: geo.size.height)
                        
                        page2
                            .frame(width: geo.size.width)
                    }.focusable()
                        .focused($focusedShortcuts)
                        .onAppear() {
                            focusedShortcuts = true
                        }
                        //.focusEffectDisabled(true)
                        .onKeyPress(.rightArrow) {
                            if onboarding == 1 {
                                withAnimation {
                                    onboarding = 2
                                }
                            }
                            else {
                                if onboardingIndex >= 6 {
                                    onboardingComplete = true
                                    withAnimation(.linear(duration: 0)) {
                                        onboardingDone = true
                                    }
                                }
                                else {
                                    withAnimation {
                                        onboardingIndex += 1
                                    }
                                }
                            }
                            return .handled
                        }
                        .onKeyPress(.return) {
                            if onboarding == 1 {
                                withAnimation {
                                    onboarding = 2
                                }
                            }
                            else {
                                if onboardingIndex >= 6 {
                                    onboardingComplete = true
                                    withAnimation(.linear(duration: 0)) {
                                        onboardingDone = true
                                    }
                                }
                                else {
                                    withAnimation {
                                        onboardingIndex += 1
                                    }
                                }
                            }
                            return .handled
                        }
                        .onKeyPress(.leftArrow) {
                            withAnimation {
                                if onboardingIndex > 0 {
                                    onboardingIndex -= 1
                                }
                                else {
                                    onboarding = 1
                                }
                            }
                            
                            return .handled
                        }
                        .offset(x: onboarding == 1 ? 0: -geo.size.width)
                }
                
            }
        }
    }
    
    var page1: some View {
        ZStack {
            onboardingBackground
            
            VStack(spacing: 20) {
                Text("Hello!")
                    .foregroundColor(Color(.white))
                    .font(.system(size: 100, weight: .bold, design: .rounded))
                    .shadow(color: Color(hex: "fff").opacity(0.75), radius: 7, x: 0, y: 0)
                
                
                SizedSpacer(height: 20)
                
                
                Text("Let's get you set up")
                    .foregroundColor(Color(.white))
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                    .shadow(color: Color(hex: "fff").opacity(0.75), radius: 7, x: 0, y: 0)
                
                
                SizedSpacer(height: 100)
                
                Text("It looks like you're on mobile. Onboarding isn't ready for mobile yet. You can proceed anyway or skip.")
                    .foregroundColor(Color(.white))
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .shadow(color: Color(hex: "fff").opacity(0.75), radius: 7, x: 0, y: 0)
                
                
                HStack {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        Button {
                            withAnimation(.linear(duration: 0)) {
                                onboardingDone = true
                            }
                            
                            onboardingComplete = true
                        } label: {
                            ZStack {
                                Text("Skip")
                            }
                        }.buttonStyle(NewButtonStyle(startHex: "8A3CEF", endHex: "84F5FE"))
                    }
                    
                    Button {
                        withAnimation {
                            onboarding = 2
                        }
                    } label: {
                        ZStack {
                            Text("Continue")
                        }
                    }.buttonStyle(NewButtonStyle(startHex: "8A3CEF", endHex: "84F5FE"))
                }
#if !os(macOS)
                    .hoverEffect(.lift)
                #endif
                
            }
        }
    }
    
    @State var onboardingInfo = [
        OnboardingInfo(index: 0, title: "Meet Aura", description: "Aura is a new browser built for iPad first with additional support for iOS, macOS, and visionOS. The design is based on Arc browser.", rectangle1Size: [0, 0], rectangle2Size: [0, 0], rectangle3Size: [0, 554], rectangleOutlineSize: [780, 554]),
        OnboardingInfo(index: 1, title: "Meet Aura - Sidebar", description: "Aura organizes tabs into a sidebar which can be either on the left or right. There are three types of tabs: favorite, pinned, and today tabs.", rectangle1Size: [126, 0], rectangle2Size: [126, 0], rectangle3Size: [582, 554], rectangleOutlineSize: [217, 554]),
        OnboardingInfo(index: 2, title: "Meet Aura - Favorite Tabs", description: "Favorite tabs are shown at the top of the sidebar under the url bar. These tabs are displayed in capsules as either the website icon or name.", rectangle1Size: [126, 80], rectangle2Size: [126, 400], rectangle3Size: [674, 554], rectangleOutlineSize: [126, 74]),
        OnboardingInfo(index: 3, title: "Meet Aura - Pinned Tabs", description: "Pinned tabs are beneath favorite tabs. They show the website icon and name.", rectangle1Size: [217, 145], rectangle2Size: [217, 325], rectangle3Size: [582, 554], rectangleOutlineSize: [217, 84]),
        OnboardingInfo(index: 4, title: "Meet Aura - Today Tabs", description: "Today tabs are at the bottom and are where new tabs are created. We will be adding support to automatically close these tabs after a set amount of time.", rectangle1Size: [217, 264], rectangle2Size: [217, 195], rectangle3Size: [582, 554], rectangleOutlineSize: [217, 95]),
        OnboardingInfo(index: 5, title: "Meet Aura - Spaces", description: "Spaces scroll horizontally at the bottom. You can switch between spaces by tapping on the space you want to use or swiping in the sidebar. \n \nSpaces can be added with the plus icon. The name, icon, and theme can be customized for each space.", rectangle1Size: [217, 504], rectangle2Size: [217, 10], rectangle3Size: [582, 554], rectangleOutlineSize: [217, 40]),
        OnboardingInfo(index: 6, title: "Meet Aura - Feedback", description: "Thanks for trying out our browser. If you have any feedback, we’d love to hear it. Email us at support@doorhingeapps.com. Click the button below to get started using the browser.", rectangle1Size: [0, 0], rectangle2Size: [0, 0], rectangle3Size: [0, 0], rectangleOutlineSize: [0, 0])
    ]
    
    @State var rectangle1Size = [0, 0] as [CGFloat]
    @State var rectangle2Size = [0, 0] as [CGFloat]
    @State var rectangle3Size = [0, 0] as [CGFloat]
    @State var rectangleOutlineSize = [780, 540] as [CGFloat]
    
    @State var onboardingIndex = 0
    var page2: some View {
        GeometryReader { geo in
            ZStack {
                onboardingBackground
                
                VStack {
                    Text(onboardingInfo[onboardingIndex].title)
                        .foregroundColor(Color(.white))
                        .font(.system(size: 55, weight: .bold, design: .rounded))
                        .shadow(color: Color(hex: "fff").opacity(0.75), radius: 7, x: 0, y: 0)
                    
                    GeometryReader { geo2 in
                        ZStack {
                            Image("Aura")
                                .resizable()
                                .scaledToFit()
                            
                            HStack(alignment: .center, spacing: 0) {
                                VStack(alignment: .center, spacing: 0) {
                                    Rectangle()
                                        .fill(Color.black.opacity(0.5))
                                        .frame(width: rectangle1Size[0], height: rectangle1Size[1])
                                        .zIndex(0)
                                    
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white, lineWidth: 3)
                                        .frame(width: rectangleOutlineSize[0], height: rectangleOutlineSize[1])
                                        .zIndex(2)
                                    
                                    Rectangle()
                                        .fill(Color.black.opacity(0.5))
                                        .frame(width: rectangle2Size[0], height: rectangle2Size[1])
                                        .zIndex(0)
                                }.zIndex(1)
                                
                                Rectangle()
                                    .fill(Color.black.opacity(0.5))
                                    .frame(width: rectangle3Size[0], height: rectangle3Size[1])
                                    .zIndex(0)
                            }
                        }.cornerRadius(15)
                    }
                    .frame(maxWidth: geo.size.width, maxHeight: geo.size.height-400)
                    .aspectRatio(1, contentMode: .fit)
                    
                    //Spacer()
                    //    .frame(height: 100)
                    
                    Text(onboardingInfo[onboardingIndex].description)
                        .foregroundColor(Color(.white))
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .shadow(color: Color(hex: "fff").opacity(0.75), radius: 7, x: 0, y: 0)
                        .frame(maxWidth: geo.size.width / 1.2 + 50)
                        .frame(height: geo.size.width > 450 ? 100: .infinity)
                    
                    Button {
                            if onboardingIndex >= 6 {
                                withAnimation(.linear(duration: 0)) {
                                    onboardingDone = true
                                }
                                
                                onboardingComplete = true
                                
                                onboardingIndex += 1
                            }
                            else {
                                withAnimation {
                                    onboardingIndex += 1
                                }
                            }
                    } label: {
                        ZStack {
                            if onboardingIndex >= 6 {
                                Text("Get Started")
                            }
                            else {
                                Text("Continue")
                            }
                        }
                    }.buttonStyle(NewButtonStyle(startHex: "8A3CEF", endHex: "84F5FE"))
#if !os(macOS)
                        .hoverEffect(.lift)
                    #endif
                }.onChange(of: onboardingIndex) {
                    withAnimation(.default, {
                        rectangle1Size = [((geo.size.height-400)/554)*onboardingInfo[onboardingIndex].rectangle1Size[0], (geo.size.height-400)/554*onboardingInfo[onboardingIndex].rectangle1Size[1]]
                        rectangle2Size = [((geo.size.height-400)/554)*onboardingInfo[onboardingIndex].rectangle2Size[0], (geo.size.height-400)/554*onboardingInfo[onboardingIndex].rectangle2Size[1]]
                        rectangle3Size = [((geo.size.height-400)/554)*onboardingInfo[onboardingIndex].rectangle3Size[0], (geo.size.height-400)/554*onboardingInfo[onboardingIndex].rectangle3Size[1]]
                        rectangleOutlineSize = [((geo.size.height-400)/554)*onboardingInfo[onboardingIndex].rectangleOutlineSize[0], (geo.size.height-400)/554*onboardingInfo[onboardingIndex].rectangleOutlineSize[1]]
                    })
                }
                .onAppear() {
                    rectangle1Size = [((geo.size.height-400)/554)*onboardingInfo[onboardingIndex].rectangle1Size[0], (geo.size.height-400)/554*onboardingInfo[onboardingIndex].rectangle1Size[1]]
                    rectangle2Size = [((geo.size.height-400)/554)*onboardingInfo[onboardingIndex].rectangle2Size[0], (geo.size.height-400)/554*onboardingInfo[onboardingIndex].rectangle2Size[1]]
                    rectangle3Size = [((geo.size.height-400)/554)*onboardingInfo[onboardingIndex].rectangle3Size[0], (geo.size.height-400)/554*onboardingInfo[onboardingIndex].rectangle3Size[1]]
                    rectangleOutlineSize = [((geo.size.height-400)/554)*onboardingInfo[onboardingIndex].rectangleOutlineSize[0], (geo.size.height-400)/554*onboardingInfo[onboardingIndex].rectangleOutlineSize[1]]
                }
                
                VStack {
                    HStack {
                        Button {
                            withAnimation {
                                if onboardingIndex > 0 {
                                    onboardingIndex -= 1
                                }
                                else {
                                    onboarding = 1
                                }
                            }
                        } label: {
                            ZStack {
                                Label("Back", systemImage: "chevron.left")
                            }
                        }.buttonStyle(NewButtonStyle(startHex: "8A3CEF", endHex: "84F5FE"))
#if !os(macOS)
                            .hoverEffect(.lift)
                        #endif
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.linear(duration: 0)) {
                                onboardingDone = true
                            }
                            
                            onboardingComplete = true
                        } label: {
                            ZStack {
                                Text("Skip")
                            }
                        }.buttonStyle(NewButtonStyle(startHex: "8A3CEF", endHex: "84F5FE"))
#if !os(macOS)
                            .hoverEffect(.lift)
                        #endif
                    }.padding(.horizontal, 30)
                    
                    Spacer()
                }
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
    
#if !os(macOS)
    func saveColor(color: Color, key: String) {
        let uiColor = UIColor(color)
        let hexString = uiColor.toHex()
        defaults.set(hexString, forKey: key)
    }
    #else
    func saveColor(color: Color, key: String) {
        let uiColor = NSColor(color)
        let hexString = uiColor.toHex()
        defaults.set(hexString, forKey: key)
    }
#endif
    
    func getColor(forKey key: String) -> Color? {
        guard let hexString = UserDefaults.standard.string(forKey: key) else {
            return nil
        }
        return Color(hex: hexString)
    }
    
}




extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}


struct OnboardingInfo {
    let index: Int
    let title: String
    let description: String
    let rectangle1Size: [CGFloat]
    let rectangle2Size: [CGFloat]
    let rectangle3Size: [CGFloat]
    let rectangleOutlineSize: [CGFloat]
}


#Preview(body: {
    OnboardingView()
})

