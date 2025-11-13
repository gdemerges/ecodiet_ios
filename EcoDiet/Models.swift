import Foundation
import SwiftUI
import SwiftData

// Extension pour les couleurs hex
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

// Structure pour représenter un ingrédient requis dans une recette
struct RecipeIngredient: Codable, Hashable {
    let name: String
    let quantity: Double
    let unit: String
    let isOptional: Bool
    
    init(name: String, quantity: Double, unit: String, isOptional: Bool = false) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.isOptional = isOptional
    }
}

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
    var ingredientsData: Data? // Stockage sérialisé des ingrédients
    
    // Relations
    var folders: [RecipeFolder] = []
    var userProfiles: [UserProfile] = [] // Pour les favoris
    
    init(title: String, subtitle: String, imageName: String, carbonFootprint: Double = 1000, preparationTime: Int = 30, dietaryTags: [String] = [], allergens: [String] = [], requiredIngredients: [RecipeIngredient] = []) {
        self.id = UUID()
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.timestamp = Date()
        self.carbonFootprint = carbonFootprint
        self.preparationTime = preparationTime
        self.dietaryTags = dietaryTags
        self.allergens = allergens
        self.requiredIngredients = requiredIngredients
    }
    
    // Computed property pour gérer les ingrédients
    var requiredIngredients: [RecipeIngredient] {
        get {
            guard let data = ingredientsData else { return [] }
            return (try? JSONDecoder().decode([RecipeIngredient].self, from: data)) ?? []
        }
        set {
            ingredientsData = try? JSONEncoder().encode(newValue)
        }
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
    var colorHex: String // Couleur de fond du logo en hex
    var timestamp: Date
    
    // Relations
    @Relationship(deleteRule: .nullify, inverse: \Recipe.folders)
    var recipes: [Recipe] = []
    
    // Lien avec l'utilisateur propriétaire
    var owner: UserProfile?
    
    init(title: String, imageName: String = "folder", colorHex: String = "#3B82F6", owner: UserProfile? = nil) {
        self.id = UUID()
        self.title = title
        self.imageName = imageName
        self.colorHex = colorHex
        self.timestamp = Date()
        self.owner = owner
    }
    
    // Couleur SwiftUI dérivée du hex
    var color: Color {
        Color(hex: colorHex) ?? Color.blue
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
