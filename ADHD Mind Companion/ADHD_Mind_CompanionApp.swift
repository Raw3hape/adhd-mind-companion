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
    let dataManager = DataManager.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(dataManager)
        }
    }
}
