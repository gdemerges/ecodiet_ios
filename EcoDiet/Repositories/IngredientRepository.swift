import Foundation
import SwiftData
import Observation

@Observable
class IngredientRepository: IngredientRepositoryProtocol {
    private let modelContext: ModelContext
    private(set) var ingredients: [Ingredient] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        Task {
            await loadAllIngredients()
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
            print("Error loading ingredients: \(error)")
        }
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
