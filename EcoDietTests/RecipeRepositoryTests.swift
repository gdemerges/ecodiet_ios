import XCTest
@testable import EcoDiet
import SwiftData

@MainActor
final class RecipeRepositoryTests: XCTestCase {
    var modelContext: ModelContext!
    var repository: RecipeRepository!

    override func setUp() async throws {
        try await super.setUp()

        // Créer un conteneur en mémoire pour les tests
        let schema = Schema([Recipe.self, RecipeFolder.self, UserProfile.self, Ingredient.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: config)
        modelContext = ModelContext(container)
        repository = RecipeRepository(modelContext: modelContext)

        // Attendre que le repository charge
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconde
    }

    override func tearDown() async throws {
        modelContext = nil
        repository = nil
        try await super.tearDown()
    }

    // MARK: - Tests d'ajout

    func testAddRecipe() throws {
        // Given
        let recipe = Recipe(
            title: "Pasta Carbonara",
            subtitle: "Italian classic",
            imageName: "pasta",
            carbonFootprint: 800
        )

        // When
        try repository.addRecipe(recipe)

        // Then
        XCTAssertEqual(repository.recipes.count, 1)
        XCTAssertEqual(repository.recipes.first?.title, "Pasta Carbonara")
        XCTAssertEqual(repository.recipes.first?.carbonFootprint, 800)
    }

    func testAddMultipleRecipes() throws {
        // Given
        let recipe1 = Recipe(title: "Recipe 1", subtitle: "Sub 1", imageName: "img1")
        let recipe2 = Recipe(title: "Recipe 2", subtitle: "Sub 2", imageName: "img2")
        let recipe3 = Recipe(title: "Recipe 3", subtitle: "Sub 3", imageName: "img3")

        // When
        try repository.addRecipe(recipe1)
        try repository.addRecipe(recipe2)
        try repository.addRecipe(recipe3)

        // Then
        XCTAssertEqual(repository.recipes.count, 3)
    }

    // MARK: - Tests de suppression

    func testDeleteRecipe() throws {
        // Given
        let recipe = Recipe(title: "To Delete", subtitle: "Test", imageName: "test")
        try repository.addRecipe(recipe)
        XCTAssertEqual(repository.recipes.count, 1)

        // When
        try repository.deleteRecipe(recipe)

        // Then
        XCTAssertEqual(repository.recipes.count, 0)
    }

    // MARK: - Tests de pagination

    func testFetchRecipesWithPagination() async throws {
        // Given - Ajouter 50 recettes
        for i in 1...50 {
            let recipe = Recipe(
                title: "Recipe \(i)",
                subtitle: "Subtitle \(i)",
                imageName: "image\(i)"
            )
            try repository.addRecipe(recipe)
        }

        // When - Récupérer page 1 (20 items)
        let page1 = try await repository.fetchRecipes(page: 1, limit: 20)

        // Then
        XCTAssertEqual(page1.count, 20, "La première page devrait contenir 20 recettes")

        // When - Récupérer page 2
        let page2 = try await repository.fetchRecipes(page: 2, limit: 20)

        // Then
        XCTAssertEqual(page2.count, 20, "La deuxième page devrait contenir 20 recettes")

        // When - Récupérer page 3 (10 items restants)
        let page3 = try await repository.fetchRecipes(page: 3, limit: 20)

        // Then
        XCTAssertEqual(page3.count, 10, "La troisième page devrait contenir 10 recettes")

        // When - Récupérer page 4 (vide)
        let page4 = try await repository.fetchRecipes(page: 4, limit: 20)

        // Then
        XCTAssertEqual(page4.count, 0, "La quatrième page devrait être vide")
    }

    func testFetchRecipesWithCustomPageSize() async throws {
        // Given
        for i in 1...25 {
            let recipe = Recipe(title: "Recipe \(i)", subtitle: "Sub", imageName: "img")
            try repository.addRecipe(recipe)
        }

        // When - Utiliser une taille de page de 10
        let page1 = try await repository.fetchRecipes(page: 1, limit: 10)
        let page2 = try await repository.fetchRecipes(page: 2, limit: 10)
        let page3 = try await repository.fetchRecipes(page: 3, limit: 10)

        // Then
        XCTAssertEqual(page1.count, 10)
        XCTAssertEqual(page2.count, 10)
        XCTAssertEqual(page3.count, 5)
    }

    // MARK: - Tests de recherche

    func testSearchRecipes() async throws {
        // Given
        try repository.addRecipe(Recipe(title: "Pasta Carbonara", subtitle: "Italian", imageName: "pasta"))
        try repository.addRecipe(Recipe(title: "Pasta Bolognese", subtitle: "Italian", imageName: "pasta2"))
        try repository.addRecipe(Recipe(title: "Chicken Curry", subtitle: "Indian", imageName: "curry"))
        try repository.addRecipe(Recipe(title: "Beef Stew", subtitle: "American", imageName: "stew"))

        // When - Rechercher "pasta"
        let pastaResults = try await repository.searchRecipes(query: "pasta", page: 1, limit: 20)

        // Then
        XCTAssertEqual(pastaResults.count, 2, "Devrait trouver 2 recettes avec 'pasta'")
        XCTAssertTrue(pastaResults.allSatisfy { $0.title.localizedCaseInsensitiveContains("pasta") })

        // When - Rechercher "chicken"
        let chickenResults = try await repository.searchRecipes(query: "chicken", page: 1, limit: 20)

        // Then
        XCTAssertEqual(chickenResults.count, 1, "Devrait trouver 1 recette avec 'chicken'")
        XCTAssertEqual(chickenResults.first?.title, "Chicken Curry")

        // When - Rechercher quelque chose qui n'existe pas
        let emptyResults = try await repository.searchRecipes(query: "pizza", page: 1, limit: 20)

        // Then
        XCTAssertEqual(emptyResults.count, 0, "Ne devrait trouver aucune recette avec 'pizza'")
    }

    func testSearchRecipesWithPagination() async throws {
        // Given - Créer 25 recettes contenant "test"
        for i in 1...25 {
            try repository.addRecipe(Recipe(title: "Test Recipe \(i)", subtitle: "Sub", imageName: "img"))
        }
        // Ajouter quelques recettes sans "test"
        try repository.addRecipe(Recipe(title: "Other Recipe", subtitle: "Sub", imageName: "img"))

        // When
        let page1 = try await repository.searchRecipes(query: "test", page: 1, limit: 10)
        let page2 = try await repository.searchRecipes(query: "test", page: 2, limit: 10)
        let page3 = try await repository.searchRecipes(query: "test", page: 3, limit: 10)

        // Then
        XCTAssertEqual(page1.count, 10)
        XCTAssertEqual(page2.count, 10)
        XCTAssertEqual(page3.count, 5)
    }

    // MARK: - Tests de chargement

    func testLoadAllRecipes() async throws {
        // Given
        for i in 1...30 {
            try repository.addRecipe(Recipe(title: "Recipe \(i)", subtitle: "Sub", imageName: "img"))
        }

        // When
        await repository.loadAllRecipes()

        // Then
        XCTAssertEqual(repository.recipes.count, 30, "Devrait charger toutes les 30 recettes")
    }
}
