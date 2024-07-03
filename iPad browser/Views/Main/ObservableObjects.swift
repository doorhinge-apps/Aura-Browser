//
//  ObservableObjects.swift
//  Aura
//
//  Created by Caedmon Myers on 3/6/24.
//

import SwiftUI
import WebKit
import WebViewSwiftUI
import LinkPresentation


class ObservableVariables: ObservableObject {
    @AppStorage("prefferedColorScheme") var prefferedColorScheme = "automatic"
    
    // Webview handling
    @ObservedObject var navigationState = NavigationState()
    @ObservedObject var pinnedNavigationState = NavigationState()
    @ObservedObject var favoritesNavigationState = NavigationState()
    
    @StateObject var settings = SettingsVariables()
    
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
}


class WebsiteManager: ObservableObject {
    @Published var webViewStores: [String: WebViewStore] = [:]
    
    @Published var selectedWebView: WebViewStore?
    
    func addWebViewStore(id: String, webViewStore: WebViewStore) {
        webViewStores[id] = webViewStore
    }
    
    func getWebViewStore(id: String) -> WebViewStore? {
        return webViewStores[id]
    }
    
    func selectOrAddWebView(urlString: String) {
        if let existingStore = webViewStores.values.first(where: { $0.webView.url?.absoluteString == urlString }) {
            // Set the found WebViewStore as the selected WebView
            selectedWebView = existingStore
        } else {
            // Create a new WebViewStore if not found and add it to the dictionary
            let newWebViewStore = WebViewStore()
            newWebViewStore.webView.allowsBackForwardNavigationGestures = true
            
            
            newWebViewStore.loadIfNeeded(url: URL(string: urlString) ?? URL(string: "https://example.com")!)
            webViewStores[urlString] = newWebViewStore
            selectedWebView = newWebViewStore
        }
        
        if webViewStores.count > 15 {
            webViewStores = Dictionary(webViewStores.keys.prefix(15).map { ($0, webViewStores[$0]!) }, uniquingKeysWith: { first, _ in first })
        }
    }
    
    
    @Published var linksWithTitles: [String: String] = [:]
    
    func fetchTitles(for urls: [String]) {
        for urlString in urls {
            guard let url = URL(string: urlString) else { continue }
            
            let metadataProvider = LPMetadataProvider() // Create a new instance for each URL
            metadataProvider.startFetchingMetadata(for: url) { (metadata, error) in
                guard error == nil, let title = metadata?.title else {
                    print("Failed to fetch metadata for url: \(urlString)")
                    return
                }
                DispatchQueue.main.async {
                    self.linksWithTitles[urlString] = title
                }
            }
        }
    }
    
    func fetchTitlesIfNeeded(for urls: [String]) {
        for urlString in urls {
            if linksWithTitles[urlString] == nil {
                guard let url = URL(string: urlString) else { continue }
                
                let metadataProvider = LPMetadataProvider() // Create a new instance for each URL
                metadataProvider.startFetchingMetadata(for: url) { (metadata, error) in
                    guard error == nil, let title = metadata?.title else {
                        print("Failed to fetch metadata for url: \(urlString)")
                        return
                    }
                    DispatchQueue.main.async {
                        self.linksWithTitles[urlString] = title
                    }
                }
            }
        }
    }
    
    @AppStorage("selectedSpaceIndex") var selectedSpaceIndex = 0
    
    @Published var hoverTab = ""
    
    @Published var selectedTabIndex = -1
    @Published var hoverTabIndex = -1
    @Published var hoverCloseTabIndex = -1
    
    @Published var draggedIndex: Int?
    
    @Published var selectedTabLocation: TabLocations = .tabs
    @Published var hoverTabLocation: TabLocations = .tabs
}


class LinkViewModel: ObservableObject {
    let metadataProvider = LPMetadataProvider()
    
    @Published var metadata: LPLinkMetadata?
    @Published var image: UIImage?
    
    init(link: String) {
        guard let url = URL(string: link) else {
            return
        }
        metadataProvider.startFetchingMetadata(for: url) { (metadata, error) in
            guard error == nil else {
                assertionFailure("Error")
                return
            }
            DispatchQueue.main.async {
                self.metadata = metadata
            }
            guard let imageProvider = metadata?.imageProvider else { return }
            imageProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                guard error == nil else {
                    // handle error
                    return
                }
                if let image = image as? UIImage {
                    // do something with image
                    DispatchQueue.main.async {
                        self.image = image
                    }
                } else {
                    print("no image available")
                }
            }
        }
    }
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
    
    @AppStorage("swipeNavigationDisabled") var swipeNavigationDisabled = false
    
    @AppStorage("launchAnimation") var launchAnimation = true
    
    @AppStorage("apiKey") var apiKey = ""
}
