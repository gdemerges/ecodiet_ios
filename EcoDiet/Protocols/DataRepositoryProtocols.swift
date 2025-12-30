import Foundation
import SwiftData

// MARK: - Recipe Repository Protocol

protocol RecipeRepositoryProtocol {
    var recipes: [Recipe] { get }

    func fetchRecipes(page: Int, limit: Int) async throws -> [Recipe]
    func addRecipe(_ recipe: Recipe) throws
    func deleteRecipe(_ recipe: Recipe) throws
    func searchRecipes(query: String, page: Int, limit: Int) async throws -> [Recipe]
}

// MARK: - Folder Repository Protocol

protocol FolderRepositoryProtocol {
    var folders: [RecipeFolder] { get }

    func fetchFolders() async throws -> [RecipeFolder]
    func addFolder(_ folder: RecipeFolder) throws
    func deleteFolder(_ folder: RecipeFolder) throws
    func addRecipe(_ recipe: Recipe, to folder: RecipeFolder) throws
    func removeRecipe(_ recipe: Recipe, from folder: RecipeFolder) throws
}

// MARK: - User Profile Repository Protocol

protocol UserProfileRepositoryProtocol {
    var currentProfile: UserProfile? { get }

    func fetchProfile() async throws -> UserProfile?
    func updateProfile(_ profile: UserProfile) throws
    func addFavorite(_ recipe: Recipe) throws
    func removeFavorite(_ recipe: Recipe) throws
    func isFavorite(_ recipe: Recipe) -> Bool
}

// MARK: - Ingredient Repository Protocol

protocol IngredientRepositoryProtocol {
    var ingredients: [Ingredient] { get }

    func fetchIngredients(page: Int, limit: Int) async throws -> [Ingredient]
    func addIngredient(_ ingredient: Ingredient) throws
    func removeIngredient(_ ingredient: Ingredient) throws
    func updateIngredient(_ ingredient: Ingredient) throws
}
