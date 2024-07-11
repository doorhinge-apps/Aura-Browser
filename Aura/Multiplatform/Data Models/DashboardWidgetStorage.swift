//
//  DashboardWidgetStorage.swift
//  Aura
//
//  Created by Caedmon Myers on 16/5/24.
//

import SwiftUI
import SwiftData

struct DashboardWidget: Codable, Identifiable, Equatable {
    var id = UUID()
    var title: String
    var xPosition: Double
    var yPosition: Double
    var width: Double
    var height: Double
}
