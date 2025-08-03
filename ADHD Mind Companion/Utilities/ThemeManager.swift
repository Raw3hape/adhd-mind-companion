//
//  ThemeManager.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: ThemeType = .system
    
    enum ThemeType: String, CaseIterable {
        case light = "light"
        case dark = "dark"
        case system = "system"
        
        var displayName: String {
            switch self {
            case .light: return "Light"
            case .dark: return "Dark"
            case .system: return "System"
            }
        }
        
        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .system: return nil
            }
        }
    }
}

// MARK: - Custom Colors
extension Color {
    static let theme = ThemeColors()
}

struct ThemeColors {
    let primary = Color.blue
    let secondary = Color.gray
    let accent = Color.accentColor
    let background = Color(.systemBackground)
    let surface = Color(.secondarySystemBackground)
    let textPrimary = Color.primary
    let textSecondary = Color.secondary
    let success = Color.green
    let warning = Color.orange
    let error = Color.red
    let info = Color.blue
}

// MARK: - Priority Colors
extension TaskPriority {
    var themeColor: Color {
        switch self {
        case .low: return .green
        case .medium: return .blue
        case .high: return .orange
        case .urgent: return .red
        }
    }
}