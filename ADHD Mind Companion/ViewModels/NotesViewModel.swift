//
//  NotesViewModel.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import Foundation
import SwiftUI
import CoreData

@MainActor
class NotesViewModel: ObservableObject {
    @Published var notes: [NoteEntity] = []
    @Published var categories: [CategoryEntity] = []
    @Published var selectedCategory: CategoryEntity?
    @Published var showOnlyImportant = false
    @Published var isLoading = false
    @Published var searchText = ""
    
    private let dataManager = DataManager.shared
    
    init() {
        loadData()
    }
    
    func loadData() {
        isLoading = true
        
        let fetchedNotes = dataManager.fetchNotes(
            important: showOnlyImportant ? true : nil,
            category: selectedCategory
        )
        
        // Apply search filter if needed
        if searchText.isEmpty {
            notes = fetchedNotes
        } else {
            notes = fetchedNotes.filter { note in
                note.safeTitle.localizedCaseInsensitiveContains(searchText) ||
                note.safeContent.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        categories = dataManager.fetchCategories()
        
        isLoading = false
    }
    
    func createNote(title: String, content: String, isImportant: Bool = false) {
        _ = dataManager.createNote(
            title: title,
            content: content,
            isImportant: isImportant,
            category: selectedCategory
        )
        loadData()
    }
    
    func updateNote(_ note: NoteEntity, title: String? = nil, content: String? = nil, isImportant: Bool? = nil) {
        dataManager.updateNote(note, title: title, content: content, isImportant: isImportant)
        loadData()
    }
    
    func deleteNote(_ note: NoteEntity) {
        dataManager.deleteNote(note)
        loadData()
    }
    
    func toggleNoteImportance(_ note: NoteEntity) {
        dataManager.updateNote(note, isImportant: !note.isImportant)
        loadData()
    }
    
    func filterByCategory(_ category: CategoryEntity?) {
        selectedCategory = category
        loadData()
    }
    
    func toggleShowOnlyImportant() {
        showOnlyImportant.toggle()
        loadData()
    }
    
    func searchNotes(_ query: String) {
        searchText = query
        loadData()
    }
    
    func clearSearch() {
        searchText = ""
        loadData()
    }
    
    func notesGroupedByCategory() -> [CategoryEntity: [NoteEntity]] {
        var grouped: [CategoryEntity: [NoteEntity]] = [:]
        
        for note in notes {
            if let category = note.category {
                if grouped[category] == nil {
                    grouped[category] = []
                }
                grouped[category]!.append(note)
            }
        }
        
        return grouped
    }
    
    func recentNotes(limit: Int = 10) -> [NoteEntity] {
        return Array(notes.prefix(limit))
    }
    
    func importantNotes() -> [NoteEntity] {
        return notes.filter { $0.isImportant }
    }
    
    func notesByDate() -> [String: [NoteEntity]] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        var grouped: [String: [NoteEntity]] = [:]
        
        for note in notes {
            let dateKey = dateFormatter.string(from: note.safeCreatedAt)
            if grouped[dateKey] == nil {
                grouped[dateKey] = []
            }
            grouped[dateKey]!.append(note)
        }
        
        return grouped
    }
}