//
//  TasksViewModel.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
class TasksViewModel: ObservableObject {
    @Published var tasks: [TaskEntity] = []
    @Published var categories: [CategoryEntity] = []
    @Published var selectedCategory: CategoryEntity?
    @Published var showCompleted = false
    @Published var isLoading = false
    
    private let dataManager = DataManager.shared
    
    init() {
        loadData()
    }
    
    func loadData() {
        isLoading = true
        
        tasks = dataManager.fetchTasks(
            completed: showCompleted ? nil : false,
            category: selectedCategory
        )
        
        categories = dataManager.fetchCategories()
        
        isLoading = false
    }
    
    func toggleTaskCompletion(_ task: TaskEntity) {
        dataManager.updateTask(task, isCompleted: !task.isCompleted)
        loadData()
    }
    
    func deleteTask(_ task: TaskEntity) {
        dataManager.deleteTask(task)
        loadData()
    }
    
    func createTask(title: String, content: String, priority: TaskPriority = .medium, dueDate: Date? = nil) {
        _ = dataManager.createTask(
            title: title,
            content: content,
            priority: priority,
            dueDate: dueDate,
            category: selectedCategory
        )
        loadData()
    }
    
    func updateTask(_ task: TaskEntity, title: String? = nil, content: String? = nil, priority: TaskPriority? = nil, dueDate: Date? = nil) {
        dataManager.updateTask(task, title: title, content: content, priority: priority, dueDate: dueDate)
        loadData()
    }
    
    func filterByCategory(_ category: CategoryEntity?) {
        selectedCategory = category
        loadData()
    }
    
    func toggleShowCompleted() {
        showCompleted.toggle()
        loadData()
    }
    
    func tasksByPriority() -> [TaskPriority: [TaskEntity]] {
        var grouped: [TaskPriority: [TaskEntity]] = [:]
        
        for priority in TaskPriority.allCases {
            grouped[priority] = tasks.filter { $0.priorityLevel == priority }
        }
        
        return grouped
    }
    
    func tasksGroupedByCategory() -> [CategoryEntity: [TaskEntity]] {
        var grouped: [CategoryEntity: [TaskEntity]] = [:]
        
        for task in tasks {
            if let category = task.category {
                if grouped[category] == nil {
                    grouped[category] = []
                }
                grouped[category]!.append(task)
            }
        }
        
        return grouped
    }
    
    func upcomingTasks(days: Int = 7) -> [TaskEntity] {
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .day, value: days, to: Date()) ?? Date()
        
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate <= endDate && !task.isCompleted
        }.sorted { $0.dueDate ?? Date.distantFuture < $1.dueDate ?? Date.distantFuture }
    }
    
    func overdueTasks() -> [TaskEntity] {
        let now = Date()
        
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate < now && !task.isCompleted
        }
    }
}