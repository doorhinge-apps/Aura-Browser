//
//  ThreeDots.swift
//  iPad browser
//
//  Created by Caedmon Myers on 19/4/24.
//

import SwiftUI

struct ThreeDots: View {
    @Binding var hoverTinySpace: Bool
    @Binding var hideSidebar: Bool
    var body: some View {
        VStack {
            
            Spacer()
                .frame(width: 20, height: 20)
            
            if hideSidebar {
                Button {
                    
                } label: {
                    VStack(spacing: 2) {
                        Circle()
                            .frame(width: 8, height: 8)
                        
                        Circle()
                            .frame(width: 8, height: 8)
                        
                        Circle()
                            .frame(width: 8, height: 8)
                        
                    }.padding(.horizontal, 6.5).foregroundStyle(Color.white)
#if !os(visionOS) && !os(macOS)
                        .hoverEffect(.highlight)
                    #endif
                }
            }
            
            
            Spacer()
                .frame(width: 20)
        }
    }
}

