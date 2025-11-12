import Foundation
import SwiftData

@Model
final class Recipe: Identifiable, Hashable {
    @Attribute(.unique) var id: UUID
    var title: String
    var subtitle: String
    var imageName: String
    var timestamp: Date
    var carbonFootprint: Double // Empreinte carbone en g CO2eq par portion
    var preparationTime: Int // Temps de préparation en minutes
    var dietaryTags: [String] = [] // Tags: "Végétarien", "Vegan", "Sans gluten", "Sans lactose", etc.
    var allergens: [String] = [] // Allergènes: "Fruits à coque", "Gluten", "Lactose", "Œufs", etc.
    
    // Relations
    var folders: [RecipeFolder] = []
    var userProfiles: [UserProfile] = [] // Pour les favoris
    
    init(title: String, subtitle: String, imageName: String, carbonFootprint: Double = 1000, preparationTime: Int = 30, dietaryTags: [String] = [], allergens: [String] = []) {
        self.id = UUID()
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.timestamp = Date()
        self.carbonFootprint = carbonFootprint
        self.preparationTime = preparationTime
        self.dietaryTags = dietaryTags
        self.allergens = allergens
    }
    
    // Calcul de l'Eco-Score basé sur l'empreinte carbone
    var ecoScore: EcoScore {
        EcoScore.fromCarbonFootprint(carbonFootprint)
    }
    
    // Pour la compatibilité Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        lhs.id == rhs.id
    }
}

// Système d'Eco-Score similaire au Nutri-Score
enum EcoScore: String, CaseIterable {
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"
    case e = "E"
    
    // Calcul de l'Eco-Score basé sur les émissions de CO2 (en grammes par portion)
    static func fromCarbonFootprint(_ carbonFootprint: Double) -> EcoScore {
        switch carbonFootprint {
        case ..<500:        // Moins de 500g CO2eq : Excellent
            return .a
        case 500..<1000:    // 500-1000g CO2eq : Bon
            return .b
        case 1000..<2000:   // 1-2kg CO2eq : Moyen
            return .c
        case 2000..<3500:   // 2-3.5kg CO2eq : Médiocre
            return .d
        default:            // Plus de 3.5kg CO2eq : Mauvais
            return .e
        }
    }
    
    // Couleur associée à chaque score
    var color: String {
        switch self {
        case .a: return "ecoscore_a"  // Vert foncé
        case .b: return "ecoscore_b"  // Vert clair
        case .c: return "ecoscore_c"  // Jaune
        case .d: return "ecoscore_d"  // Orange
        case .e: return "ecoscore_e"  // Rouge
        }
    }
    
    // Couleur SwiftUI
    var swiftUIColor: (red: Double, green: Double, blue: Double) {
        switch self {
        case .a: return (0.0, 0.6, 0.2)   // Vert foncé
        case .b: return (0.4, 0.8, 0.2)   // Vert clair
        case .c: return (1.0, 0.8, 0.0)   // Jaune
        case .d: return (1.0, 0.5, 0.0)   // Orange
        case .e: return (0.9, 0.2, 0.1)   // Rouge
        }
    }
    
    // Description du score
    var description: String {
        switch self {
        case .a: return "Très faible impact"
        case .b: return "Faible impact"
        case .c: return "Impact modéré"
        case .d: return "Impact élevé"
        case .e: return "Impact très élevé"
        }
    }
    
    // Emoji associé
    var emoji: String {
        switch self {
        case .a: return "🌱"
        case .b: return "🍃"
        case .c: return "⚠️"
        case .d: return "🔶"
        case .e: return "🔴"
        }
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
    
    // Lien avec l'utilisateur propriétaire
    var owner: UserProfile?
    
    init(title: String, imageName: String = "folder", owner: UserProfile? = nil) {
        self.id = UUID()
        self.title = title
        self.imageName = imageName
        self.timestamp = Date()
        self.owner = owner
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
    
    @Relationship(deleteRule: .cascade, inverse: \RecipeFolder.owner)
    var folders: [RecipeFolder] = []
    
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
