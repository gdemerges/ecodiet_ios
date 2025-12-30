import SwiftUI

// MARK: - Recipe Repository

private struct RecipeRepositoryKey: EnvironmentKey {
    static let defaultValue: RecipeRepositoryProtocol? = nil
}

extension EnvironmentValues {
    var recipeRepository: RecipeRepositoryProtocol? {
        get { self[RecipeRepositoryKey.self] }
        set { self[RecipeRepositoryKey.self] = newValue }
    }
}

// MARK: - Folder Repository

private struct FolderRepositoryKey: EnvironmentKey {
    static let defaultValue: FolderRepositoryProtocol? = nil
}

extension EnvironmentValues {
    var folderRepository: FolderRepositoryProtocol? {
        get { self[FolderRepositoryKey.self] }
        set { self[FolderRepositoryKey.self] = newValue }
    }
}

// MARK: - User Profile Repository

private struct UserProfileRepositoryKey: EnvironmentKey {
    static let defaultValue: UserProfileRepositoryProtocol? = nil
}

extension EnvironmentValues {
    var profileRepository: UserProfileRepositoryProtocol? {
        get { self[UserProfileRepositoryKey.self] }
        set { self[UserProfileRepositoryKey.self] = newValue }
    }
}

// MARK: - Ingredient Repository

private struct IngredientRepositoryKey: EnvironmentKey {
    static let defaultValue: IngredientRepositoryProtocol? = nil
}

extension EnvironmentValues {
    var ingredientRepository: IngredientRepositoryProtocol? {
        get { self[IngredientRepositoryKey.self] }
        set { self[IngredientRepositoryKey.self] = newValue }
    }
}

// MARK: - Recommendation Service

private struct RecommendationServiceKey: EnvironmentKey {
    static let defaultValue: RecommendationServiceProtocol? = nil
}

extension EnvironmentValues {
    var recommendationService: RecommendationServiceProtocol? {
        get { self[RecommendationServiceKey.self] }
        set { self[RecommendationServiceKey.self] = newValue }
    }
}
