//
//  iPad_browserApp.swift
//  iPad browser
//
//  Created by Caedmon Myers on 8/9/23.
//

import SwiftUI
import SwiftData
import CloudKit
#if !os(macOS)
import UIKit
#else
import AppKit
#endif

class CustomAppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Set the appearance of UITabBar here
        //UITabBar.appearance().backgroundColor = UIColor.clear
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle the incoming URL
        NotificationCenter.default.post(name: .handleIncomingURL, object: url)
        return true
    }
    
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)

        // Remove unwanted menus
        builder.remove(menu: .services)
        builder.remove(menu: .format)
        builder.remove(menu: .toolbar)
    }
}

extension Notification.Name {
    static let handleIncomingURL = Notification.Name("handleIncomingURL")
}

@main
struct iPad_browserApp: App {
    
    @UIApplicationDelegateAdaptor(CustomAppDelegate.self) var appDelegate
    
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
    
    
    init() {
        UserDefaults.standard.set(0, forKey: "selectedSpaceIndex")
    }

    var body: some Scene {
        WindowGroup {
            OnboardingView()
                .onAppear { hideTitleBarOnCatalyst() }
//                .onOpenURL { url in
//                    variables.navigationState.createNewWebView(withRequest: URLRequest(url: url))
//                    print("Url:")
//                    print(url)
//                }
        }
        .modelContainer(for: SpaceStorage.self, inMemory: false, isAutosaveEnabled: true, isUndoEnabled: true)
    }
    
    func hideTitleBarOnCatalyst() {
#if targetEnvironment(macCatalyst)
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.titlebar?.titleVisibility = .hidden
#endif
    }
}



