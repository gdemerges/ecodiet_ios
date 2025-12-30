import Foundation

// MARK: - Default Data Service Protocol

protocol DefaultDataServiceProtocol {
    func createDefaultUserProfile() async throws
    func createDefaultRecipes() async throws
    func createDefaultFolders(for profile: UserProfile) async throws
}

// MARK: - Recommendation Service Protocol

protocol RecommendationServiceProtocol {
    func getRecommendedRecipes(for profile: UserProfile, from recipes: [Recipe]) -> [Recipe]
}
