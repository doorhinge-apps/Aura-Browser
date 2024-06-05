//
//  Trackpad.swift
//  Aura
//
//  Created by Caedmon Myers on 4/6/24.
//

import SwiftUI

struct TrackpadScrollView: UIViewRepresentable {
    var onScroll: (CGFloat) -> Void
    var onScrollEnd: () -> Void

    class Coordinator: NSObject, UIScrollViewDelegate {
        var onScroll: (CGFloat) -> Void
        var onScrollEnd: () -> Void
        
        init(onScroll: @escaping (CGFloat) -> Void, onScrollEnd: @escaping () -> Void) {
            self.onScroll = onScroll
            self.onScrollEnd = onScrollEnd
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offset = scrollView.contentOffset.x
            onScroll(offset)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            scrollView.contentOffset = CGPoint(x: 0, y: 0) // Reset to prevent default scrolling
            onScrollEnd()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(onScroll: onScroll, onScrollEnd: onScrollEnd)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: 1, height: 1) // To enable horizontal scrolling
        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {}
}
