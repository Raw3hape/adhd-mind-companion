//
//  ContentView.swift
//  ADHD Mind Companion
//
//  Created by Nikita Sergyshkin on 03/08/2025.
//

import SwiftUI
import CoreData

// Legacy ContentView - replaced by MainTabView
struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
