//
//  BoostDataStorage.swift
//  Aura
//
//  Created by Reyna Myers on 8/7/24.
//

import SwiftUI

class BoostDataStorage: ObservableObject {
    @Published var keyValuePairs: [String: String] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    @Published var disabledBoosts: [String] {
        didSet {
            UserDefaults.standard.setValue(disabledBoosts, forKey: "disabledBoosts")
        }
    }
    
    private let userDefaultsKey = "boostDataStorage"
    
    init() {
        if let savedData = UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: String] {
            self.keyValuePairs = savedData
        } else {
            self.keyValuePairs = [:]
        }
        
        self.disabledBoosts = UserDefaults.standard.stringArray(forKey: "disabledBoosts") ?? []
    }
    
    private func saveToUserDefaults() {
        UserDefaults.standard.set(keyValuePairs, forKey: userDefaultsKey)
    }
    
    func disableBoost(_ boost: String) {
        disabledBoosts.append(boost)
    }
    
    func enableBoost(_ boost: String) {
        disabledBoosts = disabledBoosts.filter { $0 != boost }
    }
    
    func getValue(forKey key: String) -> String? {
        return keyValuePairs[key]
    }
}
