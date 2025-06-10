//
//  ChessModel.swift
//  MindChess
//
//  Created by Charles de PLUVIÉ on 08/02/2024.
//

import SwiftUI
import SpriteKit
import AVFoundation

final class ChessScene : SKScene, ObservableObject {
    
    @Published var pieceToPromute : Bool = false
    @Published var swappingChessChoice = SwappingChessChoice.solo
    
    @Published var toucheHasBeenUsed : Bool = false
    @Published var speechRecognitionHasBeenUsed : Bool = false
    @Published var backButtonHasBeenUsed : Bool = false

    private var board : Board
    private var isWhiteTurn : Bool = true
    
    private var chessPieceNodes = [ChessPieceNode]()
    private var whitePositions : [GridPosition] {
        return chessPieceNodes.filter({ $0.colorSide == .white }).map({$0.gridPosition})
    }
    private var blackPositions : [GridPosition] {
        return chessPieceNodes.filter({ $0.colorSide == .black }).map({$0.gridPosition})
    }
    
    private var piecesMovements = [PieceMovements]()
    
    private var selectedNode : ChessPieceNode?
    private var whiteKingNode : ChessPieceNode? {
        chessPieceNodes.first(where: {$0.type == .king && $0.colorSide == .white})
    }
    private var blackKingNode : ChessPieceNode? {
        chessPieceNodes.first(where: {$0.type == .king && $0.colorSide == .black})
    }
    
    // MARK: - Init and reset the game
    
    init(sceneSize: CGSize) {
        self.board = Board(tileSize: sceneSize.width/9)
        super.init(size: sceneSize)
        
        TextureManager.shared.loadTextures {
            self.name = "ChessScene"
            self.scene?.size.width = sceneSize.width
            self.scene?.size.height = sceneSize.width
            self.scene?.backgroundColor = UIColor.whiteSideColor
            self.scene?.position = CGPoint(x: 0.0, y: 0.0)
            
            let animation = SKTransition.fade(withDuration: 1.0)
            self.view?.presentScene(self, transition: animation)
            self.addChild(self.board.drawBoard())
            self.placeInitialPiece(tileSize: self.board.tileSize)
            print("- - Chess initialized - -")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func restartGame() {
        
        self.removeAllChildren()
        
        self.isWhiteTurn = true
        self.pieceToPromute = false
        self.selectedNode = nil
        self.chessPieceNodes = []
        self.piecesMovements = []
        
        self.board = Board(tileSize: self.board.tileSize)
        self.addChild(self.board.drawBoard())
        
        self.placeInitialPiece(tileSize: self.board.tileSize)
        
        print("- - Chess re-initialized - -")
    }
    
    private func placeInitialPiece(tileSize: CGFloat) {
        
        var pieceNodes : [ChessPieceNode?] = [
            
            // Init white pieces
            ChessPieceNode(tileSize: tileSize, colorSide: .white, type: .rook, gridPosition: .a1),
            ChessPieceNode(tileSize: tileSize, colorSide: .white, type: .knight, gridPosition: .b1),
            ChessPieceNode(tileSize: tileSize, colorSide: .white, type: .bishop, gridPosition: .c1),
            
            ChessPieceNode(tileSize: tileSize, colorSide: .white, type: .queen, gridPosition: .d1),
            ChessPieceNode(tileSize: tileSize, colorSide: .white, type: .king, gridPosition: .e1),
            
            ChessPieceNode(tileSize: tileSize, colorSide: .white, type: .bishop, gridPosition: .f1),
            ChessPieceNode(tileSize: tileSize, colorSide: .white, type: .knight, gridPosition: .g1),
            ChessPieceNode(tileSize: tileSize, colorSide: .white, type: .rook, gridPosition: .h1),
            
            // Init black pieces
            ChessPieceNode(tileSize: tileSize, colorSide: .black, type: .rook, gridPosition: .a8),
            ChessPieceNode(tileSize: tileSize, colorSide: .black, type: .knight, gridPosition: .b8),
            ChessPieceNode(tileSize: tileSize, colorSide: .black, type: .bishop, gridPosition: .c8),
            
            ChessPieceNode(tileSize: tileSize, colorSide: .black, type: .queen, gridPosition: .d8),
            ChessPieceNode(tileSize: tileSize, colorSide: .black, type: .king, gridPosition: .e8),
            
            ChessPieceNode(tileSize: tileSize, colorSide: .black, type: .bishop, gridPosition: .f8),
            ChessPieceNode(tileSize: tileSize, colorSide: .black, type: .knight, gridPosition: .g8),
            ChessPieceNode(tileSize: tileSize, colorSide: .black, type: .rook, gridPosition: .h8)
        ]
        
        // Init white and black pawns
        for column in 0..<8 {
            pieceNodes.append(contentsOf: [
            ChessPieceNode(tileSize: tileSize, colorSide: .white, type: .pawn, gridPosition: GridPosition(rawValue: column + 8)!),
            ChessPieceNode(tileSize: tileSize, colorSide: .black, type: .pawn, gridPosition: GridPosition(rawValue: column + 48)!)])
        }
        
        for pieceNode in pieceNodes {
            if let pieceNode = pieceNode {
                self.chessPieceNodes.append(pieceNode)
                self.addChild(pieceNode)
            }
        }
    }
    
    // MARK: - Play
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch : UITouch = touches.first else { return }
        let location : CGPoint = touch.location(in: self)
        
        if let selectedPieceNode = self.selectedNode {
            
            guard let gridDestination : GridPosition = self.positionForPoint(location) else {
                print("Grid destination unfound")
                selectedPieceNode.desablePieceSelected()
                self.selectedNode = nil
                return
            }
            
            if self.pieceCanMove(to: gridDestination, with: selectedPieceNode) {
                self.move(to: gridDestination, with: selectedPieceNode)
                
                // Update UI if needed
                if self.swappingChessChoice == .bothSides { self.turnPiecesAtEachTurn() }
            }
            selectedPieceNode.desablePieceSelected()
            self.selectedNode = nil
            if !self.toucheHasBeenUsed {self.toucheHasBeenUsed = true}
            
        } else {
            if let touchedNode = self.atPoint(location) as? ChessPieceNode {
                if touchedNode.name == "ChessPiece" && !pieceToPromute {
                    if self.playerCanPlay(pieceNode: touchedNode) {
                        touchedNode.showPieceSelected()
                        self.selectedNode = touchedNode
                    } else {
                        TextToSpeech.shared.wrongTurn(actualTurn: isWhiteTurn ? "white" : "black")
                    }
                }
            }
        }
    }
    
    private func playWithVoice(start: GridPosition, end: GridPosition, vocalFeedback: Bool) -> Bool {
        self.selectedNode = nil
        if let pieceToMove = self.getPieceNode(at: start) {
            if self.playerCanPlay(pieceNode: pieceToMove) {
                
                guard let pieceNode = self.getPieceNode(at: start) else {
                    return false
                }
                pieceNode.desablePieceSelected()
                
                if self.pieceCanMove(to: end, with: pieceToMove) {
                    if vocalFeedback { TextToSpeech.shared.speekMove(start: String(describing: start), end: String(describing: end)) }
                    
                    self.move(to: end, with: pieceNode)
                    if !self.speechRecognitionHasBeenUsed {self.speechRecognitionHasBeenUsed = true}
                    
                    return true
                }
            } else {
                TextToSpeech.shared.wrongTurn(actualTurn: isWhiteTurn ? "white" : "black")
                return true
            }
        }
        return false
    }
    
    private func move(to end: GridPosition, with pieceNode: ChessPieceNode) {
        
        self.piecesMovements.append(PieceMovements(startGridPosition: pieceNode.gridPosition, endGridPosition: end, pieceEaten: self.getPieceNode(at: end)))
        
        self.removePieceAt(gridPosition: end)
        pieceNode.updatePositionWithEffect(gridPosition: end)
        pieceNode.increaseMoveCount()
        self.isWhiteTurn.toggle()
    }
    
    public func checkVoiceCommand(text: String, vocalFeedback: Bool) -> Bool {
        
        let input : String = text.lowercased()
        
        let pattern = #".*move (.+?) to (.+).*"#
        
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: input.utf16.count)
        
        if let match = regex?.firstMatch(in: input, options: [], range: range) {
            if let position1Range = Range(match.range(at: 1), in: input),
               let position2Range = Range(match.range(at: 2), in: input) {
                var position1 = String(input[position1Range])
                var position2 = String(input[position2Range])
                
                if position1 == "before" {position1 = "b4"} else if position2 == "before" {position2 = "b4"}
                
                guard let gridPosition1 = GridPosition(from: position1), let gridPosition2 = GridPosition(from: position2) else {
                    return false
                }
                
                print("VOICE : Move piece from \(position1) to \(position2)")
                return self.playWithVoice(start: gridPosition1, end: gridPosition2, vocalFeedback: vocalFeedback)
            }
        }
        return false
    }
    
    public func goBack() {
        if !piecesMovements.isEmpty {
            let pieceMovement = self.piecesMovements.removeLast()
            
            if let pieceNode = self.getPieceNode(at: pieceMovement.endGridPosition) {
                pieceNode.updatePositionWithEffect(gridPosition: pieceMovement.startGridPosition)
                pieceNode.moveCount -= 1
                if let pieceEaten = pieceMovement.pieceEaten {
                    self.addChild(pieceEaten)
                    self.chessPieceNodes.append(pieceEaten)
                }
                
                if !self.backButtonHasBeenUsed {self.backButtonHasBeenUsed = true}
                self.isWhiteTurn.toggle()
            }
            
        }
    }
    
    // MARK: - Update node properties
    
    public func turnPiecesAtEachTurn() {
        if isWhiteTurn {
            chessPieceNodes.forEach({$0.zRotation = 0})
        } else {
            chessPieceNodes.forEach({$0.zRotation = .pi})
        }
    }
    
    public func turnOnlyBlackPieces() {
        for pieceNode in chessPieceNodes {
            if pieceNode.colorSide == .black {
                pieceNode.zRotation = .pi
            } else {
                pieceNode.zRotation = 0
            }
        }
    }
    
    public func resetPiecesRotation() {
        for pieceNode in chessPieceNodes {
            pieceNode.zRotation = 0
        }
    }
    
    private func removePieceAt(gridPosition: GridPosition) {
        if let pieceNodeToRemove = self.getPieceNode(at: gridPosition) {
            self.chessPieceNodes.removeAll(where: {$0 == pieceNodeToRemove})
            self.removeChildren(in: [pieceNodeToRemove])
        }
    }
    
    // MARK: - Check legal movements
    
    private func pieceCanMove(to end: GridPosition, with pieceNode: ChessPieceNode) -> Bool {
        
        let start : GridPosition = pieceNode.gridPosition
        let directionMove : Direction = self.getDirectionOfMove(from: start, to: end)
        let colorFactor : Int = (pieceNode.colorSide == .white) ? 1 : -1
        let locationOfSameTeam : [GridPosition] = (pieceNode.colorSide == .white) ? self.whitePositions : self.blackPositions
        
        if start == end {
            return false
        } else {
            switch (pieceNode.type) {
            case .pawn :
                return pawnMoveIsValid(end: end, pieceNode: pieceNode, direction: directionMove, colorFactor: colorFactor, locationOfSameTeam: locationOfSameTeam)
            case .queen:
                return queenMoveIsValid(end: end, pieceNode: pieceNode, direction: directionMove, colorFactor: colorFactor, locationOfSameTeam: locationOfSameTeam)
            case .king:
                return kingMoveIsValid(end: end, pieceNode: pieceNode, direction: directionMove, colorFactor: colorFactor, locationOfSameTeam: locationOfSameTeam)
            case .knight:
                return knightMoveIsValid(end: end, pieceNode: pieceNode, direction: directionMove, colorFactor: colorFactor, locationOfSameTeam: locationOfSameTeam)
            case .bishop:
                return bishopMoveIsValid(end: end, pieceNode: pieceNode, direction: directionMove, colorFactor: colorFactor, locationOfSameTeam: locationOfSameTeam)
            case .rook:
                return rookMoveIsValid(end: end, pieceNode: pieceNode, direction: directionMove, colorFactor: colorFactor, locationOfSameTeam: locationOfSameTeam)
            }
        }
    }
    
    // Pawn - - - -
    private func checkPawnPromotion(gridPosition: GridPosition, pieceNode: ChessPieceNode) {
        if (gridPosition.rawValue >= 56 && pieceNode.colorSide == .white) || (gridPosition.rawValue <= 7 && pieceNode.colorSide == .black) {
            self.pieceToPromute = true
        }
    }
    
    public func promotePawn(to type: PieceType) {
        for pieceNode in chessPieceNodes {
            if (pieceNode.gridPosition.rawValue >= 56 && pieceNode.colorSide == .white) || (pieceNode.gridPosition.rawValue <= 7 && pieceNode.colorSide == .black) {
                
                pieceNode.texture = TextureManager.shared.getPieceTextureOf(type)
                pieceNode.type = type
                
                self.pieceToPromute = false
            }
        }
    }
    
    private func pawnMoveIsValid(end: GridPosition, pieceNode: ChessPieceNode, direction: Direction, colorFactor: Int, locationOfSameTeam: [GridPosition]) -> Bool {
        
        let start : GridPosition = pieceNode.gridPosition
        
        let moveCountForward : Int = (end.rawValue - start.rawValue) / 8
        let moveOneLeftCaseDiagonally : Bool = (end.rawValue == (start.rawValue + (7 * colorFactor)))
        let moveOneRightCaseDiagonally : Bool = (end.rawValue == (start.rawValue + (9 * colorFactor)))
        let onCaseOnPassant : Bool = (start.rawValue >= 24 && start.rawValue <= 39)
        
        if direction == .vertical && (moveCountForward * colorFactor) > 0 {
            if (abs(moveCountForward) <= 2 && pieceNode.moveCount == 0) || abs(moveCountForward) == 1 {
                if self.getPieceOnVerticalPath(to: end, from: start) == nil {
                    self.checkPawnPromotion(gridPosition: end, pieceNode: pieceNode)
                    return true
                }
            }
        } else if direction == .diagonalLeft && moveOneLeftCaseDiagonally {
            if let result = self.getPieceOnDiagonally(at: (1 * colorFactor), from: start, isGoingToLeftSide: true) {
                return (!locationOfSameTeam.contains([end]) && result.type != .king)
            } else if let result = self.getPieceOnHorizontal(at: (-1 * colorFactor), from: start) {
                if result.type == .pawn && result.colorSide != pieceNode.colorSide && result.moveCount == 1 && onCaseOnPassant {
                    self.removePieceAt(gridPosition: result.gridPosition)
                    self.checkPawnPromotion(gridPosition: end, pieceNode: pieceNode)
                    return true
                }
            }
        } else if direction == .diagonalRight && moveOneRightCaseDiagonally {
            if let result = self.getPieceOnDiagonally(at: (1 * colorFactor), from: start, isGoingToLeftSide: false) {
                return (!locationOfSameTeam.contains([end]) && result.type != .king)
            } else if let result = self.getPieceOnHorizontal(at: (1 * colorFactor), from: start) {
                if result.type == .pawn && result.colorSide != pieceNode.colorSide && result.moveCount == 1 {
                    self.removePieceAt(gridPosition: result.gridPosition)
                    self.checkPawnPromotion(gridPosition: end, pieceNode: pieceNode)
                    return true
                }
            }
        }
        return false
    }
    
    // Rook - - - -
    private func rookMoveIsValid(end: GridPosition, pieceNode: ChessPieceNode, direction: Direction, colorFactor: Int, locationOfSameTeam: [GridPosition]) -> Bool {
        
        let start : GridPosition = pieceNode.gridPosition
        
        if direction == .vertical {
            guard let result = self.getPieceOnVerticalPath(to: end, from: start) else {
                return true
            }
            return (result.gridPosition == end && !locationOfSameTeam.contains([end]) && result.type != .king)
            
        } else if direction == .horizontal {
            guard let result = self.getPieceOnHorizontalPath(to: end, from: start) else {
                return true
            }
            return (result.gridPosition == end && !locationOfSameTeam.contains([end]) && result.type != .king)
            
        }
        return false
    }
    
    // Knight - - - -
    private func knightMoveIsValid(end: GridPosition, pieceNode: ChessPieceNode, direction: Direction, colorFactor: Int, locationOfSameTeam: [GridPosition]) -> Bool {
        
        if direction == .knightMove {
            guard let result = self.getPieceNode(at: end) else {
                return true
            }
            return (!locationOfSameTeam.contains([end]) && result.type != .king)
            
        }
        return false
    }
    
    // Bishop - - - -
    private func bishopMoveIsValid(end: GridPosition, pieceNode: ChessPieceNode, direction: Direction, colorFactor: Int, locationOfSameTeam: [GridPosition]) -> Bool {
        
        let start : GridPosition = pieceNode.gridPosition
        
        if direction == .diagonalLeft {
            guard let result = self.getPieceOnDiagonallyPath(to: end, from: start, isGoingToLeftSide: true) else {
                return true
            }
            return (result.gridPosition == end && !locationOfSameTeam.contains([end]) && result.type != .king)
            
        } else if direction == .diagonalRight {
            guard let result = self.getPieceOnDiagonallyPath(to: end, from: start, isGoingToLeftSide: false) else {
                return true
            }
            return (result.gridPosition == end && !locationOfSameTeam.contains([end]) && result.type != .king)
            
        }
        return false
    }
    
    // Queen - - - -
    private func queenMoveIsValid(end: GridPosition, pieceNode: ChessPieceNode, direction: Direction, colorFactor: Int, locationOfSameTeam: [GridPosition]) -> Bool {
        
        let start : GridPosition = pieceNode.gridPosition
        
        if direction == .vertical {
            guard let result = self.getPieceOnVerticalPath(to: end, from: start) else {
                return true
            }
            return (result.gridPosition == end && !locationOfSameTeam.contains([end]) && result.type != .king)
            
        } else if direction == .horizontal {
            guard let result = self.getPieceOnHorizontalPath(to: end, from: start) else {
                return true
            }
            return (result.gridPosition == end && !locationOfSameTeam.contains([end]) && result.type != .king)
            
        } else if direction == .diagonalLeft {
            guard let result = self.getPieceOnDiagonallyPath(to: end, from: start, isGoingToLeftSide: true) else {
                return true
            }
            return (result.gridPosition == end && !locationOfSameTeam.contains([end]) && result.type != .king)
            
        } else if direction == .diagonalRight {
            guard let result = self.getPieceOnDiagonallyPath(to: end, from: start, isGoingToLeftSide: false) else {
                return true
            }
            return (result.gridPosition == end && !locationOfSameTeam.contains([end]) && result.type != .king)
            
        }
        return false
    }
    
    // King - - - -
    private func kingMoveIsValid(end: GridPosition, pieceNode: ChessPieceNode, direction: Direction, colorFactor: Int, locationOfSameTeam: [GridPosition]) -> Bool {
        
        let start : GridPosition = pieceNode.gridPosition
        
        let moveOnlyOneCaseVertical : Bool = (abs((end.rawValue - start.rawValue) / 8) == 1)
        let moveOnlyOneCaseHorizontal : Bool = (abs(end.rawValue - start.rawValue) == 1)
        let moveOnlyTwoCaseOnLeft : Bool = ((end.rawValue - start.rawValue) == -2)
        let moveOnlyTwoCaseOnRight : Bool = ((end.rawValue - start.rawValue) == 2)
        let moveOnlyOneLeftCaseDiagonally : Bool = (abs((end.rawValue - start.rawValue)/7) == 1)
        let moveOnlyOneRightCaseDiagonally : Bool = (abs((end.rawValue - start.rawValue)/9) == 1)
        
        if direction == .vertical && moveOnlyOneCaseVertical {
            guard let result = self.getPieceOnVerticalPath(to: end, from: start) else {
                return true
            }
            return (result.gridPosition == end && !locationOfSameTeam.contains([end]) && result.type != .king)
            
        } else if direction == .horizontal {
            
            if pieceNode.moveCount == 0 && moveOnlyTwoCaseOnLeft && pieceNode.colorSide == .white {
                if let pieceNodeFound = self.getPieceNode(at: .a1) {
                    if pieceNodeFound.type == .rook && self.getPieceNode(at: .b1) == nil && self.getPieceNode(at: .c1) == nil && self.getPieceNode(at: .d1) == nil {
                        let b1InDanger : Bool = self.kingIsCheck(at: .b1, kingNode: pieceNode)
                        let c1InDanger : Bool = self.kingIsCheck(at: .c1, kingNode: pieceNode)
                        let d1InDanger : Bool = self.kingIsCheck(at: .d1, kingNode: pieceNode)
                        let e1InDanger : Bool = self.kingIsCheck(at: .e1, kingNode: pieceNode)
                        if !b1InDanger && !c1InDanger && !d1InDanger && !e1InDanger {
                            pieceNodeFound.increaseMoveCount()
                            pieceNodeFound.updatePositionWithEffect(gridPosition: .d1)
                            return true
                        }
                    }
                }
            } else if pieceNode.moveCount == 0 && moveOnlyTwoCaseOnRight && pieceNode.colorSide == .white {
                if let pieceNodeFound = self.getPieceNode(at: .h1) {
                    if pieceNodeFound.type == .rook && self.getPieceNode(at: .f1) == nil && self.getPieceNode(at: .g1) == nil {
                        let e1InDanger : Bool = self.kingIsCheck(at: .e1, kingNode: pieceNode)
                        let f1InDanger : Bool = self.kingIsCheck(at: .f1, kingNode: pieceNode)
                        let g1InDanger : Bool = self.kingIsCheck(at: .g1, kingNode: pieceNode)
                        if !e1InDanger && !f1InDanger && !g1InDanger {
                            pieceNodeFound.increaseMoveCount()
                            pieceNodeFound.updatePositionWithEffect(gridPosition: .f1)
                            return true
                        }
                    }
                }
            } else if pieceNode.moveCount == 0 && moveOnlyTwoCaseOnLeft && pieceNode.colorSide == .black {
                if let pieceNodeFound = self.getPieceNode(at: .a8) {
                    if pieceNodeFound.type == .rook && self.getPieceNode(at: .b8) == nil && self.getPieceNode(at: .c8) == nil && self.getPieceNode(at: .d8) == nil {
                        let b8InDanger : Bool = self.kingIsCheck(at: .b8, kingNode: pieceNodeFound)
                        let c8InDanger : Bool = self.kingIsCheck(at: .c8, kingNode: pieceNodeFound)
                        let d8InDanger : Bool = self.kingIsCheck(at: .d8, kingNode: pieceNodeFound)
                        let e8InDanger : Bool = self.kingIsCheck(at: .e8, kingNode: pieceNodeFound)
                        if !b8InDanger && !c8InDanger && !d8InDanger && !e8InDanger {
                            pieceNodeFound.increaseMoveCount()
                            pieceNodeFound.updatePositionWithEffect(gridPosition: .d8)
                            return true
                        }
                    }
                }
            } else if pieceNode.moveCount == 0 && moveOnlyTwoCaseOnRight && pieceNode.colorSide == .black {
                if let pieceNodeFound = self.getPieceNode(at: .h8) {
                    if pieceNodeFound.type == .rook && self.getPieceNode(at: .f8) == nil && self.getPieceNode(at: .g8) == nil {
                        let e8InDanger : Bool = self.kingIsCheck(at: .e8, kingNode: pieceNodeFound)
                        let f8InDanger : Bool = self.kingIsCheck(at: .f8, kingNode: pieceNodeFound)
                        let g8InDanger : Bool = self.kingIsCheck(at: .g8, kingNode: pieceNodeFound)
                        if !e8InDanger && !f8InDanger && !g8InDanger {
                            pieceNodeFound.increaseMoveCount()
                            pieceNodeFound.updatePositionWithEffect(gridPosition: .f8)
                            return true
                        }
                    }
                }
            } else if moveOnlyOneCaseHorizontal {
                guard let result = self.getPieceOnHorizontalPath(to: end, from: start) else {
                    return true
                }
                return (result.gridPosition == end && !locationOfSameTeam.contains([end]) && result.type != .king)
            }
            
        } else if direction == .diagonalLeft && moveOnlyOneLeftCaseDiagonally {
            guard let result = self.getPieceOnDiagonallyPath(to: end, from: start, isGoingToLeftSide: true) else {
                return true
            }
            return (result.gridPosition == end && !locationOfSameTeam.contains([end]) && result.type != .king)
            
        } else if direction == .diagonalRight && moveOnlyOneRightCaseDiagonally {
            guard let result = self.getPieceOnDiagonallyPath(to: end, from: start, isGoingToLeftSide: false) else {
                return true
            }
            return (result.gridPosition == end && !locationOfSameTeam.contains([end]) && result.type != .king)
            
        }
        return false
    }
    
    private func kingIsCheck(at gridPosition: GridPosition, kingNode: ChessPieceNode) -> Bool {
        
        let dangerousTypeVerticallyAndHoritontally : [PieceType] = [.rook, .queen]
        let dangerousTypeDiagonally : [PieceType] = [.bishop, .queen]
        
        let (row, column) : (Int, Int) = gridPosition.rowAndColumn
        
        let array : [Int] = [1,2,3,4,5,6,7]
        
        let positiveRowsOrderArray = array.dropLast(row)
        let negativeRowsOrderArray = array.dropLast(7 - row).map({-$0})
        let positiveColumnsOrderArray = array.dropLast(column)
        let negativeColumnsOrderArray = array.dropLast(7 - column).map({-$0})
        
        var forwardIsNotChecked : Bool = true
        var backwardIsNotChecked : Bool = true
        
        var leftIsNotChecked : Bool = true
        var rightIsNotChecked : Bool = true
        
        var forwardDiagonallyLeftIsNotChecked : Bool = true
        var forwardDiagonallyRightIsNotChecked : Bool = true
        var backwardDiagonallyLeftIsNotChecked : Bool = true
        var backwardDiagonallyRightIsNotChecked : Bool = true
        
        for caseToCheck in positiveColumnsOrderArray {
            
            if rightIsNotChecked {
                if let pieceNodeFound = self.getPieceOnHorizontal(at: caseToCheck, from: gridPosition) {
                    if pieceNodeFound.colorSide != kingNode.colorSide {
                        if dangerousTypeVerticallyAndHoritontally.contains(pieceNodeFound.type) {
                            return true
                        } else {
                            rightIsNotChecked = false
                        }
                    } else {
                        rightIsNotChecked = false
                    }
                }
            }
            
            if forwardDiagonallyRightIsNotChecked {
                if let pieceNodeFound = self.getPieceOnDiagonally(at: caseToCheck, from: gridPosition, isGoingToLeftSide: false) {
                    if pieceNodeFound.colorSide != kingNode.colorSide {
                        if dangerousTypeDiagonally.contains(pieceNodeFound.type) {
                            return true
                        } else if caseToCheck == 1 && pieceNodeFound.type == .pawn && kingNode.colorSide == .white {
                            return true
                        } else {
                            forwardDiagonallyRightIsNotChecked = false
                        }
                    } else {
                        forwardDiagonallyRightIsNotChecked = false
                    }
                }
            }
            
            if backwardDiagonallyRightIsNotChecked {
                if let pieceNodeFound = self.getPieceOnDiagonally(at: -caseToCheck, from: gridPosition, isGoingToLeftSide: true) {
                    if pieceNodeFound.colorSide != kingNode.colorSide {
                        if dangerousTypeDiagonally.contains(pieceNodeFound.type) {
                            return true
                        } else if caseToCheck == 1 && pieceNodeFound.type == .pawn && kingNode.colorSide == .black {
                            return true
                        } else {
                            backwardDiagonallyRightIsNotChecked = false
                        }
                    } else {
                        backwardDiagonallyRightIsNotChecked = false
                    }
                }
            }
        }
        
        for caseToCheck in negativeColumnsOrderArray {
            
            if leftIsNotChecked {
                if let pieceNodeFound = self.getPieceOnHorizontal(at: caseToCheck, from: gridPosition) {
                    if pieceNodeFound.colorSide != kingNode.colorSide {
                        if dangerousTypeVerticallyAndHoritontally.contains(pieceNodeFound.type) {
                            return true
                        } else {
                            leftIsNotChecked = false
                        }
                    } else {
                        leftIsNotChecked = false
                    }
                }
            }
            
            if forwardDiagonallyLeftIsNotChecked {
                if let pieceNodeFound = self.getPieceOnDiagonally(at: -caseToCheck, from: gridPosition, isGoingToLeftSide: true) {
                    if pieceNodeFound.colorSide != kingNode.colorSide {
                        if dangerousTypeDiagonally.contains(pieceNodeFound.type) {
                            return true
                        } else if caseToCheck == -1 && pieceNodeFound.type == .pawn && kingNode.colorSide == .white {
                            return true
                        } else {
                            forwardDiagonallyLeftIsNotChecked = false
                        }
                    } else {
                        forwardDiagonallyLeftIsNotChecked = false
                    }
                }
            }
            
            if backwardDiagonallyLeftIsNotChecked {
                if let pieceNodeFound = self.getPieceOnDiagonally(at: caseToCheck, from: gridPosition, isGoingToLeftSide: false) {
                    if pieceNodeFound.colorSide != kingNode.colorSide {
                        if dangerousTypeDiagonally.contains(pieceNodeFound.type) {
                            return true
                        } else if caseToCheck == -1 && pieceNodeFound.type == .pawn && kingNode.colorSide == .black {
                            return true
                        } else {
                            backwardDiagonallyLeftIsNotChecked = false
                        }
                    } else {
                        backwardDiagonallyLeftIsNotChecked = false
                    }
                }
            }
            
        }
        
        for caseToCheck in positiveRowsOrderArray {
            
            if forwardIsNotChecked {
                if let pieceNodeFound = self.getPieceOnVertical(at: caseToCheck, from: gridPosition) {
                    if pieceNodeFound.colorSide != kingNode.colorSide {
                        if dangerousTypeVerticallyAndHoritontally.contains(pieceNodeFound.type) {
                            return true
                        } else {
                            forwardIsNotChecked = false
                        }
                    } else {
                        forwardIsNotChecked = false
                    }
                }
            }

        }
        
        for caseToCheck in negativeRowsOrderArray {
            
            if backwardIsNotChecked {
                if let pieceNodeFound = self.getPieceOnVertical(at: caseToCheck, from: gridPosition) {
                    if pieceNodeFound.colorSide != kingNode.colorSide {
                        if dangerousTypeVerticallyAndHoritontally.contains(pieceNodeFound.type) {
                            return true
                        } else {
                            backwardIsNotChecked = false
                        }
                    } else {
                        backwardIsNotChecked = false
                    }
                }
            }
    
        }
        
        // Check knight
        for rowToCheck in [-1,-2,1,2] {
            for columnToCheck in [-1,-2,1,2] {
                let rowDiff = abs(gridPosition.rawValue / 8 - (gridPosition.rawValue + rowToCheck*8) / 8)
                let colDiff = abs(gridPosition.rawValue % 8 - (gridPosition.rawValue + columnToCheck) % 8)
                if (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2) {
                    let positionToCheck : Int = gridPosition.rawValue + columnToCheck + rowToCheck*8
                    if destinationIsOnGride(at: positionToCheck) {
                        if let pieceDetected = self.getPieceNode(at: GridPosition(rawValue: positionToCheck)!) {
                            if pieceDetected.colorSide != kingNode.colorSide && pieceDetected.type == .knight {
                                return true
                            }
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    // MARK: - Get information on the board
    
    // Get on a tile
    private func getDirectionOfMove(from startPosition: GridPosition, to endPosition: GridPosition) -> Direction {
        
        let startIndex = startPosition.rawValue
        let endIndex = endPosition.rawValue
        
        if startIndex / 8 == endIndex / 8 {
            return .horizontal
        } else if startIndex % 8 == endIndex % 8 {
            return .vertical
        }
        
        let rowDiff = abs(startIndex / 8 - endIndex / 8)
        let colDiff = abs(startIndex % 8 - endIndex % 8)
        
        if (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2) {
            return .knightMove
        } else if rowDiff == colDiff {
            if (startIndex % 8 < endIndex % 8 && startIndex / 8 < endIndex / 8) ||
                (startIndex % 8 > endIndex % 8 && startIndex / 8 > endIndex / 8) {
                return .diagonalRight
            } else if (startIndex % 8 > endIndex % 8 && startIndex / 8 < endIndex / 8) ||
                        (startIndex % 8 < endIndex % 8 && startIndex / 8 > endIndex / 8) {
                return .diagonalLeft
            }
        }
        
        return .invalid
    }
    
    private func getPieceOnVertical(at distance: Int, from startPosition: GridPosition ) -> ChessPieceNode? {
        let calculatedRawPosition : Int = startPosition.rawValue + (distance * 8)
        
        if destinationIsOnGride(at: calculatedRawPosition) {
            let calculatedPosition = GridPosition(rawValue: calculatedRawPosition)!
            return self.getPieceNode(at: calculatedPosition)
        }
        return nil
    }
    
    private func getPieceOnHorizontal(at distance: Int, from startPosition: GridPosition ) -> ChessPieceNode? {
        let calculatedRawPosition : Int = startPosition.rawValue + distance
        
        if destinationIsOnGride(at: calculatedRawPosition) {
            let calculatedPosition = GridPosition(rawValue: calculatedRawPosition)!
            return self.getPieceNode(at: calculatedPosition)
        }
        return nil
    }
    
    private func getPieceOnDiagonally(at distance: Int, from startPosition: GridPosition, isGoingToLeftSide: Bool) -> ChessPieceNode? {
        let multiplierFactor : Int = isGoingToLeftSide ? 7 : 9
        let calculatedRawPosition : Int = startPosition.rawValue + (distance * multiplierFactor)
        
        if destinationIsOnGride(at: calculatedRawPosition) {
            let calculatedPosition = GridPosition(rawValue: calculatedRawPosition)!
            return self.getPieceNode(at: calculatedPosition)
        }
        return nil
    }
    
    // Get on a path
    private func getPieceOnVerticalPath(to endPosition: GridPosition, from startPosition: GridPosition) -> ChessPieceNode? {
        let needToMoveCount : Int = (endPosition.rawValue - startPosition.rawValue)/8
        var checkOrder : [Int] {
            if needToMoveCount > 0 {
                return Array(1...needToMoveCount)
            } else if needToMoveCount < 0 {
                return Array(needToMoveCount...(-1)).reversed()
            } else {
                return []
            }
        }
        
        for moveNumber in checkOrder {
            if let result = getPieceOnVertical(at: moveNumber, from: startPosition) {
                return result
            }
        }
        return nil
    }
    
    private func getPieceOnHorizontalPath(to endPosition: GridPosition, from startPosition: GridPosition) -> ChessPieceNode? {
        let needToMoveCount : Int = endPosition.rawValue - startPosition.rawValue
        var checkOrder : [Int] {
            if needToMoveCount > 0 {
                return Array(1...needToMoveCount)
            } else if needToMoveCount < 0 {
                return Array(needToMoveCount...(-1)).reversed()
            } else {
                return []
            }
        }
        
        for moveNumber in checkOrder {
            if let result = getPieceOnHorizontal(at: moveNumber, from: startPosition) {
                return result
            }
        }
        return nil
    }
    
    private func getPieceOnDiagonallyPath(to endPosition: GridPosition, from startPosition: GridPosition, isGoingToLeftSide: Bool) -> ChessPieceNode? {
        let divisionFactor : Int = isGoingToLeftSide ? 7 : 9
        let needToMoveCount : Int = (endPosition.rawValue - startPosition.rawValue)/divisionFactor
        var checkOrder : [Int] {
            if needToMoveCount > 0 {
                return Array(1...needToMoveCount)
            } else if needToMoveCount < 0 {
                return Array(needToMoveCount...(-1)).reversed()
            } else {
                return []
            }
        }

        for moveNumber in checkOrder {
            if let result = getPieceOnDiagonally(at: moveNumber, from: startPosition, isGoingToLeftSide: isGoingToLeftSide) {
                return result
            }
        }
        return nil
    }
    
    // MARK: - Useful tools
    
    private func getPieceNode(at gridPosition: GridPosition) -> ChessPieceNode? {
        return chessPieceNodes.first(where: {$0.gridPosition == gridPosition})
    }
    
    private func destinationIsOnGride(at rawPosition: Int) -> Bool {
        return (rawPosition >= 0 && rawPosition <= 63)
    }
    
    private func playerCanPlay(pieceNode: ChessPieceNode) -> Bool {
        return (pieceNode.colorSide == .white && self.isWhiteTurn) || (pieceNode.colorSide == .black && !self.isWhiteTurn)
    }
    
    private func positionForPoint(_ location: CGPoint) -> GridPosition? {
        
        let row = Int((location.y - self.board.tileSize/2) / self.board.tileSize)
        let column = Int((location.x - self.board.tileSize/2) / self.board.tileSize)

        // Vérifiez que les coordonnées sont à l'intérieur des limites du tableau de 8x8
        if row >= 0, row < 8, column >= 0, column < 8 {
            let positionIndex = row * 8 + column
            return GridPosition(rawValue: positionIndex)
        } else {
            return nil
        }
    }
}
