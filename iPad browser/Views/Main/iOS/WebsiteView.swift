//
//  WebsiteView.swift
//  Aura
//
//  Created by Caedmon Myers on 26/6/24.
//

import SwiftUI

struct WebsiteView: View {
    @State var url: String
    @State private var offset = CGSize.zero
    @State private var scale: CGFloat = 1.0
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var parentGeo: GeometryProxy
    
    @State var gestureStarted = false
    
    @State var exponentialThing = 1.0
    
    @State private var webTitle: String = ""
    
    var body: some View {
        GeometryReader { geo in
#if !os(macOS)
            ZStack {
                WebViewMobile(urlString: url, title: $webTitle)
                    .ignoresSafeArea()
                    .navigationBarBackButtonHidden(true)
                    .offset(x: offset.width, y: offset.height)
                    .scaleEffect(scale)
                
                VStack {
                    Spacer()
                    
                    ZStack {
                        Rectangle()
                            .fill(.regularMaterial)
                            .frame(height: 150)
                        
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.8))
                            .padding(10)
                            .frame(height: 65)
                    }
                }
                .offset(x: offset.width, y: offset.height)
                .scaleEffect(scale)
                .cornerRadius(15 - min(abs(offset.height) / 2, 15))
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            withAnimation {
                                gestureStarted = true
                            }
                            exponentialThing = exponentialThing * 0.99
                            var dragX = min(max(gesture.translation.width, -50), 50)
                            dragX *= exponentialThing
                            
                            let dragY = gesture.translation.height
                            if dragY < 0 { // Only allow upward movement
                                let slowDragY = dragY * 0.1 // Drag up slower
                                offset = CGSize(width: dragX, height: slowDragY)
                                scale = 1 - min(-slowDragY / 200, 0.5)
                            }
                        }
                        .onEnded { gesture in
                            exponentialThing = 1
                            withAnimation {
                                gestureStarted = false
                            }
                            if gesture.translation.height < -100 {
                                self.presentationMode.wrappedValue.dismiss()
                            } else {
                                withAnimation(.spring()) {
                                    offset = .zero
                                    scale = 1.0
                                }
                            }
                        }
                )
            }
            //.frame(height: gestureStarted ? geo.size.height * scale: .infinity)
            .ignoresSafeArea(.container, edges: [.leading, .trailing, .bottom])
            #endif
        }
    }
}

