//
//  TasksView.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import SwiftUI

struct TasksView: View {
    @StateObject private var viewModel = TasksViewModel()
    @State private var showingAddTask = false
    @State private var showingFilters = false
    @State private var selectedFilter: TaskFilter = .all
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case pending = "Pending"
        case completed = "Completed"
        case overdue = "Overdue"
        case today = "Today"
        case thisWeek = "This Week"
        
        var systemImage: String {
            switch self {
            case .all: return "list.bullet"
            case .pending: return "circle"
            case .completed: return "checkmark.circle"
            case .overdue: return "exclamationmark.triangle"
            case .today: return "calendar"
            case .thisWeek: return "calendar.badge.clock"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter bar
                filterBar
                
                // Tasks list
                if viewModel.isLoading {
                    ProgressView("Loading tasks...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredTasks.isEmpty {
                    emptyStateView
                } else {
                    tasksListView
                }
            }
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Add Task") {
                            showingAddTask = true
                        }
                        
                        Button("Filters") {
                            showingFilters = true
                        }
                        
                        Button(viewModel.showCompleted ? "Hide Completed" : "Show Completed") {
                            viewModel.toggleShowCompleted()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView { title, content, priority, dueDate in
                    viewModel.createTask(title: title, content: content, priority: priority, dueDate: dueDate)
                }
            }
            .refreshable {
                viewModel.loadData()
            }
        }
        .onAppear {
            viewModel.loadData()
        }
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        icon: filter.systemImage,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                        UIImpactFeedbackGenerator.light()
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private var tasksListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredTasks, id: \.safeID) { task in
                    TaskRowView(
                        task: task,
                        showDueDate: true
                    ) {
                        viewModel.toggleTaskCompletion(task)
                        UINotificationFeedbackGenerator.success()
                    }
                    .contextMenu {
                        taskContextMenu(task)
                    }
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: selectedFilter.systemImage)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(emptyStateTitle)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text(emptyStateSubtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add Your First Task") {
                showingAddTask = true
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(25)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateTitle: String {
        switch selectedFilter {
        case .all: return "No tasks yet"
        case .pending: return "No pending tasks"
        case .completed: return "No completed tasks"
        case .overdue: return "No overdue tasks"
        case .today: return "No tasks for today"
        case .thisWeek: return "No tasks this week"
        }
    }
    
    private var emptyStateSubtitle: String {
        switch selectedFilter {
        case .all: return "Create your first task to get started"
        case .pending: return "Great job! All tasks are completed"
        case .completed: return "Complete some tasks to see them here"
        case .overdue: return "You're all caught up!"
        case .today: return "No tasks scheduled for today"
        case .thisWeek: return "Your week is clear"
        }
    }
    
    private var filteredTasks: [TaskEntity] {
        let allTasks = viewModel.tasks
        
        switch selectedFilter {
        case .all:
            return allTasks
        case .pending:
            return allTasks.filter { !$0.isCompleted }
        case .completed:
            return allTasks.filter { $0.isCompleted }
        case .overdue:
            return viewModel.overdueTasks()
        case .today:
            return allTasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return Calendar.current.isDateInToday(dueDate)
            }
        case .thisWeek:
            return allTasks.filter { task in
                guard let dueDate = task.dueDate else { return false }
                return Calendar.current.isDate(dueDate, equalTo: Date(), toGranularity: .weekOfYear)
            }
        }
    }
    
    @ViewBuilder
    private func taskContextMenu(_ task: TaskEntity) -> some View {
        Button {
            viewModel.toggleTaskCompletion(task)
        } label: {
            Label(task.isCompleted ? "Mark Incomplete" : "Mark Complete", 
                  systemImage: task.isCompleted ? "circle" : "checkmark.circle")
        }
        
        Button(role: .destructive) {
            viewModel.deleteTask(task)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue, lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}