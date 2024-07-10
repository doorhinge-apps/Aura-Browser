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
    var spaceIndex: Int = 0
    var spaceName: String = ""
    var spaceIcon: String = ""
    var favoritesUrls: [String] = []
    var pinnedUrls: [String] = []
    var tabUrls: [String] = []
    var startHex: String = ""
    var endHex: String = ""
    var browseForMe: Bool? = false
    var browseForMeSearch: String? = ""
    var browseForMeResponse: String? = ""
    
    init(spaceIndex: Int = 0, spaceName: String =  "", spaceIcon: String =  "", favoritesUrls: [String] =  [""], pinnedUrls: [String] =  [""], tabUrls: [String] =  [""], startHex: String =  "8A3CEF", endHex: String =  "84F5FE", browseForMe: Bool? = false, browseForMeSearch: String = "", browseForMeResponse: String? = "") {
        self.spaceIndex = spaceIndex
        self.spaceName = spaceName
        self.spaceIcon = spaceIcon
        self.favoritesUrls = favoritesUrls
        self.pinnedUrls = pinnedUrls
        self.tabUrls = tabUrls
        self.startHex = startHex
        self.endHex = endHex
        self.browseForMe = browseForMe
        self.browseForMeSearch = browseForMeSearch
        self.browseForMeResponse = browseForMeResponse
    }
}
