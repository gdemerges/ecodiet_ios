import Foundation
import SwiftData

class DefaultDataService: DefaultDataServiceProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Public Methods

    /// Crée un profil utilisateur par défaut
    func createDefaultUserProfile() async throws {
        let profile = UserProfile(
            name: "Guillaume",
            email: "guillaume@email.com"
        )

        profile.dietaryPreferences = ["Végétarien", "Bio", "Local"]
        profile.allergies = ["Fruits à coque"]
        profile.cookingLevel = .intermediate

        modelContext.insert(profile)
        try modelContext.save()
    }

    /// Crée des recettes par défaut
    func createDefaultRecipes() async throws {
        // Bowl veggie
        let bowlVeggie = Recipe(
            title: "Bowl veggie",
            subtitle: "Protéines végétales",
            imageName: "leaf",
            carbonFootprint: 350,
            preparationTime: 15,
            dietaryTags: ["Végétarien", "Vegan", "Sans gluten"],
            allergens: []
        )

        // Poke bowl saumon
        let pokeBowl = Recipe(
            title: "Poke bowl saumon",
            subtitle: "Recette hawaïenne",
            imageName: "fish",
            carbonFootprint: 1200,
            preparationTime: 20,
            dietaryTags: ["Sans gluten"],
            allergens: ["Poisson"]
        )

        modelContext.insert(bowlVeggie)
        modelContext.insert(pokeBowl)
        try modelContext.save()
    }

    /// Crée des dossiers par défaut pour un profil
    func createDefaultFolders(for profile: UserProfile) async throws {
        let defaultFolders = [
            RecipeFolder(title: "Recettes sport", imageName: "figure.run", colorHex: "#EF4444", owner: profile),
            RecipeFolder(title: "Recettes hiver", imageName: "snowflake", colorHex: "#60A5FA", owner: profile),
            RecipeFolder(title: "Végétarien", imageName: "leaf.fill", colorHex: "#10B981", owner: profile)
        ]

        for folder in defaultFolders {
            modelContext.insert(folder)
            profile.folders.append(folder)
        }

        try modelContext.save()
    }
}
