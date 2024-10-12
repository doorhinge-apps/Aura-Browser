//
// Aura
// SidebarObservable.swift
//
// Created by Reyna Myers on 12/10/24
//
// Copyright ©2024 DoorHinge Apps.
//


import SwiftUI
import WebKit


class SidebarObservable: ObservableObject {
    @Published var temporaryRenamingString = ""
    @Published var isRenaming = false
    
    // Storage and Website Loading
    @AppStorage("currentSpace") var currentSpace = "Untitled"
    
    @Published var spaceIcons: [String: String]? = [:]
    
    @Published var reloadTitles = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Settings and Sheets
    @Published var hoverTab = WKWebView()
    
    @Published var changeColorSheet = false
    
    @Published var presentIcons = false
    
    // Hover Effects
    @Published var hoverSidebarSearchField = false
    
    @Published var hoverCloseTab = WKWebView()
    
    @Published var spaceIconHover = false
    
    @Published var settingsButtonHover = false
    @Published var hoverNewTabSection = false
    
    @Published var temporaryRenameSpace = ""
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = true
    @AppStorage("favoritesStyle") var favoritesStyle = false
    @AppStorage("faviconLoadingStyle") var faviconLoadingStyle = false
    
    @AppStorage("faviconShape") var faviconShape = "circle"
    
    @AppStorage("selectedSpaceIndex") var selectedSpaceIndex = 0
    
    @Published var hoverPaintbrush = false
    
    @FocusState var renameIsFocused: Bool
    
    // Selection States
    @Published var changingIcon = ""
    @Published var draggedTab: WKWebView?
    
    @Published var textRect = CGRect()
    
    @Published var draggedItem: String?
    @Published var draggedItemIndex: Int?
    @Published var currentHoverIndex: Int?
    @Published var reorderingTabs: [String] = []
    
    @Published var pdfData: Data? = nil
    
    @Published var isShowingShareSheet = false
    
    @Published var activityController: UIActivityViewController!
}
