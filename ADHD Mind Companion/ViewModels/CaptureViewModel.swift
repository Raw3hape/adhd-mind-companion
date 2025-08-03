//
//  CaptureViewModel.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import Foundation
import SwiftUI

@MainActor
class CaptureViewModel: ObservableObject {
    @Published var isProcessing = false
    @Published var showSuccess = false
    @Published var errorMessage: String?
    @Published var processedResult: AIAnalysisResult?
    
    private let speechService = SpeechService()
    private let aiService = AIService.shared
    private let dataManager = DataManager.shared
    
    var speechServicePublished: SpeechService {
        return speechService
    }
    
    func startRecording() async {
        await speechService.startRecording()
    }
    
    func stopRecording() {
        speechService.stopRecording()
    }
    
    func processTranscription() async {
        guard !speechService.transcribedText.isEmpty else {
            errorMessage = "No text to process"
            return
        }
        
        isProcessing = true
        errorMessage = nil
        
        do {
            let result = try await aiService.analyzeText(speechService.transcribedText)
            processedResult = result
            
            // Save to Core Data
            dataManager.processAIAnalysis(result)
            
            // Show success feedback
            showSuccess = true
            
            // Clear transcription after successful processing
            speechService.clearTranscription()
            
            // Hide success message after delay
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            showSuccess = false
            processedResult = nil
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isProcessing = false
    }
    
    func clearAll() {
        speechService.clearTranscription()
        errorMessage = nil
        processedResult = nil
        showSuccess = false
        isProcessing = false
    }
    
    func retryProcessing() async {
        errorMessage = nil
        await processTranscription()
    }
}