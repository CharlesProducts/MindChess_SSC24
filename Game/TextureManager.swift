//
//  TextureManager.swift
//  MindChess
//
//  Created by Charles de PLUVIÉ on 12/02/2024.
//

import SpriteKit
import SwiftUI

final class TextureManager {
    
    static let shared = TextureManager()
    
    private var textureAtlas : SKTextureAtlas?
    
    public func loadTextures(completion: @escaping (() -> Void)) {
        
        var texturesToLoad = [String : Any]()
        for pieceType in PieceType.allCases {
            if let image = UIImage(named: "\(pieceType.rawValue).png") {
                texturesToLoad[pieceType.rawValue] = image
            }
        }
        
        self.textureAtlas = SKTextureAtlas(dictionary: texturesToLoad)
        completion()
    }
    
    public func getPieceTextureOf(_ pieceType: PieceType) -> SKTexture? {
        return textureAtlas?.textureNamed(pieceType.rawValue)
    }
    
    public func getTextureOf(_ textureName: String) -> SKTexture? {
        return textureAtlas?.textureNamed(textureName)
    }
}
