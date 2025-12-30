import Foundation
import SwiftData
import Observation

@Observable
class FolderRepository: FolderRepositoryProtocol {
    private let modelContext: ModelContext
    private(set) var folders: [RecipeFolder] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Public Methods

    /// Récupère tous les dossiers
    func fetchFolders() async throws -> [RecipeFolder] {
        let descriptor = FetchDescriptor<RecipeFolder>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Charge les dossiers pour un profil utilisateur
    func loadFolders(for profile: UserProfile) {
        folders = profile.folders.sorted { $0.timestamp > $1.timestamp }
    }

    /// Ajoute un nouveau dossier
    func addFolder(_ folder: RecipeFolder) throws {
        modelContext.insert(folder)
        try modelContext.save()
        folders.append(folder)
    }

    /// Supprime un dossier
    func deleteFolder(_ folder: RecipeFolder) throws {
        modelContext.delete(folder)
        try modelContext.save()
        folders.removeAll { $0.id == folder.id }
    }

    /// Ajoute une recette à un dossier
    func addRecipe(_ recipe: Recipe, to folder: RecipeFolder) throws {
        if !folder.recipes.contains(where: { $0.id == recipe.id }) {
            folder.recipes.append(recipe)
            try modelContext.save()
        }
    }

    /// Retire une recette d'un dossier
    func removeRecipe(_ recipe: Recipe, from folder: RecipeFolder) throws {
        folder.recipes.removeAll { $0.id == recipe.id }
        try modelContext.save()
    }
}
