import SwiftUI
import SwiftData

@Observable
class FridgeManager {
    private var modelContext: ModelContext
    var ingredients: [Ingredient] = []
    
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
            // Important: mettre à jour la propriété pour déclencher la mise à jour de l'UI
            ingredients = fetchedIngredients
        } catch {
            print("❌ Erreur lors du chargement des ingrédients: \(error)")
            ingredients = []
        }
    }
    
    func addIngredient(_ ingredient: Ingredient) {
        modelContext.insert(ingredient)
        
        // Sauvegarder immédiatement
        do {
            try modelContext.save()
        } catch {
            print("❌ Erreur lors de la sauvegarde de l'ingrédient: \(error)")
        }
        
        // Recharger pour mettre à jour la liste
        loadIngredients()
    }
    
    func removeIngredient(_ ingredient: Ingredient) {
        modelContext.delete(ingredient)
        
        // Sauvegarder immédiatement
        do {
            try modelContext.save()
        } catch {
            print("❌ Erreur lors de la suppression de l'ingrédient: \(error)")
        }
        
        // Recharger pour mettre à jour la liste
        loadIngredients()
    }
    
    func updateIngredient(_ ingredient: Ingredient) {
        // Sauvegarder immédiatement
        do {
            try modelContext.save()
        } catch {
            print("❌ Erreur lors de la mise à jour de l'ingrédient: \(error)")
        }
        
        // Recharger pour mettre à jour la liste
        loadIngredients()
    }
    
    func toggleFridgeStatus(_ ingredient: Ingredient) {
        ingredient.isInFridge.toggle()
        
        // Sauvegarder immédiatement
        do {
            try modelContext.save()
        } catch {
            print("❌ Erreur lors de la mise à jour du statut: \(error)")
        }
        
        // Recharger pour mettre à jour la liste
        loadIngredients()
    }
    
    func ingredientsInFridge() -> [Ingredient] {
        return ingredients.filter { $0.isInFridge }
    }
    
    func hasIngredient(named name: String) -> Bool {
        return ingredients.contains { $0.name.lowercased().contains(name.lowercased()) && $0.isInFridge }
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
    
    // Ingrédients populaires pré-définis
    static func popularIngredients() -> [Ingredient] {
        return [
            // Légumes
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
            
            // Protéines
            Ingredient(name: "Poulet", category: .protein, unit: .gram, imageName: "fish.fill"),
            Ingredient(name: "Pois chiches", category: .protein, unit: .gram, imageName: "circle.fill"),
            Ingredient(name: "Œufs", category: .protein, unit: .piece, imageName: "circle.fill"),
            Ingredient(name: "Anchois", category: .protein, unit: .piece, imageName: "fish.fill"),
            
            // Produits laitiers
            Ingredient(name: "Parmesan", category: .dairy, unit: .gram, imageName: "square.fill"),
            Ingredient(name: "Lait de coco", category: .dairy, unit: .milliliter, imageName: "cup.and.saucer.fill"),
            
            // Céréales
            Ingredient(name: "Quinoa", category: .grain, unit: .gram, imageName: "leaf.fill"),
            Ingredient(name: "Pâtes complètes", category: .grain, unit: .gram, imageName: "circle.fill"),
            Ingredient(name: "Croûtons", category: .grain, unit: .gram, imageName: "square.fill"),
            
            // Huiles et condiments
            Ingredient(name: "Huile d'olive", category: .oil, unit: .milliliter, imageName: "drop.fill"),
            
            // Épices
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
