//
//  ADHD_Mind_CompanionApp.swift
//  ADHD Mind Companion
//
//  Created by Nikita Sergyshkin on 03/08/2025.
//

import SwiftUI

@main
struct ADHD_Mind_CompanionApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
