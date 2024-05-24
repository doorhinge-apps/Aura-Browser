//
//  Tile Game.swift
//  Aura
//
//  Created by Caedmon Myers on 12/5/24.
//

import SwiftUI

struct TileGame: View {
    @Namespace var namespace
    
    @State private var tiles: [Int] = Array(0..<16)
    @State private var emptyIndex: Int = 15
    
    @State var size: CGFloat = 34.5
    
    @State var image: UIImage = UIImage(named: "catalina")!
    
    @State var hasShuffled = false
    @State var shuffling = false
    @State var adjacentTilesDisplay = [] as [Int]
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        let columns = Array(repeating: GridItem(.fixed(size), spacing: 1), count: 4)
            /*VStack {
                Text(hasShuffled.description)
                Text(shuffling.description)
                Text(adjacentTilesDisplay.description)
            }*/
            ZStack {
                LazyVGrid(columns: columns, spacing: 1) {
                    ForEach(0..<16, id: \.self) { index in
                        if index == emptyIndex {
                            Color.clear
                                .frame(width: size, height: size)
                                .matchedGeometryEffect(id: "tile", in: namespace)
                        } else {
                            if let tileImage = tileImage(for: tiles[index]) {
                                Image(uiImage: tileImage)
                                    .resizable()
                                    .frame(width: size, height: size)
                                    .onTapGesture {
                                        moveTile(at: index)
                                    }
                            } else {
                                Color.clear
                                    .frame(width: size, height: size)
                            }
                        }
                    }
                }
                
                if hasShuffled && tiles == Array(0..<16) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .onTapGesture {
                            tiles = Array(0..<16)
                            emptyIndex = 15
                            hasShuffled = false
                            shuffling = false
                        }
                }
                
                if !hasShuffled {
                    Button(action: {
                        if !shuffling {
                            shuffling = true
                        }
                        else {
                            shuffling = false
                            hasShuffled = true
                        }
                    }, label: {
                        Color.white.opacity(0.001).ignoresSafeArea()
                    })
                }
            }
            .frame(width: size * 4 + 3, height: size * 4 + 3)
            .onReceive(timer, perform: { _ in
                shuffleTiles()
            })
            .contextMenu(ContextMenu(menuItems: {
                Text("Change Image")
                
                Button(action: {
                    tiles = Array(0..<16)
                    emptyIndex = 15
                    hasShuffled = false
                    shuffling = false
                    
                    image = UIImage(named: "catalina")!
                }, label: {
                    Text("Catalina")
                })
                Button(action: {
                    tiles = Array(0..<16)
                    emptyIndex = 15
                    hasShuffled = false
                    shuffling = false
                    image = UIImage(named: "catalina night")!
                    
                }, label: {
                    Text("Catalina Night")
                })
                Button(action: {
                    tiles = Array(0..<16)
                    emptyIndex = 15
                    hasShuffled = false
                    shuffling = false
                    
                    image = UIImage(named: "mojave")!
                }, label: {
                    Text("Mojave")
                })
                Button(action: {
                    tiles = Array(0..<16)
                    emptyIndex = 15
                    hasShuffled = false
                    shuffling = false
                    
                    image = UIImage(named: "mojave night")!
                }, label: {
                    Text("Mojave Night")
                })
                Button(action: {
                    tiles = Array(0..<16)
                    emptyIndex = 15
                    hasShuffled = false
                    shuffling = false
                    
                    image = UIImage(named: "high sierra")!
                }, label: {
                    Text("High Sierra")
                })
                Button(action: {
                    tiles = Array(0..<16)
                    emptyIndex = 15
                    hasShuffled = false
                    shuffling = false
                    
                    image = UIImage(named: "sierra")!
                }, label: {
                    Text("Sierra")
                })
                Button(action: {
                    tiles = Array(0..<16)
                    emptyIndex = 15
                    hasShuffled = false
                    shuffling = false
                    
                    image = UIImage(named: "el capitan")!
                }, label: {
                    Text("El Capitan")
                })
                Button(action: {
                    tiles = Array(0..<16)
                    emptyIndex = 15
                    hasShuffled = false
                    shuffling = false
                    
                    image = UIImage(named: "yosemite")!
                }, label: {
                    Text("Yosemite")
                })
            }))
    }
    
    private func tileImage(for tileIndex: Int) -> UIImage? {
        guard tileIndex < 15 else { return nil }
        
        let scale = image.scale
        let tileSize = CGSize(width: image.size.width / 4, height: image.size.height / 4)
        let x = CGFloat(tileIndex % 4) * tileSize.width
        let y = CGFloat(tileIndex / 4) * tileSize.height
        
        let cropRect = CGRect(x: x * scale, y: y * scale, width: tileSize.width * scale, height: tileSize.height * scale)
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else { return nil }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: image.imageOrientation)
    }
    
    private func moveTile(at index: Int) {
        let canMove = isAdjacent(to: index, emptyIndex)
        if canMove {
            //withAnimation {
                tiles.swapAt(index, emptyIndex)
                emptyIndex = index
            //}
        }
    }
    
    private func adjacentIndexes(to index: Int) -> [Int] {
        var indexes = [Int]()
        
        let row = index / 4
        let column = index % 4
        
        if index - 4 >= 0 {
            indexes.append(index - 4)
        }
        
        if index + 4 <= 15 {
            indexes.append(index + 4)
        }
        
        if index - 1 >= 0 {
            indexes.append(index - 1)
        }
        
        if index + 1 <= 15 {
            indexes.append(index + 1)
        }
        
        
        
        /*
        if row > 0 {
            indexes.append(index - 4) // Tile above
        }
        if row < 3 {
            indexes.append(index + 4) // Tile below
        }
        if column > 0 {
            indexes.append(index - 1) // Tile to the left
        }
        if column < 3 {
            indexes.append(index + 1) // Tile to the right
        }
        */
        return indexes
    }

    
    private func isAdjacent(to index: Int, _ emptyIndex: Int) -> Bool {
        let rowDifference = abs((index / 4) - (emptyIndex / 4))
        let columnDifference = abs((index % 4) - (emptyIndex % 4))
        return (rowDifference == 1 && columnDifference == 0) || (rowDifference == 0 && columnDifference == 1)
    }
    
    private func moveRandomAdjacentTile(currentIndex: Int) {
//        let adjacent = adjacentIndexes(to: emptyIndex).compactMap { index in
//            tiles.firstIndex(of: index)
//        }
        var adjacent = adjacentIndexes(to: currentIndex)
        
        adjacentTilesDisplay = adjacent
        if let randomIndex = adjacent.randomElement() {
            moveTile(at: randomIndex)
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
//                for i in [0, 5, 15, 2, 12, 8, 6, 13, 7, 3, 14, 4, 10] {
//                    moveTile(at: i)
//                }
//            }
        } else {
            // Retry after 0.2 seconds if no valid adjacent tile is found
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//                moveRandomAdjacentTile()
//            }
            for i in 0..<16 {
                moveTile(at: i)
            }
        }
    }

    private func shuffleTiles() {
        if shuffling {
            moveRandomAdjacentTile(currentIndex: emptyIndex)
        }
    }

    
    private func isSolvable(_ tiles: [Int]) -> Bool {
        let inversions = countInversions(tiles)
        return inversions % 2 == 0
    }
    
    private func countInversions(_ tiles: [Int]) -> Int {
        var inversions = 0
        for i in 0..<tiles.count {
            for j in i+1..<tiles.count {
                if tiles[i] > tiles[j] && tiles[i] != 15 && tiles[j] != 15 {
                    inversions += 1
                }
            }
        }
        return inversions
    }
}

#Preview {
    TileGame()
}
