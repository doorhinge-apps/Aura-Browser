//
//  DropViewDelegate.swift
//  iPad browser
//
//  Created by Caedmon Myers on 19/4/24.
//

import SwiftUI
import WebKit
import Dynamic

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
                        
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    }
                }
            }
        }
    }
}
