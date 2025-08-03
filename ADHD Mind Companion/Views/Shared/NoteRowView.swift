//
//  NoteRowView.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import SwiftUI

struct NoteRowView: View {
    let note: NoteEntity
    let onToggleImportant: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header row
            HStack {
                Text(note.safeTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Spacer()
                
                Button(action: onToggleImportant) {
                    Image(systemName: note.isImportant ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundColor(note.isImportant ? .yellow : .gray)
                }
            }
            
            // Content preview
            if !note.safeContent.isEmpty {
                Text(note.preview)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            
            // Footer row
            HStack {
                // Category
                if let category = note.category {
                    categoryView(category)
                }
                
                Spacer()
                
                // Last updated
                Text(note.safeUpdatedAt.relativeFormat)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: note.isImportant ? 2 : 0)
        )
    }
    
    private func categoryView(_ category: CategoryEntity) -> some View {
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
    
    private var backgroundColor: Color {
        if note.isImportant {
            return Color.yellow.opacity(0.1)
        } else {
            return Color(.systemBackground)
        }
    }
    
    private var borderColor: Color {
        if note.isImportant {
            return .yellow
        } else {
            return .clear
        }
    }
}