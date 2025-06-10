//
//  Introduction.swift
//  MindChess
//
//  Created by Charles de PLUVIÉ on 22/02/2024.
//

import SwiftUI

struct Introduction: View {
    
    @Binding var showIntroduction : Bool
    @State private var currentIndexCard : Int = 0
    
    private func nextCard() {
        if self.currentIndexCard >= 2 {
            self.showIntroduction = false
        }
        self.currentIndexCard += 1
    }
    
    var body: some View {
        VStack {
            if self.currentIndexCard == 0 {
                self.welcomeCard()
            } else if self.currentIndexCard == 1 {
                self.objectiveCard()
            } else {
                self.featuresCard()
            }
        }
        .hAlign(.center)
        .vAlign(.center)
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func welcomeCard() -> some View {
        VStack(spacing: 30) {
            VStack(spacing: 40) {
                Text("♟️")
                    .font(.system(size: 100))
                    .rotationEffect(Angle(degrees: 10.0))
                
                Text("Welcome on MIND CHESS")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                
                if #unavailable(iOS 17) {
                    Text("⚠️ iPadOS 17 is necessary to use voice recognition, update your device to have the best user experience.")
                        .multilineTextAlignment(.center)
                }
                
            }
            .vAlign(.center)
            .padding(.bottom, 30)
            
            Text("An application developed by Charles de Pluvié")
                .font(.callout)
                .foregroundStyle(Color.black.opacity(0.7))
            
            Button {
                withAnimation(.smooth) {
                    self.nextCard()
                }
            } label: {
                RoundedRectangle(cornerRadius: 25.0)
                    .frame(height: 70)
                    .overlay {
                        Text("Continue")
                            .font(.title.bold())
                            .foregroundStyle(Color.white)
                    }
            }
        }
        .padding(40)
        .frame(width: 500, height: 700)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
        .shadow(radius: 10)
    }
    
    @ViewBuilder
    private func objectiveCard() -> some View {
        VStack(spacing: 30) {
            
            VStack(spacing: 30) {
                Text("📋")
                    .font(.system(size: 100))
                
                Text("What are the objectives of this application ?")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 30) {
                HStack(spacing: 35) {
                    Text("🧠")
                        .font(.system(size: 40))
                    
                    Text("Work on your memory and concentration")
                        .font(.system(size: 18).bold())
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.leading)
                        .hAlign(.leading)
                }
                
                HStack(spacing: 35) {
                    Text("😎")
                        .font(.system(size: 40))
                    
                    Text("This prototype will aim to allow visually impaired people to also be able to play")
                        .font(.system(size: 18).bold())
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.leading)
                        .hAlign(.leading)
                }
                
                HStack(spacing: 35) {
                    Text("♟️")
                        .font(.system(size: 40))
                    
                    Text("All this while keeping the fun side of playing chess")
                        .font(.system(size: 18).bold())
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.leading)
                        .hAlign(.leading)
                }
            }
            .padding(.horizontal, 32)
            .vAlign(.center)
            
            Button {
                withAnimation(.smooth) {
                    self.nextCard()
                }
            } label: {
                RoundedRectangle(cornerRadius: 25.0)
                    .frame(height: 70)
                    .overlay {
                        Text("Continue")
                            .font(.title.bold())
                            .foregroundStyle(Color.white)
                    }
            }
        }
        .padding(40)
        .frame(width: 500, height: 700)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
        .shadow(radius: 10)
    }
    
    @ViewBuilder
    private func featuresCard() -> some View {
        VStack(spacing: 30) {
            
            VStack(spacing: 20) {
                Text("⚡️")
                    .font(.system(size: 100))
                
                Text("What features does the app offer ?")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                HStack(spacing: 35) {
                    Text("🎙️")
                        .font(.system(size: 40))
                    
                    Text("Speech recognition system to control the game")
                        .font(.system(size: 18).bold())
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.leading)
                        .hAlign(.leading)
                }
                
                HStack(spacing: 35) {
                    Text("🔊")
                        .font(.system(size: 40))
                    
                    Text("Audio feedback to be informed of actions carried out")
                        .font(.system(size: 18).bold())
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.leading)
                        .hAlign(.leading)
                }
                
                HStack(spacing: 35) {
                    Text("♟️")
                        .font(.system(size: 40))
                    
                    Text("A simple and clean board to enjoy the game")
                        .font(.system(size: 18).bold())
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.leading)
                        .hAlign(.leading)
                }
                
                HStack(spacing: 35) {
                    Text("📖")
                        .font(.system(size: 40))
                    
                    Text("A discovery unit to learn methods and advice")
                        .font(.system(size: 18).bold())
                        .foregroundStyle(Color.gray)
                        .multilineTextAlignment(.leading)
                        .hAlign(.leading)
                }
            }
            .padding(.horizontal, 32)
            .vAlign(.center)

            Button {
                withAnimation(.smooth) {
                    self.nextCard()
                }
            } label: {
                RoundedRectangle(cornerRadius: 25.0)
                    .frame(height: 70)
                    .overlay {
                        Text("Continue")
                            .font(.title.bold())
                            .foregroundStyle(Color.white)
                    }
            }
        }
        .padding(40)
        .frame(width: 500, height: 700)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
        .shadow(radius: 10)
    }
}

#Preview {
    Introduction(showIntroduction: .constant(true))
}
