//
//  ContentView.swift
//  MindChess
//
//  Created by Charles de PLUVIÉ on 23/01/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            GeometryReader { proxy in
                ChessView(screenSize: proxy.size, model: ChessViewModel(chessGame: ChessScene(sceneSize: proxy.size)))
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.light)
    }
}

#Preview {
    ContentView()
}
