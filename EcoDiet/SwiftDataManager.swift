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
        
        // Ne plus créer automatiquement les dossiers par défaut
        // L'utilisateur devra les créer lui-même
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
        guard let profile = userProfile else {
            folders = []
            return
        }
        
        // Charger uniquement les dossiers de l'utilisateur actuel
        folders = profile.folders.sorted { $0.timestamp > $1.timestamp }
        
        // Migration: Ajouter des couleurs par défaut aux anciens dossiers
        migrateFolderColors()
    }
    
    private func migrateFolderColors() {
        var needsSave = false
        
        for folder in folders {
            // Si le dossier n'a pas de couleur (ancien format), lui en assigner une
            if folder.colorHex.isEmpty || folder.colorHex == "#000000" {
                // Assigner une couleur basée sur l'icône
                let defaultColor = getDefaultColorForIcon(folder.imageName)
                folder.colorHex = defaultColor
                needsSave = true
            }
        }
        
        if needsSave {
            do {
                try modelContext.save()
            } catch {
                print("Erreur lors de la migration des couleurs des dossiers: \(error)")
            }
        }
    }
    
    private func getDefaultColorForIcon(_ iconName: String) -> String {
        // Retourner une couleur par défaut basée sur l'icône
        switch iconName {
        case "figure.run", "dumbbell.fill":
            return "#EF4444" // Rouge pour sport
        case "leaf.fill", "leaf", "carrot.fill", "leaf.circle.fill":
            return "#10B981" // Vert pour végétarien/légumes
        case "snowflake", "drop.fill":
            return "#60A5FA" // Bleu pour hiver/eau
        case "sun.max.fill", "sun.max":
            return "#FBBF24" // Jaune pour été
        case "flame.fill", "flame":
            return "#F97316" // Orange pour viande/chaud
        case "heart.fill", "heart":
            return "#EC4899" // Rose pour favoris
        case "star.fill", "star":
            return "#FBBF24" // Jaune doré pour favoris
        case "moon.stars.fill", "moon.stars":
            return "#6366F1" // Indigo pour nuit
        case "birthday.cake.fill", "gift.fill":
            return "#F472B6" // Rose pour desserts/fêtes
        case "fish.fill", "fish":
            return "#0EA5E9" // Bleu ciel pour poisson
        default:
            return "#3B82F6" // Bleu par défaut
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
            // Créer les dossiers par défaut après avoir sauvegardé le profil
            createDefaultFolders()
        } catch {
            print("Erreur lors de la création du profil par défaut: \(error)")
        }
    }
    
    private func createDefaultRecipes() {
        let defaultRecipes = [
            // Eco-Score A : < 500g CO2eq - Très faible impact
            Recipe(title: "Bowl veggie", subtitle: "Protéines végétales", imageName: "leaf", carbonFootprint: 350, preparationTime: 15, dietaryTags: ["Végétarien", "Vegan", "Sans gluten"], allergens: []),
            
            // Eco-Score B : 500-1000g CO2eq - Faible impact
            Recipe(title: "Pâtes complètes", subtitle: "Tomates & basilic", imageName: "takeoutbag.and.cup.and.straw", carbonFootprint: 650, preparationTime: 20, dietaryTags: ["Végétarien", "Vegan"], allergens: ["Gluten"]),
            
            // Eco-Score C : 1000-2000g CO2eq - Impact modéré
            Recipe(title: "Salade césar", subtitle: "Poulet, parmesan", imageName: "fork.knife", carbonFootprint: 1400, preparationTime: 25, dietaryTags: ["Sans gluten"], allergens: ["Lactose", "Œufs"]),
            
            // Eco-Score A : < 500g CO2eq - Très faible impact
            Recipe(title: "Soupe de saison", subtitle: "Potiron & coco", imageName: "cup.and.saucer", carbonFootprint: 280, preparationTime: 35, dietaryTags: ["Végétarien", "Vegan", "Sans gluten"], allergens: []),
            
            // Eco-Score B : 500-1000g CO2eq - Faible impact
            Recipe(title: "Curry de légumes", subtitle: "Épices douces", imageName: "flame", carbonFootprint: 520, preparationTime: 30, dietaryTags: ["Végétarien", "Vegan", "Sans gluten"], allergens: []),
            
            // Eco-Score D : 2000-3500g CO2eq - Impact élevé
            Recipe(title: "Burger maison", subtitle: "Bœuf, fromage", imageName: "cart", carbonFootprint: 2800, preparationTime: 40, dietaryTags: [], allergens: ["Gluten", "Lactose"]),
            
            // Eco-Score C : 1000-2000g CO2eq - Impact modéré
            Recipe(title: "Poisson grillé", subtitle: "Légumes vapeur", imageName: "fish", carbonFootprint: 1200, preparationTime: 25, dietaryTags: ["Sans gluten", "Sans lactose", "Pescetarien"], allergens: ["Poisson"]),
            
            // Eco-Score A : < 500g CO2eq - Très faible impact
            Recipe(title: "Salade quinoa", subtitle: "Avocat, pois chiches", imageName: "leaf.circle", carbonFootprint: 420, preparationTime: 10, dietaryTags: ["Végétarien", "Vegan", "Sans gluten"], allergens: [])
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
        guard let profile = userProfile else { return }
        
        let defaultFolders = [
            RecipeFolder(title: "Recettes sport", imageName: "figure.run", colorHex: "#EF4444", owner: profile),
            RecipeFolder(title: "Recettes hiver", imageName: "snowflake", colorHex: "#60A5FA", owner: profile),
            RecipeFolder(title: "Végétarien", imageName: "leaf.fill", colorHex: "#10B981", owner: profile)
        ]
        
        for folder in defaultFolders {
            modelContext.insert(folder)
            profile.folders.append(folder)
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
        
        // Ne plus créer automatiquement les dossiers par défaut
        // L'utilisateur devra les créer lui-même
        folders = []
        
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
        guard let profile = userProfile else { return }
        
        folder.owner = profile
        modelContext.insert(folder)
        profile.folders.append(folder)
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
        userProfile?.folders.removeAll { $0.id == folder.id }
        
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
    
    // MARK: - Recommandations personnalisées
    func getRecommendedRecipes() -> [Recipe] {
        guard let profile = userProfile else {
            return recipes
        }
        
        let preferences = profile.dietaryPreferences
        
        // Si l'utilisateur n'a pas de préférences, retourner toutes les recettes
        if preferences.isEmpty {
            return recipes
        }
        
        // Filtrer les recettes qui correspondent aux préférences alimentaires
        return recipes.filter { recipe in
            // Vérifier si la recette correspond à au moins une préférence de l'utilisateur
            for preference in preferences {
                if recipe.dietaryTags.contains(preference) {
                    return true
                }
                
                // Cas spéciaux
                // Si l'utilisateur est vegan, il peut manger végétarien
                if preference == "Vegan" && recipe.dietaryTags.contains("Végétarien") {
                    return true
                }
                
                // Si l'utilisateur est végétarien ou flexitarien, il peut manger végétarien
                if (preference == "Végétarien" || preference == "Flexitarien") && 
                   recipe.dietaryTags.contains("Végétarien") {
                    return true
                }
                
                // Si l'utilisateur est omnivore, il peut manger toutes les recettes sauf vegan strictes
                if preference == "Omnivore" {
                    return true
                }
            }
            return false
        }
    }
    
    // MARK: - Utilitaires
    func refreshFolders() {
        loadFolders()
    }
    
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
