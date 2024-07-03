//
//  DropViewDelegate.swift
//  iPad browser
//
//  Created by Caedmon Myers on 19/4/24.
//

import SwiftUI
import WebKit

struct DropViewDelegate: DropDelegate {
    
    let destinationItem: WKWebView
    @Binding var allTabs: [WKWebView]
    @Binding var draggedItem: WKWebView?
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // Swap Items
        if let draggedItem {
            let fromIndex = allTabs.firstIndex(of: draggedItem)
            if let fromIndex {
                let toIndex = allTabs.firstIndex(of: destinationItem)
                if let toIndex, fromIndex != toIndex {
                    withAnimation {
                        self.allTabs.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex))
                        softHaptics()
                    }
                }
            }
        }
    }
}



struct AlternateDropViewDelegate: DropDelegate {
    let destinationItem: (id: UUID, url: String)
    @Binding var allTabs: [(id: UUID, url: String)]
    @Binding var draggedItem: (id: UUID, url: String)?

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let dragged = draggedItem else { return false }
        guard let fromIndex = allTabs.firstIndex(where: { $0.id == dragged.id }) else { return false }
        guard let toIndex = allTabs.firstIndex(where: { $0.id == destinationItem.id }) else { return false }
        if fromIndex != toIndex {
            withAnimation {
                allTabs.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: (toIndex > fromIndex ? toIndex + 1 : toIndex))
            }
        }
        draggedItem = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let dragged = draggedItem else { return }
        guard let fromIndex = allTabs.firstIndex(where: { $0.id == dragged.id }) else { return }
        guard let toIndex = allTabs.firstIndex(where: { $0.id == destinationItem.id }) else { return }

        if fromIndex != toIndex {
            withAnimation {
                allTabs.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
        }
    }
}



struct IndexDropViewDelegate: DropDelegate {
    let destinationIndex: Int
    @State var allStrings: [String]
    @Binding var draggedIndex: Int?
    var onSuccessfulDrop: () -> Void  // Closure to call on successful drop

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let dragged = draggedIndex else { return false }
        if dragged != destinationIndex {
            withAnimation {
                allStrings.move(fromOffsets: IndexSet(integer: dragged), toOffset: destinationIndex > dragged ? destinationIndex + 1 : destinationIndex)
            }
            draggedIndex = nil
            onSuccessfulDrop()  // Call the closure after successful drop
            return true
        }
        draggedIndex = nil
        return false
    }

    func dropEntered(info: DropInfo) {
        guard let dragged = draggedIndex else { return }
        if dragged != destinationIndex {
            withAnimation {
                allStrings.move(fromOffsets: IndexSet(integer: dragged), toOffset: destinationIndex > dragged ? destinationIndex + 1 : destinationIndex)
            }
        }
    }
}

