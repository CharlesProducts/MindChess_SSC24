//
//  Board.swift
//  MindChess
//
//  Created by Charles de PLUVIÉ on 08/02/2024.
//

import SwiftUI
import SpriteKit

public enum GridPosition : Int, CaseIterable {
    
    case a1, b1, c1, d1, e1, f1, g1, h1
    case a2, b2, c2, d2, e2, f2, g2, h2
    case a3, b3, c3, d3, e3, f3, g3, h3
    case a4, b4, c4, d4, e4, f4, g4, h4
    case a5, b5, c5, d5, e5, f5, g5, h5
    case a6, b6, c6, d6, e6, f6, g6, h6
    case a7, b7, c7, d7, e7, f7, g7, h7
    case a8, b8, c8, d8, e8, f8, g8, h8
    
    var rowAndColumn : (Int, Int) {
        let row = self.rawValue / 8
        let column = self.rawValue % 8
        return (row, column)
    }
    
    init?(from text: String) {
        for position in GridPosition.allCases {
            if String(describing: position) == text {
                self = position
                return
            }
        }
        return nil
    }
}

public enum Direction {
    case vertical, horizontal, diagonalLeft, diagonalRight, knightMove, invalid
}

public struct Board {
    
    public var tileSize : CGFloat
    
    // MARK: - Draw the board
    
    public func drawBoard() -> SKNode {
        
        // Create the boardNode
        let boardNode = SKNode()
        
        // Create image of the tiles
        let whiteTileImage : UIImage = self.drawSquare(color: UIColor.whiteSideColor, sideSize: self.tileSize)
        let blackTileImage : UIImage = self.drawSquare(color: UIColor.blackSideColor, sideSize: self.tileSize)
        
        // Create the textures
        let whiteTileTexture = SKTexture(image: whiteTileImage)
        let blackTileTexture = SKTexture(image: blackTileImage)
        
        // Create the definitions
        let whiteTileDefinition = SKTileDefinition(texture: whiteTileTexture)
        let blackTileDefinition = SKTileDefinition(texture: blackTileTexture)
        
        // Create the groups
        let whiteTileGroup = SKTileGroup(tileDefinition: whiteTileDefinition)
        let blackTileGroup = SKTileGroup(tileDefinition: blackTileDefinition)
        
        // Create tileSet
        let tileSet = SKTileSet(tileGroups: [blackTileGroup, whiteTileGroup], tileSetType: .grid)
        
        // Create the map
        let tileMap = SKTileMapNode(tileSet: tileSet, columns: 8, rows: 8, tileSize: tileSet.defaultTileSize)
        
        tileMap.fill(with: tileSet.tileGroups.first)
        
        for row in stride(from: 0, to: 7, by: 2) {
            for column in stride(from: 1, to: 8, by: 2) {
                tileMap.setTileGroup(whiteTileGroup, forColumn: column, row: row)
                tileMap.setTileGroup(whiteTileGroup, forColumn: column - 1, row: row + 1)
            }
        }
        
        tileMap.anchorPoint = .zero
        tileMap.position = CGPoint(x: self.tileSize/2, y: self.tileSize/2)
        
        // Add bord's element to the node
        let labelBoardNode = drawBoardLabel()
        let borderNode = drawBoardBorder()
        
        boardNode.addChild(tileMap)
        boardNode.addChild(labelBoardNode)
        boardNode.addChild(borderNode)
        
        boardNode.name = "WholeBoard"
        
        return boardNode
    }
    
    private func drawSquare(color: UIColor, sideSize: Double) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: sideSize, height: sideSize))
        return renderer.image { (context) in
            context.cgContext.setFillColor(color.cgColor)
            context.cgContext.setAlpha(0.9)
            context.fill(CGRect(x: 0, y: 0, width: sideSize, height: sideSize))
        }
    }
    
    private func drawBoardLabel() -> SKNode {
        
        let labelGroupNode = SKNode()
        
        let columnIndex : [String] = ["A", "B", "C", "D", "E", "F", "G", "H"]
        let rowIndex : [Int] = Array(1...8)
        
        for side in 0...1 {
            for (i, title) in columnIndex.enumerated() {
                // Create letter labels
                let labelNode = SKLabelNode(text: title)
                labelNode.fontName = "Arial Black"
                labelNode.fontSize = (self.tileSize * 35)/91
                labelNode.fontColor = UIColor.blackSideColor
                
                if side == 1  {
                    labelNode.position = CGPoint(
                        x: CGFloat(i + 1) * self.tileSize,
                        y: self.tileSize/8)
                } else {
                    labelNode.position = CGPoint(
                        x: CGFloat(i + 1) * self.tileSize,
                        y: self.tileSize * 9 - self.tileSize/8)
                    labelNode.zRotation = .pi
                }
                labelGroupNode.addChild(labelNode)
            }
            
            for (i, title) in rowIndex.enumerated() {
                // Create letter labels
                let labelNode = SKLabelNode(text: "\(title)")
                labelNode.fontName = "Arial Black"
                labelNode.fontSize = (self.tileSize * 35)/91
                labelNode.fontColor = UIColor.blackSideColor
                
                if side == 1  {
                    labelNode.position = CGPoint(
                        x: self.tileSize/4,
                        y: CGFloat(i+1) * self.tileSize - self.tileSize/8)
                } else {
                    labelNode.position = CGPoint(
                        x: self.tileSize * 9 - self.tileSize/4,
                        y: CGFloat(i+1) * self.tileSize + self.tileSize/8)
                    labelNode.zRotation = .pi
                }
                labelGroupNode.addChild(labelNode)
            }
        }
        return labelGroupNode
    }
    
    private func drawBoardBorder() -> SKNode {
        
        let borderNode = SKNode()
        
        let borderShapeNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.tileSize*8 + 2,height: self.tileSize*8 + 2), cornerRadius: 5)
        
        borderShapeNode.fillColor = .clear
        borderShapeNode.strokeColor = UIColor.blackSideColor
        borderShapeNode.lineWidth = 4
        borderShapeNode.position = CGPoint(x: self.tileSize/2, y: self.tileSize/2)
        
        borderNode.addChild(borderShapeNode)
        
        return borderNode
    }
}
