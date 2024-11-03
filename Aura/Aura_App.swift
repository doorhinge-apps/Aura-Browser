//
//  iPad_browserApp.swift
//  iPad browser
//
//  Created by Reyna Myers on 8/9/23.
//

import SwiftUI
import SwiftData
import CloudKit
#if !os(macOS)
import UIKit
#else
import AppKit
#endif

#if !os(macOS)
class CustomAppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set the appearance of UITabBar here
        //UITabBar.appearance().backgroundColor = UIColor.clear
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        NotificationCenter.default.post(name: .handleIncomingURL, object: url)
        return true
    }
    
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        builder.remove(menu: .services)
        builder.remove(menu: .format)
        builder.remove(menu: .toolbar)
    }
}
#else
class CustomAppDelegate: NSResponder, NSApplicationDelegate {
    
}
#endif

extension Notification.Name {
    static let handleIncomingURL = Notification.Name("handleIncomingURL")
}

@main
struct iPad_browserApp: App {
#if !os(macOS)
    @UIApplicationDelegateAdaptor(CustomAppDelegate.self) var appDelegate
    #else
    @NSApplicationDelegateAdaptor(CustomAppDelegate.self) var appDelegate
    #endif
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SpaceStorage.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            var container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject var variables = ObservableVariables()
    @StateObject var settings = SettingsVariables()
    @StateObject var manager =  WebsiteManager()
    
    
    init() {
        UserDefaults.standard.set(0, forKey: "selectedSpaceIndex")
    }

    var body: some Scene {
#if !os(visionOS)
        WindowGroup {
            OnboardingView()
                .onAppear { hideTitleBarOnCatalyst() }
                .environmentObject(variables)
                .environmentObject(settings)
                .environmentObject(manager)
        }
        .modelContainer(for: SpaceStorage.self, inMemory: false, isAutosaveEnabled: true, isUndoEnabled: true)
        #if os(macOS)
        .windowStyle(HiddenTitleBarWindowStyle())
        #endif
#else
        WindowGroup {
            TabbedPagedSidebar(isHovering: false)
                .padding(5)
                .padding(.leading, 5)
                .environmentObject(variables)
                .environmentObject(settings)
                .environmentObject(manager)
        }
        .defaultSize(width: 300, height: 800)
        .modelContainer(for: SpaceStorage.self, inMemory: false, isAutosaveEnabled: true, isUndoEnabled: true)
        
        WindowGroup(id: "mainWindow") {
            ContentView()
                .onAppear { hideTitleBarOnCatalyst() }
                .environmentObject(variables)
                .environmentObject(settings)
                .environmentObject(manager)
        }
        .modelContainer(for: SpaceStorage.self, inMemory: false, isAutosaveEnabled: true, isUndoEnabled: true)
#endif
    }
    
    func hideTitleBarOnCatalyst() {
#if targetEnvironment(macCatalyst)
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.titlebar?.titleVisibility = .hidden
#endif
    }
}



