//
//  DefaultsStorage.swift
//  Aura
//
//  Created by Quinn O'Donnell on 4/28/24.
//

import SwiftUI

class DefaultsStorage: ObservableObject {
    @Published var email = "" {
        didSet {
            defaults.set(email, forKey: "email")
        }
    }
}
