//
//  HistoryStorage.swift
//  Aura
//
//  Created by Reyna Myers on 12/7/24.
//

import SwiftUI

extension Date {
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d/M/yy h:mm a"
        return formatter.string(from: self)
    }
}


struct HistoryItem: Codable, Identifiable {
    var id = UUID()
    var title: String?
    var websiteURL: String
    var date: Date
}

class HistoryObservable: ObservableObject {
    @Published var items: [HistoryItem] {
        didSet {
            saveItems()
        }
    }

    init() {
        if let loadedItems = HistoryObservable.loadItems() {
            self.items = loadedItems.sorted(by: { $0.date > $1.date })
        } else {
            self.items = []
        }
    }

    func addItem(_ item: HistoryItem) {
        items.append(item)
        items = items.sorted(by: { $0.date > $1.date })
    }

    func removeItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }

    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "HistoryItems")
        }
    }

    private static func loadItems() -> [HistoryItem]? {
        if let data = UserDefaults.standard.data(forKey: "HistoryItems"),
           let decoded = try? JSONDecoder().decode([HistoryItem].self, from: data) {
            return decoded
        }
        return nil
    }
}
