import SwiftUI
import SwiftData
import Observation

@Observable
class UserProfileManager {
    private var dataManager: SwiftDataManager?
    
    var userProfile: UserProfile? {
        dataManager?.userProfile
    }
    
    init() {
        // L'initialisation sera faite quand le modelContext sera disponible
    }
    
    func configure(with dataManager: SwiftDataManager) {
        self.dataManager = dataManager
    }
    
    func addFavoriteRecipe(_ recipe: Recipe) {
        dataManager?.addFavoriteRecipe(recipe)
    }
    
    func removeFavoriteRecipe(_ recipe: Recipe) {
        dataManager?.removeFavoriteRecipe(recipe)
    }
    
    func isFavorite(_ recipe: Recipe) -> Bool {
        dataManager?.isFavorite(recipe) ?? false
    }
    
    func createProfileFromSignup(email: String, password: String, profile: UserProfile) {
        dataManager?.createProfileFromSignup(email: email, password: password, profile: profile)
    }
    
    func updateProfile(name: String, email: String, cookingLevel: CookingLevel, 
                      dietaryPreferences: [String], allergies: [String]) {
        dataManager?.updateProfile(
            name: name, 
            email: email, 
            cookingLevel: cookingLevel, 
            dietaryPreferences: dietaryPreferences, 
            allergies: allergies
        )
    }
    
    func clearAllData() {
        dataManager?.clearAllData()
    }
}
