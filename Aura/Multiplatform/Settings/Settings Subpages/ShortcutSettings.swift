//
//  ShortcutSettings.swift
//  Aura
//
//  Created by Caedmon Myers on 10/7/24.
//

import SwiftUI

struct ShortcutSettings: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var settings: SettingsVariables
    
    @StateObject var shortcuts = KeyboardShortcuts()
    
    @State var startHex: String
    @State var endHex: String
    
    @State private var selectedFaviconShape: String = "circle"
    
    @State var iconRadius = 0
#if !os(macOS)
    @StateObject var motionManager = MotionManager()
#endif
    private let maxDegrees: Double = 30
    private let rotationScale: Double = 0.5
    
    @State var editingShortcut = false
    
    @FocusState private var editingShortcutFocus: Bool
    
    var body: some View {
        ZStack {
#if !os(visionOS)
            LinearGradient(colors: [Color(hex: startHex), Color(hex: endHex)], startPoint: .bottomLeading, endPoint: .topTrailing).ignoresSafeArea()
#endif
            
            if settings.prefferedColorScheme == "dark" || (settings.prefferedColorScheme == "automatic" && colorScheme == .dark) {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
            }
            
            ScrollView {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.black.opacity(0.5))
                            .frame(width: editingShortcut ? 305: 130, height: 145)
                            .offset(y: 8)
                        
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.black.opacity(0.2), lineWidth: 10)
                            .fill(Color.white)
                            .frame(width: editingShortcut ? 300: 125, height: 125)
                        
                        HStack {
                            Text(shortcuts.newTab.replacingOccurrences(of: ", ", with: "").capitalized)
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                            
                            if editingShortcut {
                                Spacer()
                            }
                        }.frame(width: editingShortcut ? 300: 125, height: 125)
                        
                        TextField("⌘T", text: $shortcuts.newTab)
                            .disabled(!editingShortcut)
                            .focused($editingShortcutFocus)
                        
                    }.onTapGesture(perform: {
                        withAnimation {
                            editingShortcut.toggle()
                        }
                        editingShortcutFocus = true
                    })
                    
                    Spacer()
                        .frame(height: 20)
                    
                }.padding(10)
            }
        }
#if !os(macOS)
        .toolbarBackground(.hidden, for: .navigationBar)
#endif
    }
}


#Preview {
    ShortcutSettings(settings: SettingsVariables(), startHex: "8A3CEF", endHex: "84F5FE")
}
