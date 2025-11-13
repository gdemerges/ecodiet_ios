import SwiftUI
import SwiftData

@Model
final class Ingredient {
    var id: UUID
    var name: String
    var category: IngredientCategory
    var unit: IngredientUnit
    var quantity: Double
    var expirationDate: Date?
    var isInFridge: Bool
    var imageName: String
    
    init(
        name: String,
        category: IngredientCategory,
        unit: IngredientUnit = .piece,
        quantity: Double = 1.0,
        expirationDate: Date? = nil,
        isInFridge: Bool = false,
        imageName: String = "questionmark.circle"
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.unit = unit
        self.quantity = quantity
        self.expirationDate = expirationDate
        self.isInFridge = isInFridge
        self.imageName = imageName
    }
}

enum IngredientCategory: String, Codable, CaseIterable {
    case vegetable = "Légumes"
    case fruit = "Fruits"
    case protein = "Protéines"
    case dairy = "Produits laitiers"
    case grain = "Céréales"
    case spice = "Épices"
    case oil = "Huiles"
    case other = "Autre"
    
    var icon: String {
        switch self {
        case .vegetable: return "carrot.fill"
        case .fruit: return "apple.logo"
        case .protein: return "fish.fill"
        case .dairy: return "cup.and.saucer.fill"
        case .grain: return "leaf.fill"
        case .spice: return "sparkles"
        case .oil: return "drop.fill"
        case .other: return "basket.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .vegetable: return Color(red: 0.3, green: 0.7, blue: 0.4)
        case .fruit: return Color(red: 0.9, green: 0.4, blue: 0.3)
        case .protein: return Color(red: 0.9, green: 0.5, blue: 0.2)
        case .dairy: return Color(red: 0.4, green: 0.6, blue: 0.9)
        case .grain: return Color(red: 0.8, green: 0.7, blue: 0.4)
        case .spice: return Color(red: 0.7, green: 0.4, blue: 0.6)
        case .oil: return Color(red: 0.9, green: 0.8, blue: 0.3)
        case .other: return Color(red: 0.6, green: 0.6, blue: 0.6)
        }
    }
}

enum IngredientUnit: String, Codable, CaseIterable {
    case gram = "g"
    case kilogram = "kg"
    case milliliter = "ml"
    case liter = "L"
    case piece = "pièce(s)"
    case tablespoon = "c. à soupe"
    case teaspoon = "c. à café"
    
    var displayName: String {
        return self.rawValue
    }
}
