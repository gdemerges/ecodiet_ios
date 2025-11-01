import Foundation

struct Recipe: Identifiable, Hashable, Codable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
}

struct RecipeFolder: Identifiable, Hashable, Codable {
    let id = UUID()
    var title: String
    var recipes: [Recipe]
    var imageName: String
    
    init(title: String, recipes: [Recipe] = [], imageName: String = "folder") {
        self.title = title
        self.recipes = recipes
        self.imageName = imageName
    }
}

struct UserProfile: Codable {
    var name: String
    var email: String
    var profileImageName: String
    var favoriteRecipes: [Recipe]
    var dietaryPreferences: [String]
    var allergies: [String]
    var cookingLevel: CookingLevel
    var joinDate: Date
    
    init(name: String = "", email: String = "", profileImageName: String = "person.crop.circle.fill") {
        self.name = name
        self.email = email
        self.profileImageName = profileImageName
        self.favoriteRecipes = []
        self.dietaryPreferences = []
        self.allergies = []
        self.cookingLevel = .beginner
        self.joinDate = Date()
    }
}

enum CookingLevel: String, CaseIterable, Codable {
    case beginner = "Débutant"
    case intermediate = "Intermédiaire"
    case advanced = "Avancé"
    case expert = "Expert"
}