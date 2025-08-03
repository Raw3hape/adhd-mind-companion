//
//  MyDayView.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import SwiftUI

struct MyDayView: View {
    @StateObject private var viewModel = MyDayViewModel()
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    headerSection
                    
                    todayTasksSection
                    
                    importantNotesSection
                    
                    upcomingSection
                    
                    overduSection
                }
                .padding()
            }
            .navigationTitle("My Day")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                refresh()
            }
        }
        .onAppear {
            refresh()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(selectedDate.formatted(date: .complete, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Quick stats
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(todayTasks.filter { !$0.isCompleted }.count) tasks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(importantNotes.count) notes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar
            if !todayTasks.isEmpty {
                progressBar
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var progressBar: some View {
        let completedCount = todayTasks.filter { $0.isCompleted }.count
        let totalCount = todayTasks.count
        let progress = totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Today's Progress")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(completedCount)/\(totalCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
        }
    }
    
    private var todayTasksSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Tasks")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !todayTasks.isEmpty {
                    Text("\(todayTasks.filter { !$0.isCompleted }.count) remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if todayTasks.isEmpty {
                emptyStateView(
                    icon: "checkmark.circle",
                    title: "No tasks for today",
                    subtitle: "Great job! You're all caught up."
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(todayTasks, id: \.safeID) { task in
                        TaskRowView(task: task) {
                            viewModel.toggleTaskCompletion(task)
                            UINotificationFeedbackGenerator.success()
                        }
                    }
                }
            }
        }
    }
    
    private var importantNotesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Important Notes")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !importantNotes.isEmpty {
                    Text("\(importantNotes.count) notes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if importantNotes.isEmpty {
                emptyStateView(
                    icon: "note.text",
                    title: "No important notes",
                    subtitle: "Important notes will appear here"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(importantNotes.prefix(3), id: \.safeID) { note in
                        NoteRowView(note: note) {
                            viewModel.toggleNoteImportance(note)
                        }
                    }
                    
                    if importantNotes.count > 3 {
                        NavigationLink("View all important notes") {
                            // Navigate to notes with important filter
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    
    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Upcoming This Week")
                .font(.title2)
                .fontWeight(.semibold)
            
            let upcoming = viewModel.upcomingTasks
            
            if upcoming.isEmpty {
                emptyStateView(
                    icon: "calendar",
                    title: "No upcoming tasks",
                    subtitle: "You're all set for the week"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(upcoming.prefix(3), id: \.safeID) { task in
                        TaskRowView(task: task, showDueDate: true) {
                            viewModel.toggleTaskCompletion(task)
                        }
                    }
                    
                    if upcoming.count > 3 {
                        NavigationLink("View all upcoming tasks") {
                            // Navigate to tasks view
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    
    private var overduSection: some View {
        let overdueTasks = viewModel.overdueTasks
        
        return Group {
            if !overdueTasks.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Overdue")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                        
                        Spacer()
                        
                        Text("\(overdueTasks.count) tasks")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    LazyVStack(spacing: 12) {
                        ForEach(overdueTasks, id: \.safeID) { task in
                            TaskRowView(task: task, showDueDate: true, isOverdue: true) {
                                viewModel.toggleTaskCompletion(task)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var todayTasks: [TaskEntity] {
        return viewModel.todayTasks
    }
    
    private var importantNotes: [NoteEntity] {
        return viewModel.importantNotes
    }
    
    private func refresh() {
        viewModel.loadData()
    }
    
    private func emptyStateView(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}