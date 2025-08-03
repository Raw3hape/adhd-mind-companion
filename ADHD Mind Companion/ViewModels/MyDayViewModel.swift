//
//  MyDayViewModel.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
class MyDayViewModel: ObservableObject {
    @Published var todayTasks: [TaskEntity] = []
    @Published var importantNotes: [NoteEntity] = []
    @Published var upcomingTasks: [TaskEntity] = []
    @Published var overdueTasks: [TaskEntity] = []
    @Published var isLoading = false
    
    private let dataManager = DataManager.shared
    
    init() {
        loadData()
    }
    
    func loadData() {
        isLoading = true
        
        todayTasks = dataManager.fetchTodayTasks()
        importantNotes = dataManager.fetchImportantNotes()
        upcomingTasks = fetchUpcomingTasks()
        overdueTasks = fetchOverdueTasks()
        
        isLoading = false
    }
    
    func toggleTaskCompletion(_ task: TaskEntity) {
        dataManager.updateTask(task, isCompleted: !task.isCompleted)
        loadData()
    }
    
    func toggleNoteImportance(_ note: NoteEntity) {
        dataManager.updateNote(note, isImportant: !note.isImportant)
        loadData()
    }
    
    private func fetchUpcomingTasks() -> [TaskEntity] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        let calendar = Calendar.current
        let today = Date()
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today) ?? today
        
        let predicates = [
            NSPredicate(format: "isCompleted == NO"),
            NSPredicate(format: "dueDate > %@ AND dueDate <= %@", today as NSDate, nextWeek as NSDate)
        ]\n        \n        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)\n        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: true),
            NSSortDescriptor(keyPath: \TaskEntity.priority, ascending: false)
        ]\n        \n        do {\n            return try dataManager.viewContext.fetch(request)
        } catch {
            print("Error fetching upcoming tasks: \(error)")
            return []
        }\n    }\n    \n    private func fetchOverdueTasks() -> [TaskEntity] {\n        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()\n        let now = Date()\n        \n        let predicates = [\n            NSPredicate(format: \"isCompleted == NO\"),\n            NSPredicate(format: \"dueDate < %@\", now as NSDate)\n        ]\n        \n        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)\n        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: true)
        ]\n        \n        do {\n            return try dataManager.viewContext.fetch(request)
        } catch {
            print("Error fetching overdue tasks: \(error)")
            return []
        }
    }
    
    // MARK: - Computed Properties
    
    var todayProgress: Double {
        guard !todayTasks.isEmpty else { return 0 }
        let completed = todayTasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(todayTasks.count)
    }
    
    var todayCompletedCount: Int {
        todayTasks.filter { $0.isCompleted }.count
    }
    
    var todayPendingCount: Int {
        todayTasks.filter { !$0.isCompleted }.count
    }
}"