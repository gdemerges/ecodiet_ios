import Foundation

class RecommendationService: RecommendationServiceProtocol {

    /// Retourne les recettes recommandées selon les préférences de l'utilisateur
    /// - Parameters:
    ///   - profile: Profil utilisateur
    ///   - recipes: Liste de recettes disponibles
    /// - Returns: Recettes filtrées selon les préférences alimentaires et allergies
    func getRecommendedRecipes(for profile: UserProfile, from recipes: [Recipe]) -> [Recipe] {
        let preferences = profile.dietaryPreferences
        let allergies = profile.allergies

        return recipes.filter { recipe in
            // Filtrer les recettes contenant des allergènes
            let hasAllergen = recipe.allergens.contains { allergen in
                allergies.contains(allergen)
            }

            if hasAllergen {
                return false
            }

            // Favoriser les recettes correspondant aux préférences alimentaires
            let matchesPreferences = preferences.contains { preference in
                recipe.dietaryTags.contains(preference)
            }

            // Retourner les recettes qui correspondent aux préférences
            // ou qui n'ont pas de tags (neutres)
            return matchesPreferences || recipe.dietaryTags.isEmpty
        }
    }
}
