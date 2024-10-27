//
// Aura
// MobileTabsViewModel.swift
//
// Created by Reyna Myers on 26/10/24
//
// Copyright ©2024 DoorHinge Apps.
//


import SwiftUI

class MobileTabsModel: ObservableObject {
    
    @Published var browseForMeTabs = [] as [String]
    
    @Published var tabs: [(id: UUID, url: String)]
    @Published var pinnedTabs: [(id: UUID, url: String)]
    @Published var favoriteTabs: [(id: UUID, url: String)]
    @Published var offsets: [UUID: CGSize] = [:]
    @Published var tilts: [UUID: Double] = [:]
    @Published var zIndexes: [UUID: Double] = [:]
    
    @Published var selectedTab: (id: UUID, url: String)?
    @Published var draggedTab: (id: UUID, url: String)?
    
    @StateObject var settings = SettingsVariables()
    @StateObject var webViewManager = WebViewManager()
    
    @Published var selectedTabsSection: TabLocations = .tabs
    
    @FocusState var newTabFocus: Bool
    @Published var newTabSearch = ""
    
    @Published var fullScreenWebView = false
    
    @Published var suggestions = [] as [String]
    @Published var xmlString = ""
    
    @Published var offsetTest = 0 as CGFloat
    
    @Published var tabOffset = CGSize.zero
    @Published var tabScale: CGFloat = 1.0
    
    @Published var exponentialThing = 1.0
    
    @Published var newTabFromTab = false
    
    @Published var gestureStarted = false
    @Published var closeTabScrollDisabled = false
    @Published var closeTabScrollDisabledCounter = 0
    
    @Published var webURL = ""
    @Published var displayWebURL = ""
    
    init() {
        self._tabs = Published(initialValue: [])
        self._pinnedTabs = Published(initialValue: [])
        self._favoriteTabs = Published(initialValue: [])
    }
}
