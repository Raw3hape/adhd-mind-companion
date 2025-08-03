//
//  Category.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import Foundation
import CoreData

@objc(CategoryEntity)
public class CategoryEntity: NSManagedObject {
    
}

extension CategoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryEntity> {
        return NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var color: String?
    @NSManaged public var icon: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var tasks: NSSet?
    @NSManaged public var notes: NSSet?

}

// MARK: Generated accessors for tasks
extension CategoryEntity {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: TaskEntity)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: TaskEntity)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}

// MARK: Generated accessors for notes
extension CategoryEntity {

    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: NoteEntity)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: NoteEntity)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)

}

extension CategoryEntity : Identifiable {
    public var safeID: UUID {
        return id ?? UUID()
    }
    
    public var safeName: String {
        return name ?? "Unnamed Category"
    }
    
    public var safeColor: String {
        return color ?? "blue"
    }
    
    public var safeIcon: String {
        return icon ?? "folder"
    }
    
    public var safeCreatedAt: Date {
        return createdAt ?? Date()
    }
    
    public var tasksArray: [TaskEntity] {
        let set = tasks as? Set<TaskEntity> ?? []
        return set.sorted { $0.safeCreatedAt < $1.safeCreatedAt }
    }
    
    public var notesArray: [NoteEntity] {
        let set = notes as? Set<NoteEntity> ?? []
        return set.sorted { $0.safeCreatedAt < $1.safeCreatedAt }
    }
    
    public var tasksCount: Int {
        return tasksArray.count
    }
    
    public var notesCount: Int {
        return notesArray.count
    }
}