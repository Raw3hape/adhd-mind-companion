//
//  Persistence.swift
//  ADHD Mind Companion
//
//  Created by Nikita Sergyshkin on 03/08/2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample categories
        let workCategory = CDCategory(context: viewContext)
        workCategory.id = UUID()
        workCategory.name = "Work"
        workCategory.color = "blue"
        workCategory.icon = "briefcase"
        
        let personalCategory = CDCategory(context: viewContext)
        personalCategory.id = UUID()
        personalCategory.name = "Personal"
        personalCategory.color = "green"
        personalCategory.icon = "person"
        
        let ideasCategory = CDCategory(context: viewContext)
        ideasCategory.id = UUID()
        ideasCategory.name = "Ideas"
        ideasCategory.color = "purple"
        ideasCategory.icon = "lightbulb"
        
        // Create sample tasks
        let task1 = CDTask(context: viewContext)
        task1.id = UUID()
        task1.title = "Complete project proposal"
        task1.notes = "Finish the Q2 project proposal and send to team for review"
        task1.priority = 2 // High
        task1.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        task1.createdAt = Date()
        task1.updatedAt = Date()
        task1.isCompleted = false
        task1.groupName = "Work"
        
        let task2 = CDTask(context: viewContext)
        task2.id = UUID()
        task2.title = "Buy groceries"
        task2.notes = "Milk, bread, eggs, and vegetables"
        task2.priority = 1 // Medium
        task2.dueDate = Date()
        task2.createdAt = Date()
        task2.updatedAt = Date()
        task2.isCompleted = false
        task2.groupName = "Personal"
        
        let task3 = CDTask(context: viewContext)
        task3.id = UUID()
        task3.title = "Call doctor"
        task3.notes = "Schedule annual checkup"
        task3.priority = 2 // High
        task3.dueDate = Date()
        task3.createdAt = Date()
        task3.updatedAt = Date()
        task3.isCompleted = false
        task3.groupName = "Health"
        
        // Create sample notes
        let note1 = CDNote(context: viewContext)
        note1.id = UUID()
        note1.title = "App Ideas"
        note1.content = "Ideas for new features:\n- Voice memo integration\n- Smart scheduling\n- Progress tracking\n- Gamification elements"
        note1.createdAt = Date()
        note1.updatedAt = Date()
        note1.category = ideasCategory
        
        let note2 = CDNote(context: viewContext)
        note2.id = UUID()
        note2.title = "Weekend Plans"
        note2.content = "Visit the museum, have lunch with friends, and finish reading the book"
        note2.createdAt = Date()
        note2.updatedAt = Date()
        note2.category = personalCategory
        
        let note3 = CDNote(context: viewContext)
        note3.id = UUID()
        note3.title = "Meeting Notes"
        note3.content = "Discussed new project timeline, need to adjust deliverables"
        note3.createdAt = Date()
        note3.updatedAt = Date()
        note3.category = workCategory
        
        // Link note1 with task1
        note1.addToLinkedTasks(task1)
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ADHD_Mind_Companion")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
