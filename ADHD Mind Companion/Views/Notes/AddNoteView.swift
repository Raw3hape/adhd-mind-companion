//
//  AddNoteView.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import SwiftUI

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var isImportant = false
    
    let onSave: (String, String, Bool) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Title section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Title")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button {
                            isImportant.toggle()
                            UIImpactFeedbackGenerator.light()
                        } label: {
                            Image(systemName: isImportant ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundColor(isImportant ? .yellow : .gray)
                        }
                    }
                    
                    TextField("Enter note title...", text: $title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Content section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Content")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    TextEditor(text: $content)
                        .font(.body)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                
                Spacer()
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(title.trimmed.isEmpty && content.trimmed.isEmpty)
                }
            }
        }
    }
    
    private func saveNote() {
        let noteTitle = title.trimmed.isEmpty ? "Untitled Note" : title.trimmed
        onSave(noteTitle, content.trimmed, isImportant)
        dismiss()
    }
}