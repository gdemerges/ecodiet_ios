import Foundation
import SwiftData

@Model
final class Recipe: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    var title: String
    var subtitle: String
    var imageName: String
    var timestamp: Date
    
    // Relations
    var folders: [RecipeFolder] = []
    var userProfiles: [UserProfile] = [] // Pour les favoris
    
    init(title: String, subtitle: String, imageName: String) {
        self.id = UUID()
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.timestamp = Date()
    }
    
    // Pour la compatibilité Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
}

@Model
final class RecipeFolder: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    var title: String
    var imageName: String
    var timestamp: Date
    
    // Relations
    @Relationship(deleteRule: .nullify, inverse: \Recipe.folders)
    var recipes: [Recipe] = []
    
    init(title: String, imageName: String = "folder") {
        self.id = UUID()
        self.title = title
        self.imageName = imageName
        self.timestamp = Date()
    }
    
    // Pour la compatibilité Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: RecipeFolder, rhs: RecipeFolder) -> Bool {
        lhs.id == rhs.id
    }
}

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    var email: String
    var profileImageName: String
    var dietaryPreferences: [String] = []
    var allergies: [String] = []
    var cookingLevel: CookingLevel
    var joinDate: Date
    
    // Relations
    @Relationship(deleteRule: .nullify, inverse: \Recipe.userProfiles)
    var favoriteRecipes: [Recipe] = []
    
    init(name: String = "", email: String = "", profileImageName: String = "person.crop.circle.fill", cookingLevel: CookingLevel = .beginner) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.profileImageName = profileImageName
        self.cookingLevel = cookingLevel
        self.joinDate = Date()
    }
}

enum CookingLevel: String, CaseIterable, Codable {
    case beginner = "Débutant"
    case intermediate = "Intermédiaire"
    case advanced = "Avancé"
    case expert = "Expert"
}
