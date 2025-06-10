//
//  Speech_model.swift
//  MindChess
//
//  Created by Charles de PLUVIÉ on 24/01/2024.
//

import Speech

public final class SpeechModel : ObservableObject {
    
    // MARK: Properties for UI View
    @Published var isLoading : Bool = false
    
    @Published var isAvailable : Bool = false
    @Published var isListening : Bool = false
    
    @Published var userSpeech : String = ""
    
    // MARK: Properties
    
    // SpeechRecognize and Audio
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest:  SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask : SFSpeechRecognitionTask?
    
    private let audioSession = AVAudioSession.sharedInstance()
    private let audioEngine = AVAudioEngine()
    
    // Custom LM Support
    @available(iOS 17, *)
    private var lmConfiguration: SFSpeechLanguageModel.Configuration {
        let outputDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dynamicLanguageModel = outputDir.appendingPathComponent("LM")
        let dynamicVocabulary = outputDir.appendingPathComponent("Vocab")
        return SFSpeechLanguageModel.Configuration(languageModel: dynamicLanguageModel, vocabulary: dynamicVocabulary)
    }
    
    init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    if #available(iOS 17, *) {
                        Task.detached {
                            do {
                                let assetPath = Bundle.main.path(forResource: "CustomUSLMData", ofType: "bin")!
                                
                                let assetUrl = URL(fileURLWithPath: assetPath)
                                try await SFSpeechLanguageModel.prepareCustomLanguageModel(for: assetUrl,
                                                                                           clientIdentifier: "com.CharlesProduct.MindChess",
                                                                                           configuration: self.lmConfiguration)
                            } catch {
                                NSLog("Failed to prepare custom LM: \(error.localizedDescription)")
                            }
                        }
                    }
                    self.isAvailable = true
                    
                case .denied: self.isAvailable = false
                case .restricted: self.isAvailable = false
                case .notDetermined: self.isAvailable = false
                default: self.isAvailable = false
                }
            }
        }
    }
    
    public func startListening() throws {
        
        if self.isListening {
            return
        }
        self.isLoading = true
        
        // Cancel the previous task if it's running.
        if let recognitionTask = self.recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.addsPunctuation = false
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = true
            if #available(iOS 17, *) {
                recognitionRequest.customizedLanguageModel = self.lmConfiguration
            }
        }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            
            if let result = result {
                self.userSpeech = result.bestTranscription.formattedString
            }
            
            if error != nil {
                // Stop recognizing speech if there is a problem.
                // or if stopRecording method was call
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.isListening = false
            }
        }
        
        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()

        self.isLoading = false
        self.isListening = true
        
        print("Start recording")
    }
    

    public func stopListening() throws {
        
        if !self.isListening {
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.recognitionTask?.cancel()
            self.recognitionRequest?.endAudio()
            
            self.audioEngine.inputNode.removeTap(onBus: 0)
            self.audioEngine.stop()
            self.userSpeech = ""

            // Reset recognition-related properties
            self.recognitionRequest = nil
            self.recognitionTask = nil
            self.isListening = false
            self.isLoading = false
            print("Stop recording")
        }
    }
}
