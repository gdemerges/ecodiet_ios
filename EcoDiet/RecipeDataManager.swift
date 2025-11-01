import SwiftUI
import Observation

@Observable
class RecipeDataManager {
    var folders: [RecipeFolder] = [
        RecipeFolder(title: "Recettes sport", recipes: [], imageName: "figure.run"),
        RecipeFolder(title: "Recettes hiver", recipes: [], imageName: "snowflake"),
        RecipeFolder(title: "Végétarien", recipes: [], imageName: "leaf.fill")
    ] {
        didSet {
            saveFolders()
        }
    }
    
    var recipes: [Recipe] = [
        Recipe(title: "Bowl veggie", subtitle: "Protéines végétales", imageName: "leaf"),
        Recipe(title: "Salade césar", subtitle: "Poulet, parmesan", imageName: "fork.knife"),
        Recipe(title: "Pâtes complètes", subtitle: "Tomates & basilic", imageName: "takeoutbag.and.cup.and.straw"),
        Recipe(title: "Soupe de saison", subtitle: "Potiron & coco", imageName: "cup.and.saucer")
    ]
    
    private let foldersKey = "RecipeFolders"
    
    init() {
        loadFolders()
    }
    
    func addFolder(_ folder: RecipeFolder) {
        folders.append(folder)
    }
    
    func deleteFolder(at offsets: IndexSet) {
        folders.remove(atOffsets: offsets)
    }
    
    func addRecipe(to folderId: UUID, recipe: Recipe) {
        if let index = folders.firstIndex(where: { $0.id == folderId }) {
            folders[index].recipes.append(recipe)
        }
    }
    
    func removeRecipe(from folderId: UUID, at offsets: IndexSet) {
        if let index = folders.firstIndex(where: { $0.id == folderId }) {
            folders[index].recipes.remove(atOffsets: offsets)
        }
    }
    
    func folder(with id: UUID) -> RecipeFolder? {
        return folders.first { $0.id == id }
    }
    
    private func saveFolders() {
        if let encoded = try? JSONEncoder().encode(folders) {
            UserDefaults.standard.set(encoded, forKey: foldersKey)
        }
    }
    
    private func loadFolders() {
        if let data = UserDefaults.standard.data(forKey: foldersKey),
           let decoded = try? JSONDecoder().decode([RecipeFolder].self, from: data) {
            self.folders = decoded
        }
    }
}