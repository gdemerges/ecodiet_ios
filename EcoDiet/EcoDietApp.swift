//
//  EcoDietApp.swift
//  EcoDiet
//
//  Created by Guillaume Demergès on 30/10/2025.
//

import SwiftUI
import SwiftData

@main
struct EcoDietApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Recipe.self,
            RecipeFolder.self,
            UserProfile.self,
            Ingredient.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        // Demander les permissions de notification au demarrage
        Task {
            await ExpirationNotificationService.shared.requestAuthorization()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .withThemeSupport()
                .onAppear {
                    scheduleExpirationNotifications()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func scheduleExpirationNotifications() {
        let context = sharedModelContainer.mainContext
        let descriptor = FetchDescriptor<Ingredient>()

        Task {
            do {
                let ingredients = try context.fetch(descriptor)
                await ExpirationNotificationService.shared.scheduleExpirationNotifications(for: ingredients)
            } catch {
                print("Erreur chargement ingredients pour notifications: \(error)")
            }
        }
    }
}
