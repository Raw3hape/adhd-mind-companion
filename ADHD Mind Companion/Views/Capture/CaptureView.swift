//
//  CaptureView.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import SwiftUI

struct CaptureView: View {
    @StateObject private var viewModel = CaptureViewModel()
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    headerSection
                    
                    Spacer()
                    
                    recordingSection
                    
                    Spacer()
                    
                    transcriptionSection
                    
                    if !viewModel.speechServicePublished.transcribedText.isEmpty {
                        actionButtons
                    }
                    
                    Spacer()
                }
                .padding()
                
                // Success overlay
                if viewModel.showSuccess {
                    successOverlay
                }
                
                // Processing overlay
                if viewModel.isProcessing {
                    processingOverlay
                }
            }
            .navigationTitle("Capture")
            .navigationBarTitleDisplayMode(.large)
            .alert("Permission Required", isPresented: $showingPermissionAlert) {
                Button("Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable microphone and speech recognition permissions in Settings to use voice capture.")
            }
            .onReceive(viewModel.speechServicePublished.$error) { error in
                if error != nil {
                    showingPermissionAlert = true
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("What's on your mind?")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Speak your thoughts and I'll organize them for you")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var recordingSection: some View {
        VStack(spacing: 20) {
            // Recording button
            Button(action: {
                if viewModel.speechServicePublished.isRecording {
                    viewModel.stopRecording()
                } else {
                    Task {
                        await viewModel.startRecording()
                    }
                }
            }) {
                ZStack {
                    Circle()
                        .fill(viewModel.speechServicePublished.isRecording ? Color.red : Color.blue)
                        .frame(width: 120, height: 120)
                    
                    if viewModel.speechServicePublished.isRecording {
                        // Pulsing animation for recording
                        Circle()
                            .stroke(Color.red.opacity(0.4), lineWidth: 4)
                            .frame(width: 140, height: 140)
                            .scaleEffect(viewModel.speechServicePublished.isListening ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: viewModel.speechServicePublished.isListening)
                    }
                    
                    Image(systemName: viewModel.speechServicePublished.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
            }
            .disabled(viewModel.isProcessing)
            
            // Recording status
            Text(recordingStatusText)
                .font(.headline)
                .foregroundColor(viewModel.speechServicePublished.isRecording ? .red : .primary)
                .animation(.easeInOut, value: viewModel.speechServicePublished.isRecording)
        }
    }
    
    private var recordingStatusText: String {
        if viewModel.speechServicePublished.isRecording {
            return "Recording... Tap to stop"
        } else if !viewModel.speechServicePublished.transcribedText.isEmpty {
            return "Tap to record again"
        } else {
            return "Tap to start recording"
        }
    }
    
    private var transcriptionSection: some View {
        Group {
            if !viewModel.speechServicePublished.transcribedText.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("What you said:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ScrollView {
                        Text(viewModel.speechServicePublished.transcribedText)
                            .font(.body)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .frame(maxHeight: 150)
                }
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button("Clear") {
                viewModel.clearAll()
                UIImpactFeedbackGenerator.light()
            }
            .font(.headline)
            .foregroundColor(.red)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.red.opacity(0.1))
            .cornerRadius(25)
            
            Button("Process") {
                Task {
                    await viewModel.processTranscription()
                }
                UIImpactFeedbackGenerator.medium()
            }
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(25)
            .disabled(viewModel.isProcessing)
        }
    }
    
    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Successfully processed!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if let result = viewModel.processedResult {
                    VStack(spacing: 8) {
                        Text("Created: \(result.type == .task ? "Task" : "Note")")
                            .font(.headline)
                        
                        Text(result.title)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(30)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 20)
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
                
                Text("Processing with AI...")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Analyzing your thoughts...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(30)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 20)
        }
    }
}