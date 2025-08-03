//
//  NoteDetailView.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import SwiftUI

struct NoteDetailView: View {
    let note: NoteEntity
    let onSave: (NoteEntity, String?, String?, Bool?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var content: String
    @State private var isImportant: Bool
    @State private var isEditing = false
    
    init(note: NoteEntity, onSave: @escaping (NoteEntity, String?, String?, Bool?) -> Void) {
        self.note = note
        self.onSave = onSave
        _title = State(initialValue: note.safeTitle)
        _content = State(initialValue: note.safeContent)
        _isImportant = State(initialValue: note.isImportant)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    if isEditing {
                        TextField("Note title", text: $title)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .textFieldStyle(PlainTextFieldStyle())
                    } else {
                        Text(title)
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    Button {
                        isImportant.toggle()
                        if !isEditing {
                            saveChanges()
                        }
                        UIImpactFeedbackGenerator.light()
                    } label: {
                        Image(systemName: isImportant ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundColor(isImportant ? .yellow : .gray)
                    }
                }
                
                // Metadata
                HStack {
                    if let category = note.category {
                        HStack(spacing: 4) {
                            Image(systemName: category.safeIcon)
                                .font(.caption)
                            Text(category.safeName)
                                .font(.caption)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(category.safeColor).opacity(0.2))
                        .foregroundColor(Color(category.safeColor))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Updated: \(note.safeUpdatedAt.relativeFormat)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Created: \(note.safeCreatedAt.shortDateFormat)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            
            // Content section
            if isEditing {
                TextEditor(text: $content)
                    .font(.body)
                    .padding()
            } else {
                ScrollView {
                    HStack {
                        Text(content.isEmpty ? "No content" : content)
                            .font(.body)
                            .foregroundColor(content.isEmpty ? .secondary : .primary)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        saveChanges()
                    }
                    isEditing.toggle()
                }
            }
        }
    }
    
    private func saveChanges() {
        let hasChanges = title != note.safeTitle || 
                        content != note.safeContent || 
                        isImportant != note.isImportant
        
        if hasChanges {
            onSave(
                note,
                title != note.safeTitle ? title : nil,
                content != note.safeContent ? content : nil,
                isImportant != note.isImportant ? isImportant : nil
            )
        }
    }
}