//
//  TextFieldDynamicWidth.swift
//
//  Created by Joseph Hinkle on 9/10/20.
//

import SwiftUI

struct TextFieldDynamicWidth: View {
    let title: String
    @Binding var text: String
    //let onEditingChanged: (Bool) -> Void
    //let onCommit: () -> Void
    
    @State private var textRect = CGRect()
    
    var body: some View {
        ZStack {
            Text(text == "" ? title : text).background(GlobalGeometryGetter(rect: $textRect)).layoutPriority(1).opacity(0)
            HStack {
                TextField(title, text: $text)
                .frame(width: textRect.width)
            }
        }
    }
}


//
//  GlobalGeometryGetter
//
// source: https://stackoverflow.com/a/56729880/3902590
//

struct GlobalGeometryGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        return GeometryReader { geometry in
            self.makeView(geometry: geometry)
        }
    }

    func makeView(geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = geometry.frame(in: .global)
        }

        return Rectangle().fill(Color.clear)
    }
}
