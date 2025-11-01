import SwiftUI
import Observation

@Observable
class UserProfileManager {
    var userProfile: UserProfile {
        didSet {
            saveProfile()
        }
    }
    
    private let profileKey = "UserProfile"
    
    init() {
        self.userProfile = Self.loadProfile() ?? UserProfile(
            name: "Marie Dupont",
            email: "marie.dupont@email.com"
        )
        
        // Données d'exemple pour la démo
        if userProfile.favoriteRecipes.isEmpty {
            setupSampleData()
        }
    }
    
    private func setupSampleData() {
        userProfile.favoriteRecipes = [
            Recipe(title: "Bowl veggie", subtitle: "Protéines végétales", imageName: "leaf"),
            Recipe(title: "Salade césar", subtitle: "Poulet, parmesan", imageName: "fork.knife"),
            Recipe(title: "Soupe de saison", subtitle: "Potiron & coco", imageName: "cup.and.saucer")
        ]
        
        userProfile.dietaryPreferences = ["Végétarien", "Bio", "Local"]
        userProfile.allergies = ["Fruits à coque"]
        userProfile.cookingLevel = .intermediate
    }
    
    func addFavoriteRecipe(_ recipe: Recipe) {
        if !userProfile.favoriteRecipes.contains(recipe) {
            userProfile.favoriteRecipes.append(recipe)
        }
    }
    
    func removeFavoriteRecipe(_ recipe: Recipe) {
        userProfile.favoriteRecipes.removeAll { $0.id == recipe.id }
    }
    
    func isFavorite(_ recipe: Recipe) -> Bool {
        userProfile.favoriteRecipes.contains(recipe)
    }
    
    func updateProfile(name: String, email: String, cookingLevel: CookingLevel, 
                      dietaryPreferences: [String], allergies: [String]) {
        userProfile.name = name
        userProfile.email = email
        userProfile.cookingLevel = cookingLevel
        userProfile.dietaryPreferences = dietaryPreferences
        userProfile.allergies = allergies
    }
    
    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
    }
    
    private static func loadProfile() -> UserProfile? {
        if let data = UserDefaults.standard.data(forKey: "UserProfile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return decoded
        }
        return nil
    }
}