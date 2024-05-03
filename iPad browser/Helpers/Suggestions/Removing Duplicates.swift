//
//  Removing Duplicates.swift
//  Aura
//
//  Created by Caedmon Myers on 3/5/24.
//

import SwiftUI

extension RangeReplaceableCollection where Element: Hashable {
    var orderedSet: Self {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
    mutating func removeDuplicates() {
        var set = Set<Element>()
        removeAll { !set.insert($0).inserted }
    }
}
