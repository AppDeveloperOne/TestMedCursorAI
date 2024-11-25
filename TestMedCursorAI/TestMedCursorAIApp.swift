//
//  TestMedCursorAIApp.swift
//  TestMedCursorAI
//
//  Created by AppDeveloperOne on 2024-11-22.
//

import SwiftUI
import SwiftData

@main
struct TestMedCursorAIApp: App {
    let container: ModelContainer
    
    init() {
        do {
            // Create a Schema configuration that handles the migration
            let schema = Schema([
                MedicalAppointment.self,
                Doctor.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            // Delete existing store if migration fails
            do {
                container = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
            } catch {
                // If loading fails, delete the store and try again
                let storeURL = URL.applicationSupportDirectory
                    .appendingPathComponent("default.store")
                try? FileManager.default.removeItem(at: storeURL)
                
                container = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
            }
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
