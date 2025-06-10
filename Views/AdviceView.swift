//
//  AdviceView.swift
//  MindChess
//
//  Created by Charles de PLUVIÉ on 20/02/2024.
//

import SwiftUI

struct AdviceView: View {
    
    public let width : CGFloat
    
    @Binding var toucheHasBeenUsed : Bool
    @Binding var speechRecognitionHasBeenUsed : Bool
    @Binding var backButtonStateHasBeenUsed : Bool
    @Binding var speechRecognitionState : Bool
    @Binding var voiceFeedbackState : Bool
    @Binding var settingsState : Bool
    @Binding var discoveryPageState : Bool
    
    @State private var finalSpeechRecognitionHasBeenUsed : Bool = false
    @State private var finalVoiceFeedbackHasBeenUsed : Bool = false
    @State private var finalSettingsHasBeenUsed : Bool = false
    @State private var finalDiscoveryPageHasBeenUsed : Bool = false
    
    private let textForUseTouche = "Touch a white piece then touch the arrival square."
    private let textForUseSpeech = "Now say what piece you want to move with : 'Move D7 to D5' for exemple ! \nPlease articulate and speak fluently."
    private let textForGoBack = "If you made a mistake, you can go back using the back button at the bottom of the screen."
    private let textForSpeechRecognition = "You can mute voice recognition and audio feedback at the bottom of the screen."
    private let textForSettings = "You can adjust some settings by tapping the gear at the bottom of the screen."
    private let textForDiscovery = "Why not take a look at the discovery section at the bottom left of the screen ?"
    private let textForEnd = "End of the visit ! Now it's up to you to have fun with it, if you want you can try to play without looking at the board ! Good luck to you."
    
    var body: some View {
        VStack {
            if !self.toucheHasBeenUsed {
                self.adviceToShow(textToShow: self.textForUseTouche)
            } else if !self.speechRecognitionHasBeenUsed {
                self.adviceToShow(textToShow: self.textForUseSpeech)
            } else if !self.backButtonStateHasBeenUsed {
                self.adviceToShow(textToShow: self.textForGoBack)
            } else if !self.finalSpeechRecognitionHasBeenUsed && !self.finalVoiceFeedbackHasBeenUsed {
                self.adviceToShow(textToShow: self.textForSpeechRecognition)
            } else if !self.finalSettingsHasBeenUsed {
                self.adviceToShow(textToShow: self.textForSettings)
            } else if !self.finalDiscoveryPageHasBeenUsed {
                self.adviceToShow(textToShow: self.textForDiscovery)
            } else {
                self.adviceToShow(textToShow: self.textForEnd)
            }
        }
        .onChange(of: self.speechRecognitionState) { _ in
            withAnimation(.easeInOut) {
                self.finalSpeechRecognitionHasBeenUsed = true
            }
        }
        .onChange(of: self.voiceFeedbackState) { _ in
            withAnimation(.easeInOut) {
                self.finalVoiceFeedbackHasBeenUsed = true
            }
        }
        .onChange(of: self.settingsState) { _ in
            withAnimation(.easeInOut) {
                self.finalSettingsHasBeenUsed = true
            }
        }
        .onChange(of: self.discoveryPageState) { _ in
            withAnimation(.easeInOut) {
                self.finalDiscoveryPageHasBeenUsed = true
            }
        }
    }
    
    @ViewBuilder
    private func adviceToShow(textToShow: String) -> some View {
        Text(textToShow)
            .font(.callout)
            .foregroundStyle(Color.black.opacity(0.9))
            .frame(width: self.width)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(Color(UIColor.blackSideColor))
            }
    }
}
