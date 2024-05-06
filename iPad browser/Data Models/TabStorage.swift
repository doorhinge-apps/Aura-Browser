//
//  TabStorage.swift
//  Aura
//
//  Created by Quinn O'Donnell on 4/27/24.
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
