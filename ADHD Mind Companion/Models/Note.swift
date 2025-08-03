//
//  Note.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import Foundation
import CoreData

@objc(CDNote)
public class NoteEntity: NSManagedObject {
    
}

extension NoteEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteEntity> {
        return NSFetchRequest<NoteEntity>(entityName: "CDNote")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var isImportant: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var category: CategoryEntity?

}

extension NoteEntity : Identifiable {
    public var safeID: UUID {
        return id ?? UUID()
    }
    
    public var safeTitle: String {
        return title ?? "Untitled Note"
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
    
    public var preview: String {
        let cleanContent = safeContent.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanContent.count > 100 {
            return String(cleanContent.prefix(100)) + "..."
        }
        return cleanContent
    }
}