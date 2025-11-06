import SwiftUI
import SwiftData
import Observation

@Observable
class SwiftDataManager {
    var modelContext: ModelContext
    
    // Cache des données pour la performance
    var userProfile: UserProfile?
    var recipes: [Recipe] = []
    var folders: [RecipeFolder] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadData()
    }
    
    // MARK: - Chargement des données
    private func loadData() {
        loadUserProfile()
        loadRecipes()
        loadFolders()
        
        // Créer des données d'exemple si nécessaire
        if userProfile == nil {
            createDefaultUserProfile()
        }
        
        if recipes.isEmpty {
            createDefaultRecipes()
        }
        
        if folders.isEmpty {
            createDefaultFolders()
        }
    }
    
    private func loadUserProfile() {
        let descriptor = FetchDescriptor<UserProfile>()
        do {
            let profiles = try modelContext.fetch(descriptor)
            userProfile = profiles.first
        } catch {
            print("Erreur lors du chargement du profil utilisateur: \(error)")
        }
    }
    
    private func loadRecipes() {
        let descriptor = FetchDescriptor<Recipe>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        do {
            recipes = try modelContext.fetch(descriptor)
        } catch {
            print("Erreur lors du chargement des recettes: \(error)")
        }
    }
    
    private func loadFolders() {
        let descriptor = FetchDescriptor<RecipeFolder>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        do {
            folders = try modelContext.fetch(descriptor)
        } catch {
            print("Erreur lors du chargement des dossiers: \(error)")
        }
    }
    
    // MARK: - Création des données par défaut
    private func createDefaultUserProfile() {
        let profile = UserProfile(
            name: "Guillaume",
            email: "guillaume@email.com"
        )
        
        // Données d'exemple
        profile.dietaryPreferences = ["Végétarien", "Bio", "Local"]
        profile.allergies = ["Fruits à coque"]
        profile.cookingLevel = .intermediate
        
        modelContext.insert(profile)
        userProfile = profile
        
        do {
            try modelContext.save()
        } catch {
            print("Erreur lors de la création du profil par défaut: \(error)")
        }
    }
    
    private func createDefaultRecipes() {
        let defaultRecipes = [
            // Eco-Score A : < 500g CO2eq - Très faible impact
            Recipe(title: "Bowl veggie", subtitle: "Protéines végétales", imageName: "leaf", carbonFootprint: 350),
            
            // Eco-Score B : 500-1000g CO2eq - Faible impact
            Recipe(title: "Pâtes complètes", subtitle: "Tomates & basilic", imageName: "takeoutbag.and.cup.and.straw", carbonFootprint: 650),
            
            // Eco-Score C : 1000-2000g CO2eq - Impact modéré
            Recipe(title: "Salade césar", subtitle: "Poulet, parmesan", imageName: "fork.knife", carbonFootprint: 1400),
            
            // Eco-Score A : < 500g CO2eq - Très faible impact
            Recipe(title: "Soupe de saison", subtitle: "Potiron & coco", imageName: "cup.and.saucer", carbonFootprint: 280),
            
            // Eco-Score B : 500-1000g CO2eq - Faible impact
            Recipe(title: "Curry de légumes", subtitle: "Épices douces", imageName: "flame", carbonFootprint: 520),
            
            // Eco-Score D : 2000-3500g CO2eq - Impact élevé
            Recipe(title: "Burger maison", subtitle: "Bœuf, fromage", imageName: "cart", carbonFootprint: 2800),
            
            // Eco-Score C : 1000-2000g CO2eq - Impact modéré
            Recipe(title: "Poisson grillé", subtitle: "Légumes vapeur", imageName: "fish", carbonFootprint: 1200),
            
            // Eco-Score A : < 500g CO2eq - Très faible impact
            Recipe(title: "Salade quinoa", subtitle: "Avocat, pois chiches", imageName: "leaf.circle", carbonFootprint: 420)
        ]
        
        for recipe in defaultRecipes {
            modelContext.insert(recipe)
        }
        
        // Ajouter quelques recettes aux favoris du profil par défaut
        if let profile = userProfile {
            profile.favoriteRecipes = Array(defaultRecipes.prefix(3))
        }
        
        recipes = defaultRecipes
        
        do {
            try modelContext.save()
        } catch {
            print("Erreur lors de la création des recettes par défaut: \(error)")
        }
    }
    
    private func createDefaultFolders() {
        let defaultFolders = [
            RecipeFolder(title: "Recettes sport", imageName: "figure.run"),
            RecipeFolder(title: "Recettes hiver", imageName: "snowflake"),
            RecipeFolder(title: "Végétarien", imageName: "leaf.fill")
        ]
        
        for folder in defaultFolders {
            modelContext.insert(folder)
        }
        
        folders = defaultFolders
        
        do {
            try modelContext.save()
        } catch {
            print("Erreur lors de la création des dossiers par défaut: \(error)")
        }
    }
    
    // MARK: - Gestion du profil utilisateur
    func createProfileFromSignup(email: String, password: String, profile: UserProfile) {
        // Supprimer l'ancien profil s'il existe
        if let existingProfile = userProfile {
            modelContext.delete(existingProfile)
        }
        
        profile.email = email
        profile.joinDate = Date()
        
        modelContext.insert(profile)
        userProfile = profile
        
        do {
            try modelContext.save()
        } catch {
            print("Erreur lors de la création du profil: \(error)")
        }
    }
    
    func updateProfile(name: String, email: String, cookingLevel: CookingLevel, 
                      dietaryPreferences: [String], allergies: [String]) {
        guard let profile = userProfile else { return }
        
        profile.name = name
        profile.email = email
        profile.cookingLevel = cookingLevel
        profile.dietaryPreferences = dietaryPreferences
        profile.allergies = allergies
        
        do {
            try modelContext.save()
        } catch {
            print("Erreur lors de la mise à jour du profil: \(error)")
        }
    }
    
    // MARK: - Gestion des favoris
    func addFavoriteRecipe(_ recipe: Recipe) {
        guard let profile = userProfile else { return }
        
        if !profile.favoriteRecipes.contains(recipe) {
            profile.favoriteRecipes.append(recipe)
            
            do {
                try modelContext.save()
            } catch {
                print("Erreur lors de l'ajout aux favoris: \(error)")
            }
        }
    }
    
    func removeFavoriteRecipe(_ recipe: Recipe) {
        guard let profile = userProfile else { return }
        
        profile.favoriteRecipes.removeAll { $0.id == recipe.id }
        
        do {
            try modelContext.save()
        } catch {
            print("Erreur lors de la suppression des favoris: \(error)")
        }
    }
    
    func isFavorite(_ recipe: Recipe) -> Bool {
        return userProfile?.favoriteRecipes.contains(recipe) ?? false
    }
    
    // MARK: - Gestion des recettes
    func addRecipe(_ recipe: Recipe) {
        modelContext.insert(recipe)
        recipes.append(recipe)
        
        do {
            try modelContext.save()
        } catch {
            print("Erreur lors de l'ajout de la recette: \(error)")
        }
    }
    
    func deleteRecipe(_ recipe: Recipe) {
        modelContext.delete(recipe)
        recipes.removeAll { $0.id == recipe.id }
        
        // Supprimer des favoris si nécessaire
        userProfile?.favoriteRecipes.removeAll { $0.id == recipe.id }
        
        do {
            try modelContext.save()
        } catch {
            print("Erreur lors de la suppression de la recette: \(error)")
        }
    }
    
    // MARK: - Gestion des dossiers
    func addFolder(_ folder: RecipeFolder) {
        modelContext.insert(folder)
        folders.append(folder)
        
        do {
            try modelContext.save()
        } catch {
            print("Erreur lors de l'ajout du dossier: \(error)")
        }
    }
    
    func deleteFolder(_ folder: RecipeFolder) {
        modelContext.delete(folder)
        folders.removeAll { $0.id == folder.id }
        
        do {
            try modelContext.save()
        } catch {
            print("Erreur lors de la suppression du dossier: \(error)")
        }
    }
    
    func addRecipe(_ recipe: Recipe, to folder: RecipeFolder) {
        folder.recipes.append(recipe)
        
        do {
            try modelContext.save()
        } catch {
            print("Erreur lors de l'ajout de la recette au dossier: \(error)")
        }
    }
    
    func removeRecipe(_ recipe: Recipe, from folder: RecipeFolder) {
        folder.recipes.removeAll { $0.id == recipe.id }
        
        do {
            try modelContext.save()
        } catch {
            print("Erreur lors de la suppression de la recette du dossier: \(error)")
        }
    }
    
    func folder(with id: UUID) -> RecipeFolder? {
        return folders.first { $0.id == id }
    }
    
    // MARK: - Utilitaires
    func clearAllData() {
        // Supprimer tous les objets
        do {
            try modelContext.delete(model: UserProfile.self)
            try modelContext.delete(model: Recipe.self)
            try modelContext.delete(model: RecipeFolder.self)
            try modelContext.save()
            
            // Recréer les données par défaut
            userProfile = nil
            recipes = []
            folders = []
            loadData()
        } catch {
            print("Erreur lors de la suppression des données: \(error)")
        }
    }
}
