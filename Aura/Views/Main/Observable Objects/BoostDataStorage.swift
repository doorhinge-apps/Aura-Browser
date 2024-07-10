//
//  BoostDataStorage.swift
//  Aura
//
//  Created by Caedmon Myers on 8/7/24.
//

import SwiftUI

class BoostDataStorage: ObservableObject {
    @Published var keyValuePairs: [String: String] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    private let userDefaultsKey = "boostDataStorage"
    
    init() {
        if let savedData = UserDefaults.standard.dictionary(forKey: userDefaultsKey) as? [String: String] {
            self.keyValuePairs = savedData
        } else {
            self.keyValuePairs = [:]
        }
    }
    
    private func saveToUserDefaults() {
        UserDefaults.standard.set(keyValuePairs, forKey: userDefaultsKey)
    }
    
    func getValue(forKey key: String) -> String? {
        return keyValuePairs[key]
    }
}
