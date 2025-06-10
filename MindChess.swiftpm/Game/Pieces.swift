//
//  Entities.swift
//  MindChess
//
//  Created by Charles de PLUVIÉ on 08/02/2024.
//

import SpriteKit
import SwiftUI

public enum PlayerColor : String {
    case white, black
    
    var uiColor : UIColor {
        switch self {
        case .white : UIColor.white
        case .black : UIColor.black
        }
    }
}

public enum PieceType : String, CaseIterable {
    case queen, king, knight, bishop, rook, pawn
}

public struct PieceMovements {
    
    public let startGridPosition : GridPosition
    public let endGridPosition : GridPosition
    public let pieceEaten : ChessPieceNode?
    
}

public final class ChessPieceNode : SKSpriteNode {
    
    private let tileSize : CGFloat
    
    public let colorSide : PlayerColor
    public var type : PieceType
    public var gridPosition : GridPosition
    public var moveCount : Int = 0
    
    init?(tileSize: CGFloat, colorSide: PlayerColor, type: PieceType, gridPosition: GridPosition) {
        
        self.tileSize = tileSize
        self.colorSide = colorSide
        self.type = type
        self.gridPosition = gridPosition
        
        guard let texture = TextureManager.shared.getPieceTextureOf(self.type) else {
            print("Error loading piece texture for \(type.rawValue) at \(String(describing: gridPosition))")
            return nil
        }
        
        super.init(texture: texture, color: .clear, size: CGSize(width: tileSize, height: tileSize))
        
        self.position = self.getPositionWith(gridPosition)
        self.color = colorSide.uiColor
        self.colorBlendFactor = 1.0
        self.zPosition = 2
        self.name = "ChessPiece"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("An error occurred while creating a ChessPieceNode")
    }
    
    public func increaseMoveCount() {
        self.moveCount += 1
    }
    
    // MARK: - Update position
    
    public func updatePositionWithEffect(gridPosition: GridPosition) {
        Task {
            self.gridPosition = gridPosition
            
            let newPosition = getPositionWith(gridPosition)
            
            let actionMove = SKAction.move(to: newPosition, duration: 0.2)
            await self.run(actionMove)
            
            self.removeAllActions()
        }
    }
    
    private func getPositionWith(_ gridPosition: GridPosition) -> CGPoint {
        let (row, column) : (Int, Int) = gridPosition.rowAndColumn
        return CGPoint(x: CGFloat(column+1) * self.tileSize + 1, y: CGFloat(row + 1) * self.tileSize)
    }
    
    // MARK: - Change piece color when selected
    
    public func showPieceSelected() {
        self.color = (self.colorSide == .white) ? UIColor.whiteSelectedPiece : UIColor.blackSelectedPiece
        self.colorBlendFactor = 0.8
    }
    
    public func desablePieceSelected() {
        self.color = self.colorSide.uiColor
        self.colorBlendFactor = 1.0
    }
}
