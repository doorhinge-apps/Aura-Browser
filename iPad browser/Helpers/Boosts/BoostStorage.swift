//
//  BoostStorage.swift
//  Aura
//
//  Created by Caedmon Myers on 23/6/24.
//

import SwiftUI


struct Boost: Codable {
    var webUrl: String
    var css: String
}


class BoostStore: ObservableObject {
    @Published var boost: Boost {
        didSet {
            saveBoost()
        }
    }
    
    init() {
        self.boost = BoostStore.loadBoost() ?? Boost(webUrl: "", css: "")
    }
    
    private func saveBoost() {
        if let encoded = try? JSONEncoder().encode(boost) {
            UserDefaults.standard.set(encoded, forKey: "boost")
        }
    }
    
    private static func loadBoost() -> Boost? {
        if let data = UserDefaults.standard.data(forKey: "boost"),
           let boost = try? JSONDecoder().decode(Boost.self, from: data) {
            return boost
        }
        return nil
    }
}
