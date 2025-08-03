//
//  Task.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import Foundation
import CoreData

@objc(CDTask)
public class TaskEntity: NSManagedObject {
    
}

extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "CDTask")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var priority: Int16
    @NSManaged public var dueDate: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var category: CategoryEntity?
    @NSManaged public var parentTask: TaskEntity?
    @NSManaged public var subtasks: NSSet?

}

// MARK: Generated accessors for subtasks
extension TaskEntity {

    @objc(addSubtasksObject:)
    @NSManaged public func addToSubtasks(_ value: TaskEntity)

    @objc(removeSubtasksObject:)
    @NSManaged public func removeFromSubtasks(_ value: TaskEntity)

    @objc(addSubtasks:)
    @NSManaged public func addToSubtasks(_ values: NSSet)

    @objc(removeSubtasks:)
    @NSManaged public func removeFromSubtasks(_ values: NSSet)

}

extension TaskEntity : Identifiable {
    public var safeID: UUID {
        return id ?? UUID()
    }
    
    public var safeTitle: String {
        return title ?? "Untitled Task"
    }
    
    public var safeContent: String {
        return content ?? ""
    }
    
    public var safeCreatedAt: Date {
        return createdAt ?? Date()
    }
    
    public var safeUpdatedAt: Date {
        return updatedAt ?? Date()
    }
    
    public var priorityLevel: TaskPriority {
        return TaskPriority(rawValue: Int(priority)) ?? .medium
    }
    
    public var subtasksArray: [TaskEntity] {
        let set = subtasks as? Set<TaskEntity> ?? []
        return set.sorted { $0.safeCreatedAt < $1.safeCreatedAt }
    }
}

public enum TaskPriority: Int, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2
    case urgent = 3
    
    public var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .urgent: return "Urgent"
        }
    }
    
    public var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "blue"
        case .high: return "orange"
        case .urgent: return "red"
        }
    }
}