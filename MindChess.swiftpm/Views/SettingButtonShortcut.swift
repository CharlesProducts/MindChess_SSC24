//
//  SettingButtonShortcut.swift
//  MindChess
//
//  Created by Charles de PLUVIÉ on 20/02/2024.
//

import SwiftUI

struct SettingButtonShortcut: View {
    
    public let width : CGFloat
    public let height : CGFloat
    
    @ObservedObject var model : ChessViewModel
    
    @Binding var showSettingsPage : Bool
    @Binding var showDiscoveryPage : Bool
    
    var body: some View {
        HStack {
            self.learningButton()
            
            Spacer()
            
            self.voiceRecognitionButton()
            self.vocalFeedbackButton()
            self.goBackButton()
            self.settingsPageButton()
        }
    }
    
    @ViewBuilder
    private func learningButton() -> some View {
        Button(action: {
            withAnimation(.easeInOut) {
                self.showSettingsPage = false
                self.showDiscoveryPage = true
            }
        }, label: {
            Circle()
                .frame(width: self.width/2, height: self.width/2)
                .foregroundStyle(Color(UIColor.blackSideColor))
                .overlay {
                    Image(systemName: "sparkles")
                        .resizable()
                        .frame(width: self.width/3.5, height: self.width/3.5)
                        .foregroundStyle(Color(UIColor.whiteSideColor))
                        .padding(.leading, 5)
                }
        })
        
    }
    
    @ViewBuilder
    private func voiceRecognitionButton() -> some View {
        Button(action: {
            if self.model.voiceRecognitionIsActive {
                self.model.stopListening()
            } else {
                self.model.startListening()
            }
            self.model.voiceRecognitionIsActive.toggle()
        }, label: {
            Circle()
                .frame(width: self.width/2, height: self.width/2)
                .foregroundStyle(Color(UIColor.blackSideColor))
                .overlay {
                    Image(systemName: self.model.voiceRecognitionIsActive ? "waveform.badge.mic" : "waveform.slash")
                        .resizable()
                        .frame(width: self.width/3.5, height: self.width/3.5)
                        .foregroundStyle(Color(UIColor.whiteSideColor))
                        .shadow(color: self.model.voiceRecognitionIsActive ? Color.green : Color.red, radius: 10)
                        .padding(.leading, 5)
                }
        })
        
    }
    
    @ViewBuilder
    private func vocalFeedbackButton() -> some View {
        Button(action: {
            self.model.vocalFeedbackIsActive.toggle()
        }, label: {
            Circle()
                .frame(width: self.width/2, height: self.width/2)
                .foregroundStyle(Color(UIColor.blackSideColor))
                .overlay {
                    Image(systemName: self.model.vocalFeedbackIsActive ? "speaker.wave.2" : "speaker.slash")
                        .resizable()
                        .frame(width: self.width/3.5, height: self.width/3.5)
                        .foregroundStyle(Color(UIColor.whiteSideColor))
                        .shadow(color: self.model.vocalFeedbackIsActive ? Color.green : Color.red, radius: 10)
                }
        })
    }
    
    @ViewBuilder
    private func goBackButton() -> some View {
        Button(action: {
            self.model.chessGame.goBack()
        }, label: {
            Circle()
                .frame(width: self.width/2, height: self.width/2)
                .foregroundStyle(Color(UIColor.blackSideColor))
                .overlay {
                    Image(systemName: "arrow.uturn.backward.circle")
                        .resizable()
                        .frame(width: self.width/3.5, height: self.width/3.5)
                        .foregroundStyle(Color(UIColor.whiteSideColor))
                        .shadow(radius: 10)
                }
        })
    }
    
    @ViewBuilder
    private func settingsPageButton() -> some View {
        Button(action: {
            withAnimation(.easeInOut) {
                self.showSettingsPage = true
            }
        }, label: {
            Circle()
                .frame(width: self.width/2, height: self.width/2)
                .foregroundStyle(Color(UIColor.blackSideColor))
                .overlay {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: self.width/3.5, height: self.width/3.5)
                        .foregroundStyle(Color(UIColor.whiteSideColor))
                        .shadow(radius: 10)
                }
        })
    }
}
