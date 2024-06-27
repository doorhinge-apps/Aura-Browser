//
//  VGrid.swift
//  Aura
//
//  Created by Caedmon Myers on 22/6/24.
//


//
//  VGrid.swift
//  Aura
//
//  Created by Caedmon Myers on 21/6/24.
//

import SwiftUI

extension Array {
    func getElementAt(index: Int) -> Element? {
        return (index < self.endIndex) ? self[index] : nil
    }
}

struct VGrid<Element, GridCell>: View where GridCell: View {
    
    private var array: [Element]
    private var numberOfColumns: Int
    private var gridCell: (_ element: Element) -> GridCell
    
    init(_ array: [Element], numberOfColumns: Int, @ViewBuilder gridCell: @escaping (_ element: Element) -> GridCell) {
        self.array = array
        self.numberOfColumns = numberOfColumns
        self.gridCell = gridCell
    }
    
    var body: some View {
        Grid {
            ForEach(Array(stride(from: 0, to: self.array.count, by: self.numberOfColumns)), id: \.self) { index in
                GridRow {
                    ForEach(0..<self.numberOfColumns, id: \.self) { j in
                        if let element = self.array.getElementAt(index: index + j) {
                            self.gridCell(element)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}