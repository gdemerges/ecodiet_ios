import Foundation
import SwiftData
import Observation

@Observable
class RecipeRepository: RecipeRepositoryProtocol {
    private let modelContext: ModelContext
    private(set) var recipes: [Recipe] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        Task {
            await loadAllRecipes()
        }
    }

    // MARK: - Public Methods

    /// Charge toutes les recettes (pour compatibilité avec code existant)
    func loadAllRecipes() async {
        let descriptor = FetchDescriptor<Recipe>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        do {
            recipes = try modelContext.fetch(descriptor)
        } catch {
            print("Error loading recipes: \(error)")
        }
    }

    /// Récupère les recettes avec pagination
    /// - Parameters:
    ///   - page: Numéro de page (commence à 1)
    ///   - limit: Nombre de recettes par page
    /// - Returns: Liste de recettes pour la page demandée
    func fetchRecipes(page: Int = 1, limit: Int = 20) async throws -> [Recipe] {
        let offset = (page - 1) * limit
        var descriptor = FetchDescriptor<Recipe>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset

        return try modelContext.fetch(descriptor)
    }

    /// Ajoute une nouvelle recette
    /// - Parameter recipe: Recette à ajouter
    func addRecipe(_ recipe: Recipe) throws {
        modelContext.insert(recipe)
        try modelContext.save()
        recipes.append(recipe)
    }

    /// Supprime une recette
    /// - Parameter recipe: Recette à supprimer
    func deleteRecipe(_ recipe: Recipe) throws {
        modelContext.delete(recipe)
        try modelContext.save()
        recipes.removeAll { $0.id == recipe.id }
    }

    /// Recherche des recettes par titre avec pagination
    /// - Parameters:
    ///   - query: Terme de recherche
    ///   - page: Numéro de page
    ///   - limit: Nombre de résultats par page
    /// - Returns: Liste de recettes correspondant à la recherche
    func searchRecipes(query: String, page: Int = 1, limit: Int = 20) async throws -> [Recipe] {
        let offset = (page - 1) * limit
        var descriptor = FetchDescriptor<Recipe>(
            predicate: #Predicate { recipe in
                recipe.title.localizedStandardContains(query)
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset

        return try modelContext.fetch(descriptor)
    }
}
