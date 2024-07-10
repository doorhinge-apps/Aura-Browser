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
    
    @AppStorage("startColorHex") var startHex = "ffffff"
    @AppStorage("endColorHex") var endHex = "000000"
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if configuration.isPressed {
                Color.white.opacity(0.0)
                    .frame(width: 0, height: 0)
#if !os(visionOS) && !os(macOS)
                    .onAppear() {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    }
                    .onDisappear() {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
#endif
            }
            
            Text(buttonText)
                .bold()
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: averageHexColor(hex1: startHex, hex2: endHex) ?? "8880F5"))
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


#if !os(macOS)
extension UIColor {
    convenience init?(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
    
    var hexString: String {
        let components = cgColor.components!
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
#else
extension NSColor {
    convenience init?(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
    
    var hexString: String {
        let components = cgColor.components!
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
#endif


func averageHexColor(hex1: String, hex2: String) -> String {
    // Convert hex strings to UIColor
#if !os(macOS)
    guard let color1 = UIColor(hexString: hex1), let color2 = UIColor(hexString: hex2) else {
        return "Invalid Hex Values"
    }
    #else
    guard let color1 = NSColor(hexString: hex1), let color2 = NSColor(hexString: hex2) else {
        return "Invalid Hex Values"
    }
    #endif
    
    // Get the RGB components of both colors
    var red1: CGFloat = 0, green1: CGFloat = 0, blue1: CGFloat = 0, alpha1: CGFloat = 0
    var red2: CGFloat = 0, green2: CGFloat = 0, blue2: CGFloat = 0, alpha2: CGFloat = 0
    
    color1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
    color2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
    
    // Calculate the average RGB components
    let averageRed = (red1 + red2) / 2
    let averageGreen = (green1 + green2) / 2
    let averageBlue = (blue1 + blue2) / 2
    
    // Create a new UIColor with the average RGB components
#if !os(macOS)
    let averageColor = UIColor(red: averageRed, green: averageGreen, blue: averageBlue, alpha: 1.0)
    #else
    let averageColor = NSColor(red: averageRed, green: averageGreen, blue: averageBlue, alpha: 1.0)
    #endif
    
    // Convert the average UIColor to hex string
    return averageColor.hexString
}


struct MainButtonStyle: ButtonStyle {
    @AppStorage("startColorHex") var startHex = "ffffff"
    @AppStorage("endColorHex") var endHex = "000000"
    
    @State var isHovering = false
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if configuration.isPressed {
                Color.white.opacity(0.0)
                    .frame(width: 0, height: 0)
#if !os(visionOS) && !os(macOS)
                    .onAppear() {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    }
                    .onDisappear() {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                #endif
            }
            
            configuration.label
                .bold()
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: averageHexColor(hex1: startHex, hex2: endHex) ?? "8880F5"))
                .offset(y: configuration.isPressed ? 3: 0)
                .offset(y: isHovering ? 1: 0)
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
                                    .offset(y: isHovering ? 1: 0)
                                    .opacity(isHovering ? 0.8: 1.0)
                                    .modifier(InnerShadow())
                            }
                        }
                    }.shadow(color: Color(hex: "000").opacity(0.15), radius: 15, x: 0, y: 0)
                )
                .onHover(perform: { hovering in
                    isHovering = hovering
                })
                .foregroundColor(.white)
        }
    }
}


struct NewButtonStyle: ButtonStyle {
    //@AppStorage("startColorHex") var startHex = "ffffff"
    //@AppStorage("endColorHex") var endHex = "000000"
    
    @State var startHex: String
    @State var endHex: String
    
    @State var isHovering = false
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if configuration.isPressed {
                Color.white.opacity(0.0)
                    .frame(width: 0, height: 0)
            }
            
            configuration.label
                .bold()
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: averageHexColor(hex1: startHex, hex2: endHex) ?? "8880F5"))
                .offset(y: configuration.isPressed ? 3: 0)
                .offset(y: isHovering ? 1: 0)
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
                                    //.offset(y: isHovering ? 0: 0)
                                    .opacity(isHovering ? 0.8: 1.0)
                                    .modifier(InnerShadow())
                            }
                        }
                    }.shadow(color: Color(hex: "000").opacity(0.15), radius: 15, x: 0, y: 0)
                )
#if !os(visionOS) && !os(macOS)
                .onChange(of: configuration.isPressed, {
                    if configuration.isPressed {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    }
                    else {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                })
            #endif
                .onHover(perform: { hovering in
                    isHovering = hovering
                })
                .foregroundColor(.white)
        }
    }
}


struct InnerShadow: ViewModifier {
    @AppStorage("startColorHex") var startHex = "ffffff"
    @AppStorage("endColorHex") var endHex = "000000"
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(hex: averageHexColor(hex1: startHex, hex2: endHex)), lineWidth: 6)
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
