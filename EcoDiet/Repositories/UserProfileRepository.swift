import Foundation
import SwiftData
import Observation

@Observable
class UserProfileRepository: UserProfileRepositoryProtocol {
    private let modelContext: ModelContext
    private(set) var currentProfile: UserProfile?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        Task {
            try? await loadProfile()
        }
    }

    // MARK: - Public Methods

    /// Charge le profil utilisateur
    func fetchProfile() async throws -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>()
        let profiles = try modelContext.fetch(descriptor)
        currentProfile = profiles.first
        return currentProfile
    }

    /// Charge le profil (méthode privée async)
    private func loadProfile() async throws {
        _ = try await fetchProfile()
    }

    /// Met à jour le profil utilisateur
    func updateProfile(_ profile: UserProfile) throws {
        currentProfile = profile
        try modelContext.save()
    }

    /// Ajoute une recette aux favoris
    func addFavorite(_ recipe: Recipe) throws {
        guard let profile = currentProfile else { return }

        if !profile.favoriteRecipes.contains(where: { $0.id == recipe.id }) {
            profile.favoriteRecipes.append(recipe)
            try modelContext.save()
        }
    }

    /// Retire une recette des favoris
    func removeFavorite(_ recipe: Recipe) throws {
        guard let profile = currentProfile else { return }

        profile.favoriteRecipes.removeAll { $0.id == recipe.id }
        try modelContext.save()
    }

    /// Vérifie si une recette est dans les favoris
    func isFavorite(_ recipe: Recipe) -> Bool {
        guard let profile = currentProfile else { return false }
        return profile.favoriteRecipes.contains(where: { $0.id == recipe.id })
    }
}
