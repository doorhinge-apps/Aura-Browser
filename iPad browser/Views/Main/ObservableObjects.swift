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
    
    @State var navigationStateArray = [] as [NavigationState]
    @State var pinnedNavigationStateArray = [] as [NavigationState]
    @State var favoritesNavigationStateArray = [] as [NavigationState]
    
    // Storage and Website Loading
    @AppStorage("currentSpace") var currentSpace = "Untitled"
    //@State private var spaces = ["Home", "Space 2"]
    @State private var spaceIcons: [String: String]? = [:]
    
    @State private var reloadTitles = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let rotationTimer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    
    // Settings and Sheets
    @State private var hoverTab = WKWebView()
    
    @State private var showSettings = false
    @State private var changeColorSheet = false
    
    @State private var startColor: Color = Color.purple
    @State private var endColor: Color = Color.pink
    @State private var textColor: Color = Color.white
    
    @AppStorage("startColorHex") var startHex = "8A3CEF"
    @AppStorage("endColorHex") var endHex = "84F5FE"
    @AppStorage("textColorHex") var textHex = "ffffff"
    
    @AppStorage("swipingSpaces") var swipingSpaces = true
    
    @State private var presentIcons = false
    
    // Hover Effects
    @State private var hoverTinySpace = false
    @State private var hoverSidebarButton = false
    @State private var hoverPaintbrush = false
    @State private var hoverReloadButton = false
    @State private var hoverForwardButton = false
    @State private var hoverBackwardButton = false
    @State private var hoverNewTab = false
    @State private var settingsButtonHover = false
    @State private var hoverNewTabSection = false
    
    @State private var hoverSpaceIndex = 1000
    @State private var hoverSpace = ""
    
    @State private var hoverSidebarSearchField = false
    
    @State private var hoverCloseTab = WKWebView()
    
    @State private var spaceIconHover = false
    
    // Animations and Gestures
    @State private var reloadRotation = 0
    @State private var draggedTab: WKWebView?
    
    // Selection States
    @State private var tabBarShown = false
    @State private var commandBarShown = false
    
    @State private var changingIcon = ""
    //@State private var hideSidebar = false
    @AppStorage("hideSidebar") var hideSidebar = false
    
    @State private var searchInSidebar = ""
    @State private var newTabSearch = ""
    @State private var newTabSaveSearch = ""
    
    @State private var currentTabNum = 0
    
    @State private var selectedIndex: Int? = 0
    
    @FocusState private var focusedField: FocusedField?
    
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
    
    @State private var inspectCode = ""
    
    enum FocusedField {
        case commandBar, tabBar, none
    }
    @State private var selectedTabLocation = "tabs"
    
    // Other Stuff
    @State private var screenWidth = UIScreen.main.bounds.width
    
    @State private var hoveringSidebar = false
    @State private var tapSidebarShown = false
    
    @State var commandBarCollapseHeightAnimation = false
    @State var commandBarSearchSubmitted = false
    @State var commandBarSearchSubmitted2 = false
    
    @State var auraTab = ""
    
    @State var initialLoadDone = false
    
    @State var scrollLimiter = false
    
    @State private var scrollPosition: CGPoint = .zero
    @State private var horizontalScrollPosition: CGPoint = .zero
    
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
}
