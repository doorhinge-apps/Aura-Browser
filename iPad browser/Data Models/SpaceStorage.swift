//
//  SpaceStorage.swift
//  Aura
//
//  Created by Quinn O'Donnell on 4/27/24.
//

import SwiftUI
import SwiftData


@Model
class SpaceStorage {
    var spaceName: String = ""
    var spaceIcon: String = ""
    var favoritesUrls: [String] = []
    var pinnedUrls: [String] = []
    var tabUrls: [String] = []
    var startHex: String = ""
    var endHex: String = ""
    
    init(spaceName: String =  "", spaceIcon: String =  "", favoritesUrls: [String] =  [""], pinnedUrls: [String] =  [""], tabUrls: [String] =  [""], startHex: String =  "8A3CEF", endHex: String =  "84F5FE") {
        self.spaceName = spaceName
        self.spaceIcon = spaceIcon
        self.favoritesUrls = favoritesUrls
        self.pinnedUrls = pinnedUrls
        self.tabUrls = tabUrls
        self.startHex = startHex
        self.endHex = endHex
    }
}
