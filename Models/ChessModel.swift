//
//  ChessModel.swift
//  MindChess
//
//  Created by Charles de PLUVIÉ on 19/02/2024.
//

import Foundation
import Combine

final class ChessViewModel: ObservableObject {
    
    @Published var chessGame : ChessScene
    
    @Published var speechModel = SpeechModel()
    @Published var textToSpeech = TextToSpeech.shared
    
    @Published var voiceRecognitionIsActive : Bool = true
    @Published var vocalFeedbackIsActive : Bool = true
    @Published var pieceToPromute : Bool = false
    
    @Published var toucheHasBeenUsed : Bool = false
    @Published var speechRecognitionHasBeenUsed : Bool = false
    @Published var backButtonStateHasBeenUsed : Bool = false

    private var anyCancellables: Set<AnyCancellable> = []
    
    init(chessGame: ChessScene) {
        self.chessGame = chessGame
        self.setupBindings()
    }
    
    private func setupBindings() {
        self.speechModel.$userSpeech
            .sink { [weak self] recognizedText in
                
                guard let self = self, self.voiceRecognitionIsActive else { return }
                let commandIsValid = self.chessGame.checkVoiceCommand(text: recognizedText, vocalFeedback: self.vocalFeedbackIsActive)
                if commandIsValid && self.vocalFeedbackIsActive {
                    self.stopListening()
                }
            }
            .store(in: &anyCancellables)
        
        self.textToSpeech.$isSpeaking
            .sink { [weak self] isSpeaking in
                
                guard let self = self else { return }
                
                if !isSpeaking {
                    if !self.speechModel.isLoading && !self.speechModel.isListening && self.voiceRecognitionIsActive {
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            self.startListening()
                        }
                    }
                }
            }
            .store(in: &anyCancellables)
        
        self.chessGame.$pieceToPromute
            .sink { [weak self] pieceToPromute in
                guard let self = self else { return }
                self.pieceToPromute = pieceToPromute
            }
            .store(in: &anyCancellables)
        
        self.chessGame.$swappingChessChoice
            .sink { [weak self] swappingChessChoice in
                
                guard let self = self else { return }
                
                if swappingChessChoice == .onlyOneSide {
                    self.chessGame.turnOnlyBlackPieces()
                } else if swappingChessChoice == .solo {
                    self.chessGame.resetPiecesRotation()
                } else {
                    self.chessGame.turnPiecesAtEachTurn()
                }
            }
            .store(in: &anyCancellables)
        
        self.chessGame.$toucheHasBeenUsed
            .sink { [weak self] toucheHasBeenUsed in
                guard let self = self else { return }
                self.toucheHasBeenUsed = toucheHasBeenUsed
            }
            .store(in: &anyCancellables)
        
        self.chessGame.$speechRecognitionHasBeenUsed
            .sink { [weak self] speechRecognitionHasBeenUsed in
                guard let self = self else { return }
                self.speechRecognitionHasBeenUsed = speechRecognitionHasBeenUsed
            }
            .store(in: &anyCancellables)
        
        self.chessGame.$backButtonHasBeenUsed
            .sink { [weak self] backButtonHasBeenUsed in
                guard let self = self else { return }
                self.backButtonStateHasBeenUsed = backButtonHasBeenUsed
            }
            .store(in: &anyCancellables)
    }
    
    public func startListening() {
        do {
            try self.speechModel.startListening()
        } catch {
            print("DEBUG : \(error.localizedDescription)")
        }
    }
    
    public func stopListening() {
        do {
            try self.speechModel.stopListening()
        } catch {
            print("DEBUG : \(error.localizedDescription)")
        }
    }
    
}

