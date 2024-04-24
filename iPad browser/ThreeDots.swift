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
//                    hoverTinySpace.toggle()
//                    
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                        hoverTinySpace = false
//                    }
                } label: {
                    VStack(spacing: 2) {
                        Circle()
                            .frame(width: 8, height: 8)
                        
                        Circle()
                            .frame(width: 8, height: 8)
                        
                        Circle()
                            .frame(width: 8, height: 8)
                        
                    }.padding(.horizontal, 6.5).foregroundStyle(Color.white).hoverEffect(.highlight)
                }.keyboardShortcut("e", modifiers: .command)
            }
            
            
            Spacer()
                .frame(width: 20)
        }
    }
}

