import SwiftUI

struct FolderIconOption: Identifiable {
    let id = UUID()
    let name: String // Nom affiché en français
    let systemImage: String // Nom SF Symbol
    let colorHex: String // Couleur de fond
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
    
    static let allOptions: [FolderIconOption] = [
        // Catégories de recettes
        FolderIconOption(name: "Sport", systemImage: "figure.run", colorHex: "#EF4444"),
        FolderIconOption(name: "Végétarien", systemImage: "leaf.fill", colorHex: "#10B981"),
        FolderIconOption(name: "Rapide", systemImage: "bolt.fill", colorHex: "#F59E0B"),
        FolderIconOption(name: "Santé", systemImage: "heart.fill", colorHex: "#EC4899"),
        FolderIconOption(name: "Petit-déjeuner", systemImage: "cup.and.saucer.fill", colorHex: "#8B5CF6"),
        FolderIconOption(name: "Déjeuner", systemImage: "fork.knife", colorHex: "#3B82F6"),
        FolderIconOption(name: "Dîner", systemImage: "moon.stars.fill", colorHex: "#6366F1"),
        FolderIconOption(name: "Desserts", systemImage: "birthday.cake.fill", colorHex: "#F472B6"),
        
        // Saisons
        FolderIconOption(name: "Été", systemImage: "sun.max.fill", colorHex: "#FBBF24"),
        FolderIconOption(name: "Automne", systemImage: "leaf", colorHex: "#F97316"),
        FolderIconOption(name: "Hiver", systemImage: "snowflake", colorHex: "#60A5FA"),
        FolderIconOption(name: "Printemps", systemImage: "cloud.sun.fill", colorHex: "#34D399"),
        
        // Cuisine du monde
        FolderIconOption(name: "Asie", systemImage: "takeoutbag.and.cup.and.straw.fill", colorHex: "#DC2626"),
        FolderIconOption(name: "Italie", systemImage: "fork.knife.circle.fill", colorHex: "#059669"),
        FolderIconOption(name: "France", systemImage: "puzzlepiece.fill", colorHex: "#3B82F6"),
        
        // Types d'aliments
        FolderIconOption(name: "Poisson", systemImage: "fish.fill", colorHex: "#0EA5E9"),
        FolderIconOption(name: "Viande", systemImage: "flame.fill", colorHex: "#DC2626"),
        FolderIconOption(name: "Légumes", systemImage: "carrot.fill", colorHex: "#F97316"),
        FolderIconOption(name: "Soupes", systemImage: "drop.fill", colorHex: "#06B6D4"),
        FolderIconOption(name: "Salades", systemImage: "leaf.circle.fill", colorHex: "#10B981"),
        
        // Occasions spéciales
        FolderIconOption(name: "Fêtes", systemImage: "gift.fill", colorHex: "#EF4444"),
        FolderIconOption(name: "Anniversaires", systemImage: "balloon.fill", colorHex: "#EC4899"),
        FolderIconOption(name: "Pique-nique", systemImage: "basket.fill", colorHex: "#84CC16"),
        FolderIconOption(name: "Barbecue", systemImage: "flame.circle.fill", colorHex: "#F97316"),
        
        // Régimes spéciaux
        FolderIconOption(name: "Sans gluten", systemImage: "allergens", colorHex: "#FBBF24"),
        FolderIconOption(name: "Vegan", systemImage: "leaf.arrow.circlepath", colorHex: "#22C55E"),
        FolderIconOption(name: "Protéiné", systemImage: "dumbbell.fill", colorHex: "#7C3AED"),
        FolderIconOption(name: "Faible en calories", systemImage: "chart.line.downtrend.xyaxis", colorHex: "#06B6D4"),
        
        // Préparation
        FolderIconOption(name: "Batch cooking", systemImage: "tray.2.fill", colorHex: "#8B5CF6"),
        FolderIconOption(name: "Meal prep", systemImage: "calendar", colorHex: "#6366F1"),
        FolderIconOption(name: "À emporter", systemImage: "bag.fill", colorHex: "#F59E0B"),
        
        // Général
        FolderIconOption(name: "Favoris", systemImage: "star.fill", colorHex: "#FBBF24"),
        FolderIconOption(name: "À essayer", systemImage: "sparkles", colorHex: "#A855F7"),
        FolderIconOption(name: "Classique", systemImage: "book.closed.fill", colorHex: "#64748B"),
        FolderIconOption(name: "Nouveau", systemImage: "plus.circle.fill", colorHex: "#14B8A6"),
        FolderIconOption(name: "Personnel", systemImage: "person.fill", colorHex: "#6366F1"),
        FolderIconOption(name: "Famille", systemImage: "figure.2.and.child.holdinghands", colorHex: "#EC4899"),
    ]
}
