//
//  MainTabView.swift
//  ADHD Mind Companion
//
//  Created by Claude on 03/08/2025.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var themeManager = ThemeManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CaptureView()
                .tabItem {
                    Image(systemName: "mic.fill")
                    Text("Capture")
                }
                .tag(0)
            
            MyDayView()
                .tabItem {
                    Image(systemName: "sun.max.fill")
                    Text("My Day")
                }
                .tag(1)
            
            TasksView()
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Tasks")
                }
                .tag(2)
            
            NotesView()
                .tabItem {
                    Image(systemName: "note.text")
                    Text("Notes")
                }
                .tag(3)
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(4)
        }
        .environmentObject(themeManager)
        .preferredColorScheme(themeManager.selectedTheme.colorScheme)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        // Customize tab bar item appearance
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue
        ]
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}