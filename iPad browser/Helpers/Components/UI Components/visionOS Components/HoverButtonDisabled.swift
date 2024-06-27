//
//  HoverButtonDisabled.swift
//  Aura
//
//  Created by Caedmon Myers on 25/6/24.
//

import SwiftUI


// This view disables the iPad and Mac custom hover interaction for visionOS users
struct HoverButtonDisabledVision: View {
    @State var hoverInteraction: Bool
    var body: some View {
#if !os(visionOS)
        Color(.white)
            .opacity(hoverInteraction ? 0.5: 0.0)
#endif
    }
}
