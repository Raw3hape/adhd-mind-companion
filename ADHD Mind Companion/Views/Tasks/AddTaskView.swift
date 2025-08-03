//
//  AddTaskView.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedPriority: TaskPriority = .medium
    @State private var dueDate = Date()
    @State private var hasDueDate = false
    
    let onSave: (String, String, TaskPriority, Date?) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Task Details") {
                    TextField("Task title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Description (optional)", text: $content, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(priority.themeColor)
                                    .frame(width: 12, height: 12)
                                
                                Text(priority.displayName)
                            }
                            .tag(priority)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Due Date") {
                    Toggle("Set due date", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("Due date", selection: $dueDate)
                            .datePickerStyle(CompactDatePickerStyle())
                    }
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.trimmed.isEmpty)
                }
            }
        }
    }
    
    private func saveTask() {
        onSave(
            title.trimmed,
            content.trimmed,
            selectedPriority,
            hasDueDate ? dueDate : nil
        )
        dismiss()
    }
}