//
//  AppInfo.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import Foundation

struct AppInfo {
    static let name = "ADHD Mind Companion"
    static let version = "1.0.0"
    static let description = "AI-powered companion that transforms your thoughts into organized tasks and notes"
    
    // Features
    static let features = [
        "Voice-to-text capture with AI analysis",
        "Smart categorization of tasks and notes",
        "Priority-based task management",
        "Today's focus with progress tracking",
        "Universal search across all content",
        "Dark and light theme support"
    ]
    
    // API Configuration
    struct API {
        static let openAIModel = "gpt-4o-mini"
        static let maxTokens = 500
        static let temperature = 0.3
    }
    
    // Default Categories
    static let defaultCategories = [
        ("Work", "briefcase", "blue"),
        ("Personal", "person", "green"),
        ("Health", "heart", "red"),
        ("Learning", "book", "purple"),
        ("Ideas", "lightbulb", "yellow")
    ]
}