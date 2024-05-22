//
//  iPad_browserApp.swift
//  iPad browser
//
//  Created by Caedmon Myers on 8/9/23.
//

import SwiftUI
import Firebase
import SwiftData
import CloudKit


@main
struct iPad_browserApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SpaceStorage.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            //return try ModelContainer(for: schema, configurations: [modelConfiguration])
            var container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            //container.mainContext.undoManager = UndoManager()
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @AppStorage("launchDashboard") var launchDashboard = false
    
    init() {
        UserDefaults.standard.set(0, forKey: "selectedSpaceIndex")
        
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            if !launchDashboard {
                LoginView()
            }
            else {
                Dashboard()
            }
            //afdasdfkjnasd()
        }//.modelContainer(sharedModelContainer)
        //.modelContainer(for: [SpaceStorage.self, DashboardWidget.self], inMemory: false, isAutosaveEnabled: true, isUndoEnabled: true)
        .modelContainer(for: SpaceStorage.self, inMemory: false, isAutosaveEnabled: true, isUndoEnabled: true)
        //.modelContainer(modelContainer)
        //.modelContainer(for: DashboardWidget.self)
    }
}
