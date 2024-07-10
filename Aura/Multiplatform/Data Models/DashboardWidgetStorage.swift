//
//  DashboardWidgetStorage.swift
//  Aura
//
//  Created by Caedmon Myers on 16/5/24.
//

import SwiftUI
import SwiftData

/*
struct DashboardWidget: Equatable {
    var id = UUID()
    var title: String
    var xPosition: Double
    var yPosition: Double
    var width: Double
    var height: Double
}*/
//@Model
//class DashboardWidget {
//    var id = UUID()
//    var title: String = ""
//    var xPosition: Double = 0.0
//    var yPosition: Double = 0.0
//    var width: Double = 100.0
//    var height: Double = 100.0
//    
//    init(id: UUID = UUID(), title: String = "", xPosition: Double = 0.0, yPosition: Double = 0.0, width: Double = 100.0, height: Double = 100.0) {
//        self.id = id
//        self.title = title
//        self.xPosition = xPosition
//        self.yPosition = yPosition
//        self.width = width
//        self.height = height
//    }
//}

struct DashboardWidget: Codable, Identifiable, Equatable {
    var id = UUID()
    var title: String
    var xPosition: Double
    var yPosition: Double
    var width: Double
    var height: Double
}
