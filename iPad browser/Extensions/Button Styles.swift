//
//  Button Styles.swift
//  iPad browser
//
//  Created by Caedmon Myers on 11/9/23.
//

import SwiftUI

struct Buttons: View {
    var body: some View {
        ZStack {
            Color(hex: "8880F5")
                .ignoresSafeArea()
            
            
            Button(action: {
                
            }, label: {
                // Leave blank for custom styles
                Text("")
            }).buttonStyle(GrowingButton(buttonText: "Button", buttonWidth: 225, buttonHeight: 30))
        }
    }
}

struct GrowingButton: ButtonStyle {
    @State var buttonText: String
    var buttonWidth: CGFloat
    var buttonHeight: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if configuration.isPressed {
                Color.white.opacity(0.0)
                    .frame(width: 0, height: 0)
                    .onAppear() {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    }
                    .onDisappear() {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
            }
            
            Text(buttonText)
                .bold()
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "8880F5"))
                .frame(width: buttonWidth, height: buttonHeight)
                .offset(y: configuration.isPressed ? 3: 0)
                .padding(.horizontal, 50)
                .padding(.vertical, 15)
                .background(
                    ZStack {
                        if configuration.isPressed {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.white))
                                .modifier(InnerShadow())
                                .offset(y: 2)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(hex: "BEBEBE"))
                                    .offset(y: 2)
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.white))
                                    .modifier(InnerShadow())
                            }
                        }
                    }.shadow(color: Color(hex: "000").opacity(0.15), radius: 15, x: 0, y: 0)
                )
                .foregroundColor(.white)
        }
    }
}

struct MainButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if configuration.isPressed {
                Color.white.opacity(0.0)
                    .frame(width: 0, height: 0)
                    .onAppear() {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    }
                    .onDisappear() {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
            }
            
            configuration.label
                .bold()
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: "8880F5"))
                .offset(y: configuration.isPressed ? 3: 0)
                .padding(.horizontal, 50)
                .padding(.vertical, 15)
                .background(
                    ZStack {
                        if configuration.isPressed {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.white))
                                .modifier(InnerShadow())
                                .offset(y: 2)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(hex: "BEBEBE"))
                                    .offset(y: 2)
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(.white))
                                    .modifier(InnerShadow())
                            }
                        }
                    }.shadow(color: Color(hex: "000").opacity(0.15), radius: 15, x: 0, y: 0)
                )
                .foregroundColor(.white)
        }
    }
}

struct InnerShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(hex: "8880F5"), lineWidth: 6)
                    .blur(radius: 10)
                    .mask(RoundedRectangle(cornerRadius: 15).fill(LinearGradient(gradient: Gradient(colors: [Color.black, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)))
            )
    }
}


struct FastClickButton: ButtonStyle {
    @State var buttonText: String
    var buttonWidth: CGFloat
    var buttonHeight: CGFloat
    
    func makeBody(configuration: Configuration) -> some View {
        Text(buttonText)
            .bold()
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .foregroundStyle(Color(hex: "8880F5"))
            .frame(width: buttonWidth, height: buttonHeight)
            .offset(y: configuration.isPressed ? 3: 0)
            .padding(.horizontal, 50)
            .padding(.vertical, 15)
            .background(
                ZStack {
                    if configuration.isPressed {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.white))
                            .modifier(InnerShadow())
                            .offset(y: 2)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(hex: "BEBEBE"))
                                .offset(y: 2)
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.white))
                                .modifier(InnerShadow())
                        }
                    }
                }.shadow(color: Color(hex: "000").opacity(0.15), radius: 15, x: 0, y: 0)
            )
            .foregroundColor(.white)
    }
}
