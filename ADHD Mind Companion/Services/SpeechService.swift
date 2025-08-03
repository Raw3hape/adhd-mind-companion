//
//  SpeechService.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import Foundation
import Speech
import AVFoundation

class SpeechService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isListening = false
    @Published var transcribedText = ""
    @Published var error: SpeechError?
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override init() {
        super.init()
        setupSpeechRecognizer()
    }
    
    private func setupSpeechRecognizer() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer?.delegate = self
    }
    
    func requestPermissions() async -> Bool {
        do {
            // Request speech recognition permission
            let speechStatus = await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { status in
                    continuation.resume(returning: status)
                }
            }
            guard speechStatus == .authorized else {
                await MainActor.run {
                    self.error = .speechNotAuthorized
                }
                return false
            }
            
            // Request microphone permission
            let audioStatus = await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
            guard audioStatus else {
                await MainActor.run {
                    self.error = .microphoneNotAuthorized
                }
                return false
            }
            
            return true
        } catch {
            await MainActor.run {
                self.error = .permissionError
            }
            return false
        }
    }
    
    func startRecording() async {
        // Check permissions first
        guard await requestPermissions() else { return }
        
        await MainActor.run {
            self.error = nil
            self.transcribedText = ""
        }
        
        // Cancel any existing recognition task
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            await MainActor.run {
                self.error = .audioSessionError
            }
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            await MainActor.run {
                self.error = .recognitionError
            }
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Create recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let result = result {
                    self.transcribedText = result.bestTranscription.formattedString
                    
                    if result.isFinal {
                        self.stopRecording()
                    }
                }
                
                if error != nil {
                    self.error = .recognitionError
                    self.stopRecording()
                }
            }
        }
        
        // Configure audio input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            await MainActor.run {
                self.isRecording = true
                self.isListening = true
            }
        } catch {
            await MainActor.run {
                self.error = .audioEngineError
            }
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        Task { @MainActor in
            self.isRecording = false
            self.isListening = false
        }
    }
    
    func clearTranscription() {
        transcribedText = ""
        error = nil
    }
}

extension SpeechService: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        Task { @MainActor in
            if !available {
                self.error = .speechNotAvailable
                self.stopRecording()
            }
        }
    }
}

enum SpeechError: Error, LocalizedError {
    case speechNotAuthorized
    case microphoneNotAuthorized
    case speechNotAvailable
    case recognitionError
    case audioSessionError
    case audioEngineError
    case permissionError
    
    var errorDescription: String? {
        switch self {
        case .speechNotAuthorized:
            return "Speech recognition not authorized. Please enable in Settings."
        case .microphoneNotAuthorized:
            return "Microphone access not authorized. Please enable in Settings."
        case .speechNotAvailable:
            return "Speech recognition is not available."
        case .recognitionError:
            return "Speech recognition error occurred."
        case .audioSessionError:
            return "Audio session configuration failed."
        case .audioEngineError:
            return "Audio engine failed to start."
        case .permissionError:
            return "Permission request failed."
        }
    }
}