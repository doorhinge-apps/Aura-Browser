//
//  DropViewDelegate.swift
//  iPad browser
//
//  Created by Reyna Myers on 19/4/24.
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
    @Binding var allItems: [String]
    @Binding var draggedItem: String?
    @Binding var draggedItemIndex: Int?
    @Binding var currentHoverIndex: Int?
    var onDropAction: () -> Void
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        // Update current hover index
        currentHoverIndex = destinationIndex
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        currentHoverIndex = nil
        draggedItem = nil
        draggedItemIndex = nil
        
        onDropAction()
        
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // Swap Items
        if let draggedItem, let draggedItemIndex {
            if draggedItemIndex != destinationIndex {
                withAnimation {
                    self.allItems.move(fromOffsets: IndexSet(integer: draggedItemIndex), toOffset: (destinationIndex > draggedItemIndex ? (destinationIndex + 1) : destinationIndex))
                    softHaptics()
                }
            }
        }
    }
}


struct IndexDropViewDelegateNew: DropDelegate {
    let destinationIndex: Int
    @Binding var allItems: [String]
    @Binding var draggedItem: String?
    @Binding var draggedItemIndex: Int?
    @Binding var currentHoverIndex: Int?
    let tabHeight: CGFloat
    var onDropAction: () -> Void

    func dropEntered(info: DropInfo) {
        guard let draggedItem, let draggedItemIndex else { return }

        // Calculate the drop location within the tab's vertical bounds
        let dropLocationY = info.location.y
        let threshold = tabHeight / 2

        // Determine if the drop is in the top or bottom half of the tab
        let isInTopHalf = dropLocationY < threshold
        let targetIndex = isInTopHalf ? destinationIndex : destinationIndex + 1

        // Rearrange items only if the target index is different
        if draggedItemIndex != targetIndex {
            withAnimation {
                self.allItems.move(
                    fromOffsets: IndexSet(integer: draggedItemIndex),
                    toOffset: targetIndex > draggedItemIndex ? targetIndex + 1 : targetIndex
                )
                softHaptics()
            }

            // Update hover index for visual feedback
            currentHoverIndex = targetIndex
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        // Keep the hover index updated for visual indicators
        currentHoverIndex = destinationIndex
        return DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        // Reset all drag/drop state variables on completion
        currentHoverIndex = nil
        draggedItem = nil
        draggedItemIndex = nil

        // Trigger custom on-drop action
        onDropAction()

        return true
    }

    func dropExited(info: DropInfo) {
        // Reset hover state when drag exits
        currentHoverIndex = nil
    }
}




    extension Array {
        mutating func move(fromOffsets source: IndexSet, toOffset destination: Int) {
            let reversedSource = source.sorted(by: >)
            for index in reversedSource {
                if index < destination {
                    self.insert(self.remove(at: index), at: destination - 1)
                } else {
                    self.insert(self.remove(at: index), at: destination)
                }
            }
        }
    }

