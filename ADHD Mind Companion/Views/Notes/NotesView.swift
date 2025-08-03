//
//  NotesView.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import SwiftUI

struct NotesView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var showingAddNote = false
    @State private var searchText = ""
    @State private var selectedFilter: NoteFilter = .all
    
    enum NoteFilter: String, CaseIterable {
        case all = "All"
        case important = "Important"
        case recent = "Recent"
        
        var systemImage: String {
            switch self {
            case .all: return "note.text"
            case .important: return "star.fill"
            case .recent: return "clock"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Filter bar
                filterBar
                
                // Notes list
                if viewModel.isLoading {
                    ProgressView("Loading notes...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredNotes.isEmpty {
                    emptyStateView
                } else {
                    notesListView
                }
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddNote = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView { title, content, isImportant in
                    viewModel.createNote(title: title, content: content, isImportant: isImportant)
                }
            }
            .refreshable {
                viewModel.loadData()
            }
        }
        .onAppear {
            viewModel.loadData()
        }
        .onChange(of: searchText) { newValue in
            viewModel.searchNotes(newValue)
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search notes...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !searchText.isEmpty {
                Button("Clear") {
                    searchText = ""
                    viewModel.clearSearch()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(NoteFilter.allCases, id: \.self) { filter in
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
    
    private var notesListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredNotes, id: \.safeID) { note in
                    NavigationLink {
                        NoteDetailView(note: note) { updatedNote, title, content, isImportant in
                            viewModel.updateNote(updatedNote, title: title, content: content, isImportant: isImportant)
                        }
                    } label: {
                        NoteRowView(note: note) {
                            viewModel.toggleNoteImportance(note)
                            UIImpactFeedbackGenerator.light()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contextMenu {
                        noteContextMenu(note)
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
            
            if selectedFilter == .all {
                Button("Create Your First Note") {
                    showingAddNote = true
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(25)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateTitle: String {
        switch selectedFilter {
        case .all: return searchText.isEmpty ? "No notes yet" : "No matching notes"
        case .important: return "No important notes"
        case .recent: return "No recent notes"
        }
    }
    
    private var emptyStateSubtitle: String {
        switch selectedFilter {
        case .all: return searchText.isEmpty ? "Start capturing your thoughts and ideas" : "Try a different search term"
        case .important: return "Mark notes as important to see them here"
        case .recent: return "Your recent notes will appear here"
        }
    }
    
    private var filteredNotes: [NoteEntity] {
        let searchFiltered = searchText.isEmpty ? viewModel.notes : viewModel.notes.filter { note in
            note.safeTitle.localizedCaseInsensitiveContains(searchText) ||
            note.safeContent.localizedCaseInsensitiveContains(searchText)
        }
        
        switch selectedFilter {
        case .all:
            return searchFiltered
        case .important:
            return searchFiltered.filter { $0.isImportant }
        case .recent:
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return searchFiltered.filter { $0.safeUpdatedAt >= sevenDaysAgo }
        }
    }
    
    @ViewBuilder
    private func noteContextMenu(_ note: NoteEntity) -> some View {
        Button {
            viewModel.toggleNoteImportance(note)
        } label: {
            Label(note.isImportant ? "Remove from Important" : "Mark as Important", 
                  systemImage: note.isImportant ? "star.slash" : "star.fill")
        }
        
        Button(role: .destructive) {
            viewModel.deleteNote(note)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}