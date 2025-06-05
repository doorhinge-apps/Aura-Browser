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
    
    @AppStorage("jsInjectionDelay") var jsInjectionDelay = 3.0
    
    @AppStorage("jsInjectionDelayBoosts") var jsInjectionDelayBoosts = 3.0
    
    @AppStorage("horizontalTabBar") var horizontalTabBar = false
    
    @AppStorage("shareButtonInTabBar") var shareButtonInTabBar = true
    
    @AppStorage("previewOnHover") var previewOnHover = true
    
    @AppStorage("gridColumnCount") var gridColumnCount = 2.0
    
    @AppStorage("userAgent") var userAgent = "Mozilla/5.0 (iPad; CPU OS 18_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/136.0.7103.91 Mobile/15E148 Safari/604.1"
}
