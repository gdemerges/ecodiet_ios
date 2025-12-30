import SwiftUI
import SwiftData

@Observable
class FridgeManager {
    private var modelContext: ModelContext
    var ingredients: [Ingredient] = []

    // Cache pour les ingredients dans le frigo (optimisation)
    private var fridgeIngredientsCache: Set<String> = []
    private var needsCacheRefresh = true

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadIngredients()
    }

    func loadIngredients() {
        let descriptor = FetchDescriptor<Ingredient>(
            sortBy: [SortDescriptor(\.name)]
        )

        do {
            let fetchedIngredients = try modelContext.fetch(descriptor)
            ingredients = fetchedIngredients
            refreshCache()
        } catch {
            print("Erreur lors du chargement des ingredients: \(error)")
            ingredients = []
        }
    }

    private func refreshCache() {
        fridgeIngredientsCache = Set(
            ingredients.filter { $0.isInFridge }.map { $0.name.lowercased() }
        )
        needsCacheRefresh = false
    }

    func addIngredient(_ ingredient: Ingredient) {
        modelContext.insert(ingredient)

        do {
            try modelContext.save()
            // Mise a jour incrementale au lieu de recharger tout
            ingredients.append(ingredient)
            ingredients.sort { $0.name < $1.name }
            if ingredient.isInFridge {
                fridgeIngredientsCache.insert(ingredient.name.lowercased())
            }
        } catch {
            print("Erreur lors de la sauvegarde de l'ingredient: \(error)")
        }
    }

    func removeIngredient(_ ingredient: Ingredient) {
        modelContext.delete(ingredient)

        do {
            try modelContext.save()
            // Mise a jour incrementale
            ingredients.removeAll { $0.id == ingredient.id }
            fridgeIngredientsCache.remove(ingredient.name.lowercased())
        } catch {
            print("Erreur lors de la suppression de l'ingredient: \(error)")
        }
    }

    func updateIngredient(_ ingredient: Ingredient) {
        do {
            try modelContext.save()
            // Mettre a jour le cache si necessaire
            if ingredient.isInFridge {
                fridgeIngredientsCache.insert(ingredient.name.lowercased())
            } else {
                fridgeIngredientsCache.remove(ingredient.name.lowercased())
            }
        } catch {
            print("Erreur lors de la mise a jour de l'ingredient: \(error)")
        }
    }

    func toggleFridgeStatus(_ ingredient: Ingredient) {
        ingredient.isInFridge.toggle()

        do {
            try modelContext.save()
            // Mise a jour du cache
            if ingredient.isInFridge {
                fridgeIngredientsCache.insert(ingredient.name.lowercased())
            } else {
                fridgeIngredientsCache.remove(ingredient.name.lowercased())
            }
        } catch {
            print("Erreur lors de la mise a jour du statut: \(error)")
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
            Ingredient(name: "Epinards", category: .vegetable, unit: .gram, imageName: "leaf.fill"),
            Ingredient(name: "Potiron", category: .vegetable, unit: .kilogram, imageName: "circle.fill"),
            Ingredient(name: "Laitue romaine", category: .vegetable, unit: .piece, imageName: "leaf.fill"),

            // Fruits
            Ingredient(name: "Avocat", category: .fruit, unit: .piece, imageName: "circle.fill"),
            Ingredient(name: "Citron", category: .fruit, unit: .piece, imageName: "circle.fill"),
            Ingredient(name: "Basilic", category: .vegetable, unit: .piece, imageName: "leaf.fill"),

            // Proteines
            Ingredient(name: "Poulet", category: .protein, unit: .gram, imageName: "fish.fill"),
            Ingredient(name: "Pois chiches", category: .protein, unit: .gram, imageName: "circle.fill"),
            Ingredient(name: "Oeufs", category: .protein, unit: .piece, imageName: "circle.fill"),
            Ingredient(name: "Anchois", category: .protein, unit: .piece, imageName: "fish.fill"),

            // Produits laitiers
            Ingredient(name: "Parmesan", category: .dairy, unit: .gram, imageName: "square.fill"),
            Ingredient(name: "Lait de coco", category: .dairy, unit: .milliliter, imageName: "cup.and.saucer.fill"),

            // Cereales
            Ingredient(name: "Quinoa", category: .grain, unit: .gram, imageName: "leaf.fill"),
            Ingredient(name: "Pates completes", category: .grain, unit: .gram, imageName: "circle.fill"),
            Ingredient(name: "Croutons", category: .grain, unit: .gram, imageName: "square.fill"),

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
            Ingredient(name: "Bouillon de legumes", category: .other, unit: .milliliter, imageName: "drop.fill")
        ]
    }
}
