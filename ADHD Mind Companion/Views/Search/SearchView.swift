//
//  SearchView.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var searchResults: (tasks: [TaskEntity], notes: [NoteEntity]) = ([], [])
    @State private var isSearching = false
    @State private var selectedScope: SearchScope = .all
    
    private let dataManager = DataManager.shared
    
    enum SearchScope: String, CaseIterable {
        case all = "All"
        case tasks = "Tasks"
        case notes = "Notes"
        
        var systemImage: String {
            switch self {
            case .all: return "magnifyingglass"
            case .tasks: return "checkmark.circle"
            case .notes: return "note.text"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Scope selector
                scopeSelector
                
                // Results
                if searchText.isEmpty {
                    emptySearchView
                } else if isSearching {
                    loadingView
                } else {
                    searchResultsView
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
        }
        .onChange(of: searchText) { newValue in
            performSearch(newValue)
        }
        .onChange(of: selectedScope) { _ in
            if !searchText.isEmpty {
                performSearch(searchText)
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search tasks and notes...", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    performSearch(searchText)
                }
            
            if !searchText.isEmpty {
                Button("Clear") {
                    searchText = ""
                    searchResults = ([], [])
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var scopeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(SearchScope.allCases, id: \.self) { scope in
                    Button {
                        selectedScope = scope
                        UIImpactFeedbackGenerator.light()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: scope.systemImage)
                                .font(.caption)
                            
                            Text(scope.rawValue)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedScope == scope ? Color.blue : Color(.systemBackground))
                        .foregroundColor(selectedScope == scope ? .white : .primary)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: selectedScope == scope ? 0 : 1)
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
    
    private var emptySearchView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Search Everything")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text("Find your tasks and notes by typing keywords, dates, or categories")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Search tips:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "lightbulb")
                        .foregroundColor(.yellow)
                    Text("Try searching for priority levels, dates, or categories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    Text("Search 'today', 'this week', or specific dates")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "tag")
                        .foregroundColor(.green)
                    Text("Find items by category or content keywords")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            
            Text("Searching...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var searchResultsView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Tasks section
                if shouldShowTasks && !searchResults.tasks.isEmpty {
                    searchSection(
                        title: "Tasks",
                        count: searchResults.tasks.count,
                        icon: "checkmark.circle"
                    ) {
                        ForEach(searchResults.tasks, id: \.safeID) { task in
                            TaskRowView(
                                task: task,
                                showDueDate: true
                            ) {
                                // Toggle task completion
                                DataManager.shared.updateTask(task, isCompleted: !task.isCompleted)
                                performSearch(searchText) // Refresh results
                                UINotificationFeedbackGenerator.success()
                            }
                        }
                    }
                }
                
                // Notes section
                if shouldShowNotes && !searchResults.notes.isEmpty {
                    searchSection(
                        title: "Notes",
                        count: searchResults.notes.count,
                        icon: "note.text"
                    ) {
                        ForEach(searchResults.notes, id: \.safeID) { note in
                            NavigationLink {
                                NoteDetailView(note: note) { updatedNote, title, content, isImportant in
                                    DataManager.shared.updateNote(updatedNote, title: title, content: content, isImportant: isImportant)
                                    performSearch(searchText) // Refresh results
                                }
                            } label: {
                                NoteRowView(note: note) {
                                    DataManager.shared.updateNote(note, isImportant: !note.isImportant)
                                    performSearch(searchText) // Refresh results
                                    UIImpactFeedbackGenerator.light()
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // No results
                if searchResults.tasks.isEmpty && searchResults.notes.isEmpty {
                    noResultsView
                }
            }
            .padding()
        }
    }
    
    private var shouldShowTasks: Bool {
        selectedScope == .all || selectedScope == .tasks
    }
    
    private var shouldShowNotes: Bool {
        selectedScope == .all || selectedScope == .notes
    }
    
    private func searchSection<Content: View>(
        title: String,
        count: Int,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(count) result\(count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            content()
        }
    }
    
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("No results found")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Try different keywords or check your spelling")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
    
    private func performSearch(_ query: String) {
        guard !query.isEmpty else {
            searchResults = ([], [])
            return
        }
        
        isSearching = true
        
        // Add small delay to avoid too frequent searches
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let results = dataManager.searchContent(query: query)
            
            // Filter results based on selected scope
            let filteredTasks = shouldShowTasks ? results.tasks : []
            let filteredNotes = shouldShowNotes ? results.notes : []
            
            searchResults = (filteredTasks, filteredNotes)
            isSearching = false
        }
    }
}