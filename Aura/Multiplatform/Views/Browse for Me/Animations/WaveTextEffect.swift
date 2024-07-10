//
//  WaveTextEffect.swift
//  Aura
//
//  Created by Caedmon Myers on 22/6/24.
//

import SwiftUI


struct AnimatedSineWaveOffsetRender: TextRenderer {
  let timeOffset: Double // Time offset
  func draw(layout: Text.Layout, in context: inout GraphicsContext) {
    let count = layout.flattenedRunSlices.count // Count all RunSlices in the text layout
    let width = layout.first?.typographicBounds.width ?? 0 // Get the width of the text line
    let height = layout.first?.typographicBounds.rect.height ?? 0 // Get the height of the text line
    // Iterate through each RunSlice and its index
    for (index, slice) in layout.flattenedRunSlices.enumerated() {
      // Calculate the sine wave offset for the current character
      let offset = animatedSineWaveOffset(
        forCharacterAt: index,
        amplitude: height / 2, // Set amplitude to half the line height
        wavelength: width,
        phaseOffset: timeOffset,
        totalCharacters: count
      )
      // Create a copy of the context and translate it
      var copy = context
      copy.translateBy(x: 0, y: offset)
      // Draw the current RunSlice in the modified context
      copy.draw(slice)
    }
  }

  // Calculate the sine wave offset based on character index
  func animatedSineWaveOffset(forCharacterAt index: Int, amplitude: Double, wavelength: Double, phaseOffset: Double, totalCharacters: Int) -> Double {
    let x = Double(index)
    let position = (x / Double(totalCharacters)) * wavelength
    let radians = ((position + phaseOffset) / wavelength) * 2 * .pi
    return sin(radians) * amplitude
  }
}


extension Text.Layout {
  var flattenedRuns: some RandomAccessCollection<Text.Layout.Run> {
    flatMap { line in
      line
    }
  }
}

extension Text.Layout {
  var flattenedRunSlices: some RandomAccessCollection<Text.Layout.RunSlice> {
    flattenedRuns.flatMap(\.self)
  }
}
