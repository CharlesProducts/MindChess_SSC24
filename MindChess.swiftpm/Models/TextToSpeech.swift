//
//  TextToSpeech.swift
//  MindChess
//
//  Created by Charles de PLUVIÉ on 19/02/2024.
//

import Foundation
import AVFoundation

final class TextToSpeech : NSObject, AVSpeechSynthesizerDelegate, ObservableObject {
    
    static let shared = TextToSpeech()

    @Published var synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    @Published var voiceIdentifier : String = AVSpeechSynthesisVoice.speechVoices().filter({$0.language == "en-US"}).first!.identifier
    
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }
    
    internal func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    // MARK: - Functions
    
    public func wrongTurn(actualTurn: String) {
        self.textToSpeech(text: "Impossible, it's \(actualTurn)'s turn.")
    }
    
    public func speekMove(start: String, end: String) {
        self.textToSpeech(text: "\(start) move to \(end).")
    }
    
    private func textToSpeech(text: String) {
        
        let utterance = AVSpeechUtterance(string: text)
        let voice = AVSpeechSynthesisVoice(identifier: self.voiceIdentifier)
        utterance.voice = voice

        self.synthesizer.speak(utterance)
    }
    
}
