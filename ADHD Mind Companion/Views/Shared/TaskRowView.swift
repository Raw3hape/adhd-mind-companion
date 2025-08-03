//
//  TaskRowView.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import SwiftUI

struct TaskRowView: View {
    let task: TaskEntity
    var showDueDate: Bool = false
    var isOverdue: Bool = false
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion checkbox
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(task.safeTitle)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
                // Content preview
                if !task.safeContent.isEmpty {
                    Text(task.safeContent)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                // Bottom row with priority, due date, etc.
                HStack(spacing: 8) {
                    // Priority indicator
                    priorityIndicator
                    
                    // Due date
                    if showDueDate, let dueDate = task.dueDate {
                        dueDateView(dueDate)
                    }
                    
                    // Category
                    if let category = task.category {
                        categoryView(category)
                    }
                    
                    Spacer()
                    
                    // Subtasks count
                    if !task.subtasksArray.isEmpty {
                        subtasksIndicator
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: isOverdue ? 2 : 0)
        )
    }
    
    private var priorityIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(task.priorityLevel.themeColor)
                .frame(width: 8, height: 8)
            
            Text(task.priorityLevel.displayName)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func dueDateView(_ dueDate: Date) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
                .font(.caption)
            
            Text(dueDate.isToday ? "Today" : dueDate.relativeFormat)
                .font(.caption)
        }
        .foregroundColor(dueDateColor(dueDate))
    }
    
    private func categoryView(_ category: CategoryEntity) -> some View {
        HStack(spacing: 4) {
            Image(systemName: category.safeIcon)
                .font(.caption)
            
            Text(category.safeName)
                .font(.caption)
        }
        .foregroundColor(Color(category.safeColor))
    }
    
    private var subtasksIndicator: some View {
        let completedSubtasks = task.subtasksArray.filter { $0.isCompleted }.count
        let totalSubtasks = task.subtasksArray.count
        
        return HStack(spacing: 4) {
            Image(systemName: "list.bullet")
                .font(.caption)
            
            Text("\(completedSubtasks)/\(totalSubtasks)")
                .font(.caption)
        }
        .foregroundColor(.secondary)
    }
    
    private var backgroundColor: Color {
        if task.isCompleted {
            return Color(.systemGray6)
        } else if isOverdue {
            return Color.red.opacity(0.1)
        } else {
            return Color(.systemBackground)
        }
    }
    
    private var borderColor: Color {
        if isOverdue {
            return .red
        } else {
            return .clear
        }
    }
    
    private func dueDateColor(_ dueDate: Date) -> Color {
        if dueDate < Date() && !task.isCompleted {
            return .red
        } else if dueDate.isToday {
            return .orange
        } else if dueDate.isTomorrow {
            return .blue
        } else {
            return .secondary
        }
    }
}