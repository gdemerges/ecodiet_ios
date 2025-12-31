import Foundation
import SwiftData
import Observation

@Observable
class IngredientRepository: IngredientRepositoryProtocol {
    private let modelContext: ModelContext
    private(set) var ingredients: [Ingredient] = []
    private(set) var isLoaded = false

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        Task {
            await loadAllIngredients()
        }
    }

    /// Attend que le repository soit chargé
    func waitForLoad() async {
        // Si déjà chargé, retourner immédiatement
        if isLoaded { return }

        // Attendre avec un timeout de 5 secondes
        let startTime = Date()
        let timeout: TimeInterval = 5.0

        while !isLoaded && Date().timeIntervalSince(startTime) < timeout {
            try? await Task.sleep(nanoseconds: 50_000_000) // 50ms
        }
    }

    // MARK: - Public Methods

    /// Charge tous les ingrédients
    func loadAllIngredients() async {
        let descriptor = FetchDescriptor<Ingredient>(
            sortBy: [SortDescriptor(\.name)]
        )
        do {
            ingredients = try modelContext.fetch(descriptor)
        } catch {
            Logger.dataError("Erreur lors du chargement des ingrédients", error: error)
        }
        isLoaded = true
    }

    /// Récupère les ingrédients avec pagination
    func fetchIngredients(page: Int = 1, limit: Int = 20) async throws -> [Ingredient] {
        let offset = (page - 1) * limit
        var descriptor = FetchDescriptor<Ingredient>(
            sortBy: [SortDescriptor(\.name)]
        )
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset

        return try modelContext.fetch(descriptor)
    }

    /// Ajoute un ingrédient
    func addIngredient(_ ingredient: Ingredient) throws {
        modelContext.insert(ingredient)
        try modelContext.save()
        ingredients.append(ingredient)
    }

    /// Supprime un ingrédient
    func removeIngredient(_ ingredient: Ingredient) throws {
        modelContext.delete(ingredient)
        try modelContext.save()
        ingredients.removeAll { $0.id == ingredient.id }
    }

    /// Met à jour un ingrédient
    func updateIngredient(_ ingredient: Ingredient) throws {
        try modelContext.save()
    }
}
