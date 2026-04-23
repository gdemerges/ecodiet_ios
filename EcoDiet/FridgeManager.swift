import SwiftUI
import SwiftData

@Observable
class FridgeManager {
    private var modelContext: ModelContext

    // MARK: - Repository (Phase 3)
    // Exposé en internal pour injection Environment
    internal let ingredientRepo: IngredientRepository

    // Exposer les ingredients depuis le repository pour compatibilité
    var ingredients: [Ingredient] {
        ingredientRepo.ingredients
    }

    // Cache pour les ingredients dans le frigo (optimisation)
    private var fridgeIngredientsCache: Set<String> = []
    private var needsCacheRefresh = true

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.ingredientRepo = IngredientRepository(modelContext: modelContext)

        // Attendre que le repository ait fini de charger ses données
        Task {
            await ingredientRepo.waitForLoad()
            await MainActor.run {
                refreshCache()
            }
        }
    }

    @MainActor
    func loadIngredients() {
        // Déléguer au repository
        Task {
            await ingredientRepo.loadAllIngredients()
            refreshCache()
        }
    }

    private func refreshCache() {
        fridgeIngredientsCache = Set(
            ingredients.filter { $0.isInFridge }.map { $0.name.lowercased() }
        )
        needsCacheRefresh = false
    }

    @MainActor
    func addIngredient(_ ingredient: Ingredient) {
        // Déléguer au repository
        do {
            try ingredientRepo.addIngredient(ingredient)
            // Mise à jour du cache
            if ingredient.isInFridge {
                fridgeIngredientsCache.insert(ingredient.name.lowercased())
            }
        } catch {
            Logger.dataError("Erreur lors de la sauvegarde de l'ingrédient", error: error)
        }
    }

    @MainActor
    func removeIngredient(_ ingredient: Ingredient) {
        // Déléguer au repository
        do {
            try ingredientRepo.removeIngredient(ingredient)
            // Mise à jour du cache
            fridgeIngredientsCache.remove(ingredient.name.lowercased())
        } catch {
            Logger.dataError("Erreur lors de la suppression de l'ingrédient", error: error)
        }
    }

    @MainActor
    func updateIngredient(_ ingredient: Ingredient) {
        // Déléguer au repository
        do {
            try ingredientRepo.updateIngredient(ingredient)
            // Mettre à jour le cache si nécessaire
            if ingredient.isInFridge {
                fridgeIngredientsCache.insert(ingredient.name.lowercased())
            } else {
                fridgeIngredientsCache.remove(ingredient.name.lowercased())
            }
        } catch {
            Logger.dataError("Erreur lors de la mise à jour de l'ingrédient", error: error)
        }
    }

    @MainActor
    func toggleFridgeStatus(_ ingredient: Ingredient) {
        ingredient.isInFridge.toggle()

        // Déléguer au repository
        do {
            try ingredientRepo.updateIngredient(ingredient)
            // Mise à jour du cache
            if ingredient.isInFridge {
                fridgeIngredientsCache.insert(ingredient.name.lowercased())
            } else {
                fridgeIngredientsCache.remove(ingredient.name.lowercased())
            }
        } catch {
            Logger.dataError("Erreur lors de la mise à jour du statut", error: error)
        }
    }

    func ingredientsInFridge() -> [Ingredient] {
        return ingredients.filter { $0.isInFridge }
    }

    func hasIngredient(named name: String) -> Bool {
        // Utiliser le cache pour une recherche plus rapide
        let searchName = name.lowercased()
        return fridgeIngredientsCache.contains { cachedName in
            cachedName.contains(searchName) || searchName.contains(cachedName)
        }
    }

    func missingIngredients(for recipe: Recipe) -> [RecipeIngredient] {
        let requiredIngredients = recipe.requiredIngredients
        return requiredIngredients.filter { recipeIngredient in
            !hasIngredient(named: recipeIngredient.name)
        }
    }

    func canMakeRecipe(_ recipe: Recipe, allowMissing: Int = 0) -> Bool {
        let missing = missingIngredients(for: recipe)
        return missing.count <= allowMissing
    }

    func matchPercentage(for recipe: Recipe) -> Double {
        let required = recipe.requiredIngredients.filter { !$0.isOptional }
        guard !required.isEmpty else { return 0 }

        let available = required.filter { recipeIngredient in
            hasIngredient(named: recipeIngredient.name)
        }

        return Double(available.count) / Double(required.count)
    }

    // Ingredients populaires pre-definis
    static func popularIngredients() -> [Ingredient] {
        return [
            // Legumes
            Ingredient(name: "Tomates", category: .vegetable, unit: .piece, imageName: "circle.fill"),
            Ingredient(name: "Carottes", category: .vegetable, unit: .piece, imageName: "carrot.fill"),
            Ingredient(name: "Oignon", category: .vegetable, unit: .piece, imageName: "circle.fill"),
            Ingredient(name: "Ail", category: .vegetable, unit: .piece, imageName: "circle.fill"),
            Ingredient(name: "Épinards", category: .vegetable, unit: .gram, imageName: "leaf.fill"),
            Ingredient(name: "Potiron", category: .vegetable, unit: .kilogram, imageName: "circle.fill"),
            Ingredient(name: "Laitue romaine", category: .vegetable, unit: .piece, imageName: "leaf.fill"),

            // Fruits
            Ingredient(name: "Avocat", category: .fruit, unit: .piece, imageName: "circle.fill"),
            Ingredient(name: "Citron", category: .fruit, unit: .piece, imageName: "circle.fill"),
            Ingredient(name: "Basilic", category: .vegetable, unit: .piece, imageName: "leaf.fill"),

            // Proteines
            Ingredient(name: "Poulet", category: .protein, unit: .gram, imageName: "fish.fill"),
            Ingredient(name: "Pois chiches", category: .protein, unit: .gram, imageName: "circle.fill"),
            Ingredient(name: "Œufs", category: .protein, unit: .piece, imageName: "circle.fill"),
            Ingredient(name: "Anchois", category: .protein, unit: .piece, imageName: "fish.fill"),

            // Produits laitiers
            Ingredient(name: "Parmesan", category: .dairy, unit: .gram, imageName: "square.fill"),
            Ingredient(name: "Lait de coco", category: .dairy, unit: .milliliter, imageName: "cup.and.saucer.fill"),

            // Cereales
            Ingredient(name: "Quinoa", category: .grain, unit: .gram, imageName: "leaf.fill"),
            Ingredient(name: "Pâtes complètes", category: .grain, unit: .gram, imageName: "circle.fill"),
            Ingredient(name: "Croûtons", category: .grain, unit: .gram, imageName: "square.fill"),

            // Huiles et condiments
            Ingredient(name: "Huile d'olive", category: .oil, unit: .milliliter, imageName: "drop.fill"),

            // Epices
            Ingredient(name: "Gingembre", category: .spice, unit: .gram, imageName: "sparkles"),
            Ingredient(name: "Curcuma", category: .spice, unit: .teaspoon, imageName: "sparkles"),
            Ingredient(name: "Curry", category: .spice, unit: .teaspoon, imageName: "sparkles"),
            Ingredient(name: "Sel", category: .spice, unit: .teaspoon, imageName: "sparkles"),
            Ingredient(name: "Poivre", category: .spice, unit: .teaspoon, imageName: "sparkles"),

            // Autres
            Ingredient(name: "Graines de tournesol", category: .other, unit: .gram, imageName: "circle.fill"),
            Ingredient(name: "Bouillon de légumes", category: .other, unit: .milliliter, imageName: "drop.fill")
        ]
    }
}
