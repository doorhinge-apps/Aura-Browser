//
//  ObservableObjects.swift
//  Aura
//
//  Created by Caedmon Myers on 3/6/24.
//

import SwiftUI
import WebKit

class ObservableVariables: ObservableObject {
    @AppStorage("prefferedColorScheme") var prefferedColorScheme = "automatic"
    
    // Webview handling
    @ObservedObject var navigationState = NavigationState()
    @ObservedObject var pinnedNavigationState = NavigationState()
    @ObservedObject var favoritesNavigationState = NavigationState()
    
    @StateObject var settings = SettingsVariables()
    
    @State var navigationStateArray = [] as [NavigationState]
    @State var pinnedNavigationStateArray = [] as [NavigationState]
    @State var favoritesNavigationStateArray = [] as [NavigationState]
    
    // Storage and Website Loading
    @AppStorage("currentSpace") var currentSpace = "Untitled"
    //@State var spaces = ["Home", "Space 2"]
    @State var spaceIcons: [String: String]? = [:]
    
    @State var reloadTitles = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let rotationTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    // Settings and Sheets
    @State var hoverTab = WKWebView()
    
    @State var showSettings = false
    @State var changeColorSheet = false
    
    @State var startColor: Color = Color.purple
    @State var endColor: Color = Color.pink
    @State var textColor: Color = Color.white
    
    @AppStorage("startColorHex") var startHex = "8A3CEF"
    @AppStorage("endColorHex") var endHex = "84F5FE"
    @AppStorage("textColorHex") var textHex = "ffffff"
    
    @AppStorage("swipingSpaces") var swipingSpaces = true
    
    @State var presentIcons = false
    
    // Hover Effects
    @State var hoverTinySpace = false
    @State var hoverSidebarButton = false
    @State var hoverPaintbrush = false
    @State var hoverReloadButton = false
    @State var hoverForwardButton = false
    @State var hoverBackwardButton = false
    @State var hoverNewTab = false
    @State var settingsButtonHover = false
    @State var hoverNewTabSection = false
    
    @State var hoverSpaceIndex = 1000
    @State var hoverSpace = ""
    
    @State var hoverSidebarSearchField = false
    
    @State var hoverCloseTab = WKWebView()
    
    @State var spaceIconHover = false
    
    // Animations and Gestures
    @State var reloadRotation = 0
    @State var draggedTab: WKWebView?
    
    // Selection States
    @State var tabBarShown = false
    @State var commandBarShown = false
    
    @State var changingIcon = ""
    //@State var hideSidebar = false
    @AppStorage("hideSidebar") var hideSidebar = false
    
    @State var searchInSidebar = ""
    @State var newTabSearch = ""
    @State var newTabSaveSearch = ""
    
    @State var currentTabNum = 0
    
    @State var selectedIndex: Int? = 0
    
    @FocusState var focusedField: FocusedField?
    
    @AppStorage("selectedSpaceIndex") var selectedSpaceIndex = 0
    //@State var selectedSpaceIndex = 0
    
    @State var loadingAnimationToggle = false
    @State var offset = 0.0
    @State var loadingRotation = 0
    
    
    @AppStorage("hoverEffectsAbsorbCursor") var hoverEffectsAbsorbCursor = true
    @AppStorage("favoritesStyle") var favoritesStyle = false
    @AppStorage("faviconLoadingStyle") var faviconLoadingStyle = false
    
    @AppStorage("sidebarLeft") var sidebarLeft = true
    
    @AppStorage("showBorder") var showBorder = true
    
    @State var inspectCode = ""
    
    enum FocusedField {
        case commandBar, tabBar, none
    }
    @State var selectedTabLocation = "tabs"
    
    // Other Stuff
    @State var screenWidth = UIScreen.main.bounds.width
    
    @State var hoveringSidebar = false
    @State var tapSidebarShown = false
    
    @State var commandBarCollapseHeightAnimation = false
    @State var commandBarSearchSubmitted = false
    @State var commandBarSearchSubmitted2 = false
    
    @State var auraTab = ""
    
    @State var initialLoadDone = false
    
    @State var scrollLimiter = false
    
    @State var scrollPosition: CGPoint = .zero
    @State var horizontalScrollPosition: CGPoint = .zero
    
}


class SidebarTabStorageUpdate: ObservableObject {
    
}


class SettingsVariables: ObservableObject {
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
    
    @AppStorage("commandBarOnLaunch") var commandBarOnLaunch = true
    
    @AppStorage("adBlockEnabled") var adBlockEnabled = true
}
