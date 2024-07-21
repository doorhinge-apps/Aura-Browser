//
//  ObservableVariables.swift
//  Aura
//
//  Created by Reyna Myers on 8/7/24.
//

import SwiftUI
import WebKit
//import WebViewSwiftUI


class ObservableVariables: ObservableObject {
    @AppStorage("prefferedColorScheme") var prefferedColorScheme = "automatic"
    
    // Webview handling
    @ObservedObject var navigationState = NavigationState()
    @ObservedObject var pinnedNavigationState = NavigationState()
    @ObservedObject var favoritesNavigationState = NavigationState()
    
    @StateObject var settings = SettingsVariables()
    
    @StateObject var history = HistoryObservable()
    
    @Published var navigationStateArray = [] as [NavigationState]
    @Published var pinnedNavigationStateArray = [] as [NavigationState]
    @Published var favoritesNavigationStateArray = [] as [NavigationState]
    
    // Storage and Website Loading
    @AppStorage("currentSpace") var currentSpace = "Untitled"
    //@Published var spaces = ["Home", "Space 2"]
    @Published var spaceIcons: [String: String]? = [:]
    
    @Published var reloadTitles = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let rotationTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    // Settings and Sheets
    @Published var hoverTab = WKWebView()
    
    @Published var showSettings = false
    @Published var changeColorSheet = false
    
    @Published var startColor: Color = Color.purple
    @Published var endColor: Color = Color.pink
    @Published var textColor: Color = Color.white
    
    @AppStorage("startColorHex") var startHex = "8A3CEF"
    @AppStorage("endColorHex") var endHex = "84F5FE"
    @AppStorage("textColorHex") var textHex = "ffffff"
    
    @AppStorage("swipingSpaces") var swipingSpaces = true
    
    @Published var presentIcons = false
    
    // Hover Effects
    @Published var hoverTinySpace = false
    @Published var hoverSidebarButton = false
    @Published var hoverPaintbrush = false
    @Published var hoverReloadButton = false
    @Published var hoverForwardButton = false
    @Published var hoverBackwardButton = false
    @Published var hoverNewTab = false
    @Published var settingsButtonHover = false
    @Published var hoverNewTabSection = false
    
    @Published var hoverSpaceIndex = 1000
    @Published var hoverSpace = ""
    
    @Published var hoverSidebarSearchField = false
    
    @Published var hoverCloseTab = WKWebView()
    
    @Published var spaceIconHover = false
    
    // Animations and Gestures
    @Published var reloadRotation = 0
    @Published var draggedTab: WKWebView?
    
    // Selection States
    @Published var tabBarShown = false
    @Published var commandBarShown = false
    
    @Published var changingIcon = ""
    //@Published var hideSidebar = false
    @AppStorage("hideSidebar") var hideSidebar = false
    
    @Published var searchInSidebar = ""
    @Published var newTabSearch = ""
    @Published var newTabSaveSearch = ""
    
    @Published var currentTabNum = 0
    
    @Published var selectedIndex: Int? = 0
    
    @FocusState var focusedField: FocusedField?
    
    @AppStorage("selectedSpaceIndex") var selectedSpaceIndex = 0
    //@Published var selectedSpaceIndex = 0
    
    @Published var loadingAnimationToggle = false
    @Published var offset = 0.0
    @Published var loadingRotation = 0
    
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = true
    @AppStorage("favoritesStyle") var favoritesStyle = false
    @AppStorage("faviconLoadingStyle") var faviconLoadingStyle = false
    
    @AppStorage("sidebarLeft") var sidebarLeft = true
    
    @AppStorage("showBorder") var showBorder = true
    
    @Published var inspectCode = ""
    
    enum FocusedField {
        case commandBar, tabBar, none
    }
    @Published var selectedTabLocation = "tabs"
    
    // Other Stuff
//#if !os(visionOS)
//    @Published var screenWidth = UIScreen.main.bounds.width
//    #endif
    
    @Published var hoveringSidebar = false
    @Published var tapSidebarShown = false
    
    @Published var commandBarCollapseHeightAnimation = false
    @Published var commandBarSearchSubmitted = false
    @Published var commandBarSearchSubmitted2 = false
    
    @Published var auraTab = ""
    
    @Published var initialLoadDone = false
    
    @Published var scrollLimiter = false
    
    @Published var scrollPosition: CGPoint = .zero
    @Published var horizontalScrollPosition: CGPoint = .zero
    
    @Published var isBrowseForMe = false
    @Published var delayedBrowseForMe = false
    
    @Published var browseForMeSearch = ""
    
    @Published var navigationOffset: CGFloat = 0
    @Published var navigationArrowColor = false
    @Published var arrowImpactOnce = false
    
    @Published var boostEditor = false
    
    @StateObject var shortcuts = KeyboardShortcuts()
    @StateObject var boosts = BoostDataStorage()
    
    @Published var forwardArrowPulse = false
    @Published var backArrowPulse = false
}
