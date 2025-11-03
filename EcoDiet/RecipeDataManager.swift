import SwiftUI
import SwiftData
import Observation

@Observable
class RecipeDataManager {
    private var dataManager: SwiftDataManager?
    
    var folders: [RecipeFolder] {
        dataManager?.folders ?? []
    }
    
    var recipes: [Recipe] {
        dataManager?.recipes ?? []
    }
    
    init() {
        // L'initialisation sera faite quand le modelContext sera disponible
    }
    
    func configure(with dataManager: SwiftDataManager) {
        self.dataManager = dataManager
    }
    
    func addFolder(_ folder: RecipeFolder) {
        dataManager?.addFolder(folder)
    }
    
    func deleteFolder(_ folder: RecipeFolder) {
        dataManager?.deleteFolder(folder)
    }
    
    func deleteFolder(at offsets: IndexSet) {
        for index in offsets {
            if index < folders.count {
                let folder = folders[index]
                deleteFolder(folder)
            }
        }
    }
    
    func addRecipe(_ recipe: Recipe) {
        dataManager?.addRecipe(recipe)
    }
    
    func deleteRecipe(at offsets: IndexSet) {
        for index in offsets {
            if index < recipes.count {
                let recipe = recipes[index]
                dataManager?.deleteRecipe(recipe)
            }
        }
    }
    
    func addRecipe(to folderId: UUID, recipe: Recipe) {
        if let folder = folder(with: folderId) {
            dataManager?.addRecipe(recipe, to: folder)
        }
    }
    
    func removeRecipe(from folderId: UUID, at offsets: IndexSet) {
        guard let folder = folder(with: folderId) else { return }
        
        for index in offsets {
            if index < folder.recipes.count {
                let recipe = folder.recipes[index]
                dataManager?.removeRecipe(recipe, from: folder)
            }
        }
    }
    
    func folder(with id: UUID) -> RecipeFolder? {
        return dataManager?.folder(with: id)
    }
}