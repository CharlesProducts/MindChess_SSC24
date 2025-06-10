//
//  SettingsPage.swift
//  MindChess
//
//  Created by Charles de PLUVIÉ on 21/02/2024.
//

import SwiftUI
import AVFoundation

public enum SwappingChessChoice : Hashable {
    case solo, bothSides, onlyOneSide
}

struct SettingsPage: View {
    
    public let width : CGFloat
    public let height : CGFloat
    
    @Binding var showSettingsPage : Bool
    @Binding var showTutorial : Bool
    
    @ObservedObject var model : ChessViewModel
    
    var body: some View {
        VStack() {
            
            HStack {
                ZStack {
                    Text("Settings page")
                        .font(.largeTitle.bold())
                        .hAlign(.center)
                    
                    Button {
                        withAnimation(.easeInOut) {
                            self.showSettingsPage = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: self.width/20, height: self.width/20)
                            .foregroundStyle(Color.black.opacity(0.8))
                            .hAlign(.trailing)
                    }
                }
                
            }
            
            Text("Swapping chess pieces")
                .font(.system(size: 18).bold())
                .hAlign(.leading)
                .padding(.top, 20)
            
            Picker("Swapping chess pieces", selection: self.$model.chessGame.swappingChessChoice) {
                Text("Solo").tag(SwappingChessChoice.solo)
                Text("Both sides").tag(SwappingChessChoice.bothSides)
                Text("Only one side").tag(SwappingChessChoice.onlyOneSide)
            }
            .pickerStyle(.segmented)
            
            HStack(alignment: .center) {
                Text("Voice selection")
                    .font(.system(size: 18).bold())
                    .hAlign(.leading)
                
                Picker("Voice selection", selection: self.$model.textToSpeech.voiceIdentifier) {
                    ForEach(AVSpeechSynthesisVoice.speechVoices(), id:\.identifier) { voice in
                        if voice.language == "en-US" {
                            Text("\(voice.name)").tag(voice.identifier)
                        }
                    }
                }
                .pickerStyle(.menu)
                .tint(Color.black.opacity(0.8))
                
            }
            .padding(.top, 20)
            
            HStack(alignment: .center) {
                Text("Show the tutorial")
                    .font(.system(size: 18).bold())
                    .hAlign(.leading)
                
                Toggle("", isOn: self.$showTutorial)
                
            }
            .padding(.top, 20)
            
            self.creditsPage()
            

            Button {
                self.model.chessGame.restartGame()
            } label: {
                RoundedRectangle(cornerRadius: 20.0)
                    .frame(width: self.width/1.3, height: self.height/10)
                    .foregroundStyle(Color.white)
                    .overlay {
                        Text("Reset chess game")
                            .font(.title2.bold())
                            .foregroundStyle(Color(UIColor.blackSideColor))
                    }
            }
            .padding(.bottom, 20)
            .vAlign(.bottom)
            
        }
        .padding()
        .frame(width: self.width, height: self.height)
        .background {
            RoundedRectangle(cornerRadius: 25.0)
                .foregroundStyle(.ultraThinMaterial)
        }
    }
    
    @ViewBuilder
    private func creditsPage() -> some View {
        VStack {
            
            Divider()
            
            Text("Credits")
                .font(.system(size: 18).bold())
                .hAlign(.leading)
            
            HStack {
                Text("Images of chess pieces :")
                
                Spacer()
                
                Text("Made by riajulislam from flaticon.com")
            }
            .padding(.top, 5)
            
            Divider()
        }
    }
}
