//
//  DataStore.swift
//  Aura
//
//  Created by Caedmon Myers on 27/4/24.
//

import SwiftUI
import SwiftData


@Model
class TabStorage {
    var url: String
    
    init(url: String =  "") {
        self.url = url
    }
}


@Model
class SpaceStorage {
    var spaceName: String
    var spaceIcon: String
    var favoritesUrls: [String]
    var pinnedUrls: [String]
    var tabUrls: [String]
    
    init(spaceName: String =  "", spaceIcon: String =  "", favoritesUrls: [String] =  [""], pinnedUrls: [String] =  [""], tabUrls: [String] =  [""]) {
        self.spaceName = spaceName
        self.spaceIcon = spaceIcon
        self.favoritesUrls = favoritesUrls
        self.pinnedUrls = pinnedUrls
        self.tabUrls = tabUrls
    }
}
