//
//  DataManager.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import Foundation
import CoreData

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ADHD_Mind_Companion")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Core Data save error: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Task Operations
    
    func createTask(title: String, content: String, priority: TaskPriority = .medium, dueDate: Date? = nil, category: CategoryEntity? = nil, parentTask: TaskEntity? = nil) -> TaskEntity {
        let task = TaskEntity(context: viewContext)
        task.id = UUID()
        task.title = title
        task.content = content
        task.priority = Int16(priority.rawValue)
        task.dueDate = dueDate
        task.createdAt = Date()
        task.updatedAt = Date()
        task.isCompleted = false
        task.category = category
        task.parentTask = parentTask
        
        save()
        return task
    }
    
    func updateTask(_ task: TaskEntity, title: String? = nil, content: String? = nil, priority: TaskPriority? = nil, dueDate: Date? = nil, isCompleted: Bool? = nil) {
        if let title = title { task.title = title }
        if let content = content { task.content = content }
        if let priority = priority { task.priority = Int16(priority.rawValue) }
        if let dueDate = dueDate { task.dueDate = dueDate }
        if let isCompleted = isCompleted { task.isCompleted = isCompleted }
        task.updatedAt = Date()
        
        save()
    }
    
    func deleteTask(_ task: TaskEntity) {
        viewContext.delete(task)
        save()
    }
    
    func fetchTasks(completed: Bool? = nil, category: CategoryEntity? = nil) -> [TaskEntity] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        var predicates: [NSPredicate] = []
        
        if let completed = completed {
            predicates.append(NSPredicate(format: "isCompleted == %@", NSNumber(value: completed)))
        }
        
        if let category = category {
            predicates.append(NSPredicate(format: "category == %@", category))
        }
        
        // Only fetch top-level tasks (no parent)
        predicates.append(NSPredicate(format: "parentTask == nil"))
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TaskEntity.priority, ascending: false),
            NSSortDescriptor(keyPath: \TaskEntity.createdAt, ascending: true)
        ]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }
    
    func fetchTodayTasks() -> [TaskEntity] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicates = [
            NSPredicate(format: "isCompleted == NO"),
            NSPredicate(format: "dueDate >= %@ AND dueDate < %@", startOfDay as NSDate, endOfDay as NSDate)
        ]
        
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TaskEntity.priority, ascending: false),
            NSSortDescriptor(keyPath: \TaskEntity.dueDate, ascending: true)
        ]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching today's tasks: \(error)")
            return []
        }
    }
    
    // MARK: - Note Operations
    
    func createNote(title: String, content: String, isImportant: Bool = false, category: CategoryEntity? = nil) -> NoteEntity {
        let note = NoteEntity(context: viewContext)
        note.id = UUID()
        note.title = title
        note.content = content
        note.isImportant = isImportant
        note.createdAt = Date()
        note.updatedAt = Date()
        note.category = category
        
        save()
        return note
    }
    
    func updateNote(_ note: NoteEntity, title: String? = nil, content: String? = nil, isImportant: Bool? = nil) {
        if let title = title { note.title = title }
        if let content = content { note.content = content }
        if let isImportant = isImportant { note.isImportant = isImportant }
        note.updatedAt = Date()
        
        save()
    }
    
    func deleteNote(_ note: NoteEntity) {
        viewContext.delete(note)
        save()
    }
    
    func fetchNotes(important: Bool? = nil, category: CategoryEntity? = nil) -> [NoteEntity] {
        let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        var predicates: [NSPredicate] = []
        
        if let important = important {
            predicates.append(NSPredicate(format: "isImportant == %@", NSNumber(value: important)))
        }
        
        if let category = category {
            predicates.append(NSPredicate(format: "category == %@", category))
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \NoteEntity.isImportant, ascending: false),
            NSSortDescriptor(keyPath: \NoteEntity.updatedAt, ascending: false)
        ]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching notes: \(error)")
            return []
        }
    }
    
    func fetchImportantNotes() -> [NoteEntity] {
        return fetchNotes(important: true)
    }
    
    // MARK: - Category Operations
    
    func createCategory(name: String, color: String = "blue", icon: String = "folder") -> CategoryEntity {
        let category = CategoryEntity(context: viewContext)
        category.id = UUID()
        category.name = name
        category.color = color
        category.icon = icon
        category.createdAt = Date()
        
        save()
        return category
    }
    
    func updateCategory(_ category: CategoryEntity, name: String? = nil, color: String? = nil, icon: String? = nil) {
        if let name = name { category.name = name }
        if let color = color { category.color = color }
        if let icon = icon { category.icon = icon }
        
        save()
    }
    
    func deleteCategory(_ category: CategoryEntity) {
        viewContext.delete(category)
        save()
    }
    
    func fetchCategories() -> [CategoryEntity] {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CategoryEntity.name, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    // MARK: - Search Operations
    
    func searchContent(query: String) -> (tasks: [TaskEntity], notes: [NoteEntity]) {
        let taskRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        let noteRequest: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
        
        let taskPredicate = NSPredicate(format: "title CONTAINS[cd] %@ OR content CONTAINS[cd] %@", query, query)
        let notePredicate = NSPredicate(format: "title CONTAINS[cd] %@ OR content CONTAINS[cd] %@", query, query)
        
        taskRequest.predicate = taskPredicate
        noteRequest.predicate = notePredicate
        
        taskRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TaskEntity.updatedAt, ascending: false)]
        noteRequest.sortDescriptors = [NSSortDescriptor(keyPath: \NoteEntity.updatedAt, ascending: false)]
        
        do {
            let tasks = try viewContext.fetch(taskRequest)
            let notes = try viewContext.fetch(noteRequest)
            return (tasks, notes)
        } catch {
            print("Error searching content: \(error)")
            return ([], [])
        }
    }
    
    // MARK: - AI Integration
    
    func processAIAnalysis(_ result: AIAnalysisResult) {
        let category = findOrCreateCategory(name: result.category ?? "General")
        
        switch result.type {
        case .task:
            _ = createTask(
                title: result.title,
                content: result.content,
                priority: result.priority ?? .medium,
                dueDate: result.dueDate,
                category: category
            )
        case .note:
            _ = createNote(
                title: result.title,
                content: result.content,
                isImportant: result.isImportant,
                category: category
            )
        }
    }
    
    private func findOrCreateCategory(name: String) -> CategoryEntity {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            if let existingCategory = try viewContext.fetch(request).first {
                return existingCategory
            }
        } catch {
            print("Error finding category: \(error)")
        }
        
        return createCategory(name: name)
    }
}