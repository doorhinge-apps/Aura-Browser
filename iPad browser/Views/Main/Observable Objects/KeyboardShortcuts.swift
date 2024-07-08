//
//  KeyboardShortcuts.swift
//  Aura
//
//  Created by Caedmon Myers on 8/7/24.
//

import SwiftUI


class KeyboardShortcuts: ObservableObject {
    @AppStorage("toggleSidebar - Shortcut") var toggleSidebar = "⌘, s"
    @AppStorage("newTab - Shortcut") var newTab = "⌘, t"
    @AppStorage("commandBar - Shortcut") var commandBar = "⌘, l"
    @AppStorage("goBack - Shortcut") var goBack = "⌘, ["
    @AppStorage("goForward - Shortcut") var goForward = "⌘, ]"
    @AppStorage("reload - Shortcut") var reload = "⌘, r"
    @AppStorage("copyUrl - Shortcut") var copyUrl = "⌘, ⇧, c"
    
    
    func parseShortcut(shortcut: String) -> KeyboardShortcut {
        var array: [String] = []
        
        array = shortcut.components(separatedBy: ", ")
        
        var modifiers = EventModifiers()
        
        var regularKey = ""
        
        for key in array {
            if key == "⌘" {
                modifiers.insert(.command)
            }
            else if key == "⌥" {
                modifiers.insert(.option)
            }
            else if key == "⌃" {
                modifiers.insert(.control)
            }
            else if key == "⇧" {
                modifiers.insert(.shift)
            }
            else {
                regularKey = key
            }
            
        }
        
        let keyEquivalentCharacter = KeyEquivalent(Character(regularKey))
        
        return KeyboardShortcut(keyEquivalentCharacter, modifiers: modifiers)
    }
}

