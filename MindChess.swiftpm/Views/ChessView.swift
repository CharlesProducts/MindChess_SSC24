//
//  ChessView.swift
//  MindChess
//
//  Created by Charles de PLUVIÉ on 08/02/2024.
//

import SwiftUI
import SpriteKit
import AVFoundation

struct ChessView: View {
    
    // MARK: Data properties
    let screenSize : CGSize
    @StateObject var model : ChessViewModel
    
    // MARK: View properties
    @State private var showIntroduction : Bool = true
    @State private var showTutorial : Bool = true
    @State private var showSettingsPage : Bool = false
    @State private var showDiscoveryPage : Bool = false
    
    @State private var screenRotation = UIDeviceOrientation.unknown
    @State private var previousScreenRotation = UIDeviceOrientation.unknown
    
    private var screenRotationIsGood : Bool {
        return (self.screenRotation == .portrait || self.screenRotation == .portraitUpsideDown || (self.screenRotation == .faceUp && (self.previousScreenRotation == .portrait || self.screenRotation == .portraitUpsideDown)))
    }
    
    private var canShowIntroduction : Bool {
        return (self.screenRotationIsGood && self.showIntroduction)
    }
    private var canShowGameContent : Bool {
        return (self.screenRotationIsGood && !self.showIntroduction)
    }
    
    var body: some View {
        ZStack {
            Introduction(showIntroduction: self.$showIntroduction)
                .allowsHitTesting(self.canShowIntroduction)
                .opacity(self.canShowIntroduction ? 1.0 : 0.0)
            
            self.showGameContent()
                .allowsHitTesting(self.canShowGameContent)
                .opacity(self.canShowGameContent ? 1.0 : 0.0)
            
            self.showOrientationMessage()
                .allowsHitTesting(!self.screenRotationIsGood)
                .opacity(!self.screenRotationIsGood ? 1.0 : 0.0)
        }
        .onRotate { newOrientation in
            self.previousScreenRotation = self.screenRotation
            self.screenRotation = newOrientation
        }
    }
    
    @ViewBuilder
    private func showGameContent() -> some View {
        ZStack(alignment: .center) {
            Color(UIColor.whiteSideColor)
            
            VStack(alignment: .center) {
                
                if showTutorial {
                    AdviceView(width: screenSize.width/1.5,
                               toucheHasBeenUsed: self.$model.toucheHasBeenUsed,
                               speechRecognitionHasBeenUsed: self.$model.speechRecognitionHasBeenUsed,
                               backButtonStateHasBeenUsed: self.$model.backButtonStateHasBeenUsed,
                               speechRecognitionState: self.$model.voiceRecognitionIsActive,
                               voiceFeedbackState: self.$model.vocalFeedbackIsActive,
                               settingsState: self.$showSettingsPage,
                               discoveryPageState: self.$showDiscoveryPage)
                    .padding(.top, 40)
                    .shadow(radius: 5)
                }
                
                Spacer()
                
                SettingButtonShortcut(width: self.screenSize.width/5,
                                      height: self.screenSize.width/7,
                                      model: self.model,
                                      showSettingsPage: self.$showSettingsPage,
                                      showDiscoveryPage: self.$showDiscoveryPage)
                .hAlign(.trailing)
                .padding(.bottom, 10)
                
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
            
            SpriteView(scene: self.model.chessGame)
                .frame(width: self.screenSize.width, height: self.screenSize.width)
                .position(x: self.screenSize.width/2, y: self.screenSize.height/2)
                .chessBoardStyle(sideSize: self.screenSize.width)
        }
        .overlay {
            VStack {
                if self.model.pieceToPromute == true {
                    PieceToPromuteChoiceView(width: self.screenSize.width/1.2, height: self.screenSize.width/5, model: self.model)
                }
                
                if self.showSettingsPage {
                    SettingsPage(width: self.screenSize.width/1.3, height: self.screenSize.height/2.5, showSettingsPage: self.$showSettingsPage, showTutorial: self.$showTutorial, model: self.model)
                }
                
                if self.showDiscoveryPage {
                    DiscoveryPage(showDiscoveryPage: self.$showDiscoveryPage)
                }
            }
        }
    }
    
    @ViewBuilder 
    private func showOrientationMessage() -> some View {
        VStack(alignment: .center, spacing: 10) {
            if screenRotation == .unknown {
                Text("Move the iPad so the app can detect the screen orientation")
                    .font(.title2.bold())
            } else {
                Text("Please keep your iPad in portrait mode")
                    .font(.largeTitle.bold())
            }
        }
        .multilineTextAlignment(.center)
        .foregroundStyle(Color.black.opacity(0.8))
        .hAlign(.center)
        .vAlign(.center)
    }
}

#Preview {
    ContentView()
}
