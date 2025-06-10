//
//  PieceToPromuteChoiceView.swift
//  MindChess
//
//  Created by Charles de PLUVIÉ on 20/02/2024.
//

import SwiftUI

struct PieceToPromuteChoiceView: View {
    
    public let width : CGFloat
    public let height : CGFloat
    
    @ObservedObject var model : ChessViewModel
    
    public var pieceAvailable : [PieceType] = [.queen, .knight, .bishop, .rook]
    
    var body: some View {
        VStack (spacing: 5) {
            
            Text("Promotion")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.white)
                .shadow(radius: 20)
                .padding(.top, 10)
            
            HStack {
                ForEach(pieceAvailable, id: \.rawValue) { pieceType in
                    Button {
                        model.chessGame.promotePawn(to: pieceType)
                    } label: {
                        Image(uiImage: UIImage(named: pieceType.rawValue)!)
                            .resizable()
                            .frame(width: height/1.5, height: height/1.5)
                        
                    }
                    .hAlign(.center)
                }
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal, 20)
        .frame(width: width, height: height)
        .background {
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundStyle(.ultraThinMaterial)
        }
        .shadow(radius: 10)
    }
}
