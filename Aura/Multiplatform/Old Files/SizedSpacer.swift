//
//  Functions.swift
//  iPad browser
//
//  Created by Caedmon Myers on 11/9/23.
//

import SwiftUI

struct SizedSpacer: View {
    @State var height: Int = 0
    @State var width: Int = 0
    var body: some View {
        Spacer()
            .frame(width: width == 0 ? .infinity: CGFloat(width), height: height == 0 ? .infinity: CGFloat(height))
    }
}


