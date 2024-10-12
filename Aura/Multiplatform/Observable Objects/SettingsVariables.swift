//
//  SettingsVariables.swift
//  Aura
//
//  Created by Reyna Myers on 8/7/24.
//

import SwiftUI
import WebKit
//import WebViewSwiftUI


class SettingsVariables: ObservableObject {
    @StateObject var shortcuts = KeyboardShortcuts()
    
    @AppStorage("email") var email = ""
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = false
    
    @AppStorage("favoritesStyle") var favoritesStyle = false
    
    @AppStorage("faviconLoadingStyle") var faviconLoadingStyle = true
    
    @AppStorage("showBorder") var showBorder = true
    
    @AppStorage("disableSidebarHover") var disableSidebarHover = true
    
    @AppStorage("sidebarLeft") var sidebarLeft = true
    
    @AppStorage("searchEngine") var searchEngine = "https://www.google.com/search?q="
    
    @AppStorage("prefferedColorScheme") var prefferedColorScheme = "automatic"
    
    @AppStorage("swipingSpaces") var swipingSpaces = true
    
    @AppStorage("onboardingDone") var onboardingDone = false
    
    @AppStorage("faviconShape") var faviconShape = "circle"
    
    @AppStorage("forceDarkMode") var forceDarkMode = "advanced"
    @AppStorage("forceDarkModeTime") var forceDarkModeTime = "system"
    
    @AppStorage("commandBarOnLaunch") var commandBarOnLaunch = true
    
    @AppStorage("adBlockEnabled") var adBlockEnabled = true
    
    @AppStorage("swipeNavigationDisabled") var swipeNavigationDisabled = false
    
    @AppStorage("launchAnimation") var launchAnimation = true
    
    @AppStorage("apiKey") var apiKey = ""
    
    @AppStorage("openAPIKey") var openAPIKey = ""
    
    @AppStorage("preloadingWebsites") var preloadingWebsites = 15.0
    
    @AppStorage("hideBrowseForMe") var hideBrowseForMe = false
    
    @AppStorage("historyEnabled") var historyEnabled = false
    
    @AppStorage("hideMagnifyingGlassSearch") var hideMagnifyingGlassSearch = false
    
    @AppStorage("pinnedTabCornerRadius") var favoriteTabCornerRadius = 20.0
    @AppStorage("pinnedTabBorderWidth") var favoriteTabBorderWidth = 2.0
    
    @AppStorage("horizontalTabBar") var horizontalTabBar = false
    
    @AppStorage("shareButtonInTabBar") var shareButtonInTabBar = true
}
