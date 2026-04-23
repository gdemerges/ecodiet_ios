import SwiftUI
import SwiftData
import Observation

// MARK: - Validation Errors

enum ProfileValidationError: LocalizedError {
    case emptyName
    case nameTooLong(maxLength: Int)
    case invalidEmail
    case invalidPreference(String)
    case invalidAllergy(String)

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Le nom ne peut pas être vide"
        case .nameTooLong(let maxLength):
            return "Le nom ne peut pas dépasser \(maxLength) caractères"
        case .invalidEmail:
            return "L'adresse email n'est pas valide"
        case .invalidPreference(let pref):
            return "Préférence alimentaire invalide: \(pref)"
        case .invalidAllergy(let allergy):
            return "Allergie invalide: \(allergy)"
        }
    }
}

@Observable
class SwiftDataManager {
    var modelContext: ModelContext

    // Cache des données pour la performance
    var userProfile: UserProfile?
    var recipes: [Recipe] = []
    var folders: [RecipeFolder] = []

    // MARK: - Repositories (Phase 2)
    // Exposés en internal pour injection Environment
    internal let recipeRepo: RecipeRepository
    internal let folderRepo: FolderRepository
    internal let profileRepo: UserProfileRepository
    private let defaultDataService: DefaultDataService
    internal let recommendationService: RecommendationService

    // Service PostgreSQL pour charger les recettes
    let postgreSQLService = PostgreSQLService()

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        // Initialiser les repositories
        self.recipeRepo = RecipeRepository(modelContext: modelContext)
        self.folderRepo = FolderRepository(modelContext: modelContext)
        self.profileRepo = UserProfileRepository(modelContext: modelContext)
        self.defaultDataService = DefaultDataService(modelContext: modelContext)
        self.recommendationService = RecommendationService()

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
        
        // Les recettes seront chargées depuis PostgreSQL via loadPostgreSQLRecipes()
        // Ne plus créer de recettes en dur ici
        
        // Ne plus créer automatiquement les dossiers par défaut
        // L'utilisateur devra les créer lui-même
    }
    
    private func loadUserProfile() {
        let descriptor = FetchDescriptor<UserProfile>()
        do {
            let profiles = try modelContext.fetch(descriptor)
            userProfile = profiles.first
        } catch {
            Logger.dataError("Erreur lors du chargement du profil utilisateur", error: error)
        }
    }
    
    private func loadRecipes() {
        var descriptor = FetchDescriptor<Recipe>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        descriptor.fetchLimit = 100
        do {
            recipes = try modelContext.fetch(descriptor)
        } catch {
            Logger.dataError("Erreur lors du chargement des recettes", error: error)
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
                Logger.dataError("Erreur lors de la migration des couleurs des dossiers", error: error)
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
            name: "",
            email: ""
        )
        
        // Données d'exemple - Profil omnivore par défaut pour voir toutes les recettes
        profile.dietaryPreferences = ["Omnivore"]
        profile.allergies = []
        profile.cookingLevel = .intermediate
        
        modelContext.insert(profile)
        userProfile = profile
        
        do {
            try modelContext.save()
            // Créer les dossiers par défaut après avoir sauvegardé le profil
            createDefaultFolders()
        } catch {
            Logger.dataError("Erreur lors de la création du profil par défaut", error: error)
        }
    }
    
    /// Charge les recettes depuis PostgreSQL
    @MainActor
    func loadPostgreSQLRecipes(forceReload: Bool = false) async {
        // Si forceReload, supprimer les recettes existantes
        if forceReload && !recipes.isEmpty {
            print("[Data] 🔄 Force reload: suppression des \(recipes.count) recettes existantes")
            for recipe in recipes {
                modelContext.delete(recipe)
            }
            recipes = []
            try? modelContext.save()
        }

        // Ne charger que si la base est vide pour éviter les doublons
        guard recipes.isEmpty else {
            print("[Data] Recettes déjà chargées (\(recipes.count) recettes)")
            return
        }

        print("[Data] Chargement des recettes depuis PostgreSQL...")

        do {
            // Charger toutes les recettes depuis PostgreSQL (pagination automatique)
            let marmitonRecettes = try await postgreSQLService.fetchRecettes(page: 1, limit: 50)

            print("[Data] ✅ \(marmitonRecettes.count) recettes PostgreSQL récupérées")

            // Convertir et sauvegarder les recettes
            for marmitonRecette in marmitonRecettes {
                let recipe = postgreSQLService.convertToLocalRecipe(marmitonRecette)
                modelContext.insert(recipe)
                recipes.append(recipe)
            }

            // Sauvegarder dans SwiftData
            try modelContext.save()

            // Ajouter quelques recettes aux favoris du profil par défaut
            if let profile = userProfile, !recipes.isEmpty {
                profile.favoriteRecipes = Array(recipes.prefix(3))
                try modelContext.save()
            }

            print("[Data] ✅ Recettes PostgreSQL chargées avec succès dans SwiftData")
        } catch {
            Logger.dataError("❌ Erreur lors du chargement des recettes PostgreSQL", error: error)
            // En cas d'erreur, créer quelques recettes par défaut
            createDefaultRecipes_OLD()
        }
    }

    // ANCIENNE FONCTION - Conservée en fallback
    private func createDefaultRecipes_OLD() {
        // Bowl veggie
        let bowlVeggie = Recipe(
            title: "Bowl veggie",
            subtitle: "Protéines végétales",
            imageName: "leaf",
            carbonFootprint: 350,
            preparationTime: 15,
            dietaryTags: ["Végétarien", "Vegan", "Sans gluten"],
            allergens: [],
            requiredIngredients: [
                RecipeIngredient(name: "Quinoa", quantity: 200, unit: "g"),
                RecipeIngredient(name: "Pois chiches", quantity: 150, unit: "g"),
                RecipeIngredient(name: "Avocat", quantity: 1, unit: "pièce(s)"),
                RecipeIngredient(name: "Épinards", quantity: 100, unit: "g"),
                RecipeIngredient(name: "Carottes", quantity: 2, unit: "pièce(s)"),
                RecipeIngredient(name: "Graines de tournesol", quantity: 20, unit: "g", isOptional: true),
                RecipeIngredient(name: "Huile d'olive", quantity: 2, unit: "c. à soupe"),
                RecipeIngredient(name: "Citron", quantity: 1, unit: "pièce(s)")
            ]
        )
        
        // Pâtes complètes
        let patesCompletes = Recipe(
            title: "Pâtes complètes",
            subtitle: "Tomates & basilic",
            imageName: "takeoutbag.and.cup.and.straw",
            carbonFootprint: 650,
            preparationTime: 20,
            dietaryTags: ["Végétarien", "Vegan"],
            allergens: ["Gluten"],
            requiredIngredients: [
                RecipeIngredient(name: "Pâtes complètes", quantity: 300, unit: "g"),
                RecipeIngredient(name: "Tomates", quantity: 400, unit: "g"),
                RecipeIngredient(name: "Basilic", quantity: 1, unit: "pièce(s)"),
                RecipeIngredient(name: "Ail", quantity: 3, unit: "pièce(s)"),
                RecipeIngredient(name: "Huile d'olive", quantity: 3, unit: "c. à soupe"),
                RecipeIngredient(name: "Parmesan", quantity: 50, unit: "g", isOptional: true),
                RecipeIngredient(name: "Sel", quantity: 1, unit: "c. à café"),
                RecipeIngredient(name: "Poivre", quantity: 1, unit: "c. à café")
            ]
        )
        
        // Salade césar
        let saladeCesar = Recipe(
            title: "Salade césar",
            subtitle: "Poulet, parmesan",
            imageName: "fork.knife",
            carbonFootprint: 1400,
            preparationTime: 25,
            dietaryTags: ["Sans gluten"],
            allergens: ["Lactose", "Œufs"],
            requiredIngredients: [
                RecipeIngredient(name: "Laitue romaine", quantity: 1, unit: "pièce(s)"),
                RecipeIngredient(name: "Poulet", quantity: 200, unit: "g"),
                RecipeIngredient(name: "Parmesan", quantity: 50, unit: "g"),
                RecipeIngredient(name: "Croûtons", quantity: 50, unit: "g"),
                RecipeIngredient(name: "Œufs", quantity: 2, unit: "pièce(s)"),
                RecipeIngredient(name: "Anchois", quantity: 4, unit: "pièce(s)"),
                RecipeIngredient(name: "Huile d'olive", quantity: 3, unit: "c. à soupe"),
                RecipeIngredient(name: "Ail", quantity: 1, unit: "pièce(s)")
            ]
        )
        
        // Soupe de saison
        let soupeSaison = Recipe(
            title: "Soupe de saison",
            subtitle: "Potiron & coco",
            imageName: "cup.and.saucer",
            carbonFootprint: 280,
            preparationTime: 35,
            dietaryTags: ["Végétarien", "Vegan", "Sans gluten"],
            allergens: [],
            requiredIngredients: [
                RecipeIngredient(name: "Potiron", quantity: 1, unit: "kg"),
                RecipeIngredient(name: "Lait de coco", quantity: 200, unit: "ml"),
                RecipeIngredient(name: "Oignon", quantity: 1, unit: "pièce(s)"),
                RecipeIngredient(name: "Ail", quantity: 2, unit: "pièce(s)"),
                RecipeIngredient(name: "Gingembre", quantity: 20, unit: "g"),
                RecipeIngredient(name: "Bouillon de légumes", quantity: 500, unit: "ml"),
                RecipeIngredient(name: "Curcuma", quantity: 1, unit: "c. à café"),
                RecipeIngredient(name: "Curry", quantity: 1, unit: "c. à café")
            ]
        )
        
        // Curry de légumes
        let curryLegumes = Recipe(
            title: "Curry de légumes",
            subtitle: "Épices douces",
            imageName: "flame",
            carbonFootprint: 520,
            preparationTime: 30,
            dietaryTags: ["Végétarien", "Vegan", "Sans gluten"],
            allergens: [],
            requiredIngredients: [
                RecipeIngredient(name: "Carottes", quantity: 3, unit: "pièce(s)"),
                RecipeIngredient(name: "Potiron", quantity: 500, unit: "g"),
                RecipeIngredient(name: "Pois chiches", quantity: 200, unit: "g"),
                RecipeIngredient(name: "Lait de coco", quantity: 400, unit: "ml"),
                RecipeIngredient(name: "Curry", quantity: 2, unit: "c. à soupe"),
                RecipeIngredient(name: "Gingembre", quantity: 15, unit: "g"),
                RecipeIngredient(name: "Ail", quantity: 2, unit: "pièce(s)"),
                RecipeIngredient(name: "Oignon", quantity: 1, unit: "pièce(s)")
            ]
        )
        
        // Burger maison
        let burgerMaison = Recipe(
            title: "Burger maison",
            subtitle: "Bœuf, fromage",
            imageName: "cart",
            carbonFootprint: 2800,
            preparationTime: 40,
            dietaryTags: [],
            allergens: ["Gluten", "Lactose"],
            requiredIngredients: [
                RecipeIngredient(name: "Bœuf haché", quantity: 400, unit: "g"),
                RecipeIngredient(name: "Pain burger", quantity: 4, unit: "pièce(s)"),
                RecipeIngredient(name: "Fromage cheddar", quantity: 4, unit: "pièce(s)"),
                RecipeIngredient(name: "Tomates", quantity: 2, unit: "pièce(s)"),
                RecipeIngredient(name: "Laitue", quantity: 4, unit: "pièce(s)"),
                RecipeIngredient(name: "Oignon", quantity: 1, unit: "pièce(s)")
            ]
        )
        
        // Poisson grillé
        let poissonGrille = Recipe(
            title: "Poisson grillé",
            subtitle: "Légumes vapeur",
            imageName: "fish",
            carbonFootprint: 1200,
            preparationTime: 25,
            dietaryTags: ["Sans gluten", "Sans lactose", "Pescetarien"],
            allergens: ["Poisson"],
            requiredIngredients: [
                RecipeIngredient(name: "Filet de poisson", quantity: 400, unit: "g"),
                RecipeIngredient(name: "Carottes", quantity: 2, unit: "pièce(s)"),
                RecipeIngredient(name: "Brocoli", quantity: 200, unit: "g"),
                RecipeIngredient(name: "Citron", quantity: 1, unit: "pièce(s)"),
                RecipeIngredient(name: "Huile d'olive", quantity: 2, unit: "c. à soupe")
            ]
        )
        
        // Salade quinoa
        let saladeQuinoa = Recipe(
            title: "Salade quinoa",
            subtitle: "Avocat, pois chiches",
            imageName: "leaf.circle",
            carbonFootprint: 420,
            preparationTime: 10,
            dietaryTags: ["Végétarien", "Vegan", "Sans gluten"],
            allergens: [],
            requiredIngredients: [
                RecipeIngredient(name: "Quinoa", quantity: 200, unit: "g"),
                RecipeIngredient(name: "Avocat", quantity: 2, unit: "pièce(s)"),
                RecipeIngredient(name: "Pois chiches", quantity: 150, unit: "g"),
                RecipeIngredient(name: "Tomates", quantity: 2, unit: "pièce(s)"),
                RecipeIngredient(name: "Citron", quantity: 1, unit: "pièce(s)"),
                RecipeIngredient(name: "Huile d'olive", quantity: 3, unit: "c. à soupe")
            ]
        )
        
        let defaultRecipes = [
            bowlVeggie,
            patesCompletes,
            saladeCesar,
            soupeSaison,
            curryLegumes,
            burgerMaison,
            poissonGrille,
            saladeQuinoa
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
            Logger.dataError("Erreur lors de la création des recettes par défaut", error: error)
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
            Logger.dataError("Erreur lors de la création des dossiers par défaut", error: error)
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
            Logger.dataError("Erreur lors de la création du profil", error: error)
        }
    }
    
    /// Met à jour le profil utilisateur avec validation des données
    /// - Throws: ProfileValidationError si les données sont invalides
    func updateProfile(name: String, email: String, cookingLevel: CookingLevel,
                      dietaryPreferences: [String], allergies: [String]) throws {
        guard let profile = userProfile else { return }

        // Validation des données
        try validateProfileData(name: name, email: email, dietaryPreferences: dietaryPreferences, allergies: allergies)

        // Sauvegarder les valeurs originales pour rollback
        let originalName = profile.name
        let originalEmail = profile.email
        let originalCookingLevel = profile.cookingLevel
        let originalPreferences = profile.dietaryPreferences
        let originalAllergies = profile.allergies

        // Appliquer les modifications
        profile.name = name
        profile.email = email
        profile.cookingLevel = cookingLevel
        profile.dietaryPreferences = dietaryPreferences
        profile.allergies = allergies

        do {
            try modelContext.save()
        } catch {
            // Rollback en cas d'erreur de sauvegarde
            profile.name = originalName
            profile.email = originalEmail
            profile.cookingLevel = originalCookingLevel
            profile.dietaryPreferences = originalPreferences
            profile.allergies = originalAllergies
            Logger.dataError("Erreur lors de la mise à jour du profil", error: error)
            throw error
        }
    }

    // MARK: - Validation

    private static let maxNameLength = 100
    private static let validDietaryPreferences = [
        "Végétarien", "Vegan", "Flexitarien", "Omnivore", "Pescetarien",
        "Sans gluten", "Sans lactose", "Bio", "Local", "Équilibré",
        "Riche en protéines", "Faible en glucides", "Faible en gras"
    ]
    private static let validAllergies = [
        "Gluten", "Lactose", "Œufs", "Arachides", "Fruits à coque",
        "Soja", "Poisson", "Crustacés", "Sésame", "Moutarde", "Céleri", "Sulfites"
    ]

    private func validateProfileData(name: String, email: String,
                                     dietaryPreferences: [String], allergies: [String]) throws {
        // Validation du nom
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty {
            throw ProfileValidationError.emptyName
        }
        if trimmedName.count > Self.maxNameLength {
            throw ProfileValidationError.nameTooLong(maxLength: Self.maxNameLength)
        }

        // Validation de l'email
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if !email.isEmpty && !emailPredicate.evaluate(with: email) {
            throw ProfileValidationError.invalidEmail
        }

        // Validation des préférences alimentaires
        for preference in dietaryPreferences {
            if !Self.validDietaryPreferences.contains(preference) {
                throw ProfileValidationError.invalidPreference(preference)
            }
        }

        // Validation des allergies
        for allergy in allergies {
            if !Self.validAllergies.contains(allergy) {
                throw ProfileValidationError.invalidAllergy(allergy)
            }
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
                Logger.dataError("Erreur lors de l'ajout aux favoris", error: error)
            }
        }
    }
    
    func removeFavoriteRecipe(_ recipe: Recipe) {
        guard let profile = userProfile else { return }
        
        profile.favoriteRecipes.removeAll { $0.id == recipe.id }
        
        do {
            try modelContext.save()
        } catch {
            Logger.dataError("Erreur lors de la suppression des favoris", error: error)
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
            Logger.dataError("Erreur lors de l'ajout de la recette", error: error)
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
            Logger.dataError("Erreur lors de la suppression de la recette", error: error)
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
            Logger.dataError("Erreur lors de l'ajout du dossier", error: error)
        }
    }
    
    func deleteFolder(_ folder: RecipeFolder) {
        modelContext.delete(folder)
        folders.removeAll { $0.id == folder.id }
        userProfile?.folders.removeAll { $0.id == folder.id }
        
        do {
            try modelContext.save()
        } catch {
            Logger.dataError("Erreur lors de la suppression du dossier", error: error)
        }
    }
    
    func addRecipe(_ recipe: Recipe, to folder: RecipeFolder) {
        folder.recipes.append(recipe)
        
        do {
            try modelContext.save()
        } catch {
            Logger.dataError("Erreur lors de l'ajout de la recette au dossier", error: error)
        }
    }
    
    func removeRecipe(_ recipe: Recipe, from folder: RecipeFolder) {
        folder.recipes.removeAll { $0.id == recipe.id }
        
        do {
            try modelContext.save()
        } catch {
            Logger.dataError("Erreur lors de la suppression de la recette du dossier", error: error)
        }
    }
    
    func folder(with id: UUID) -> RecipeFolder? {
        return folders.first { $0.id == id }
    }
    
    // MARK: - Recommandations personnalisées

    /// Retourne les recettes recommandées basées sur les préférences utilisateur
    /// Optimisé avec des Sets pour des recherches O(1) au lieu de O(n*m)
    func getRecommendedRecipes() -> [Recipe] {
        guard let profile = userProfile else {
            return recipes
        }

        let preferences = profile.dietaryPreferences
        let allergies = Set(profile.allergies)

        // Convertir en Set pour des recherches O(1)
        let preferencesSet = Set(preferences)

        // Pré-calculer les cas spéciaux une seule fois
        let isOmnivore = preferencesSet.contains("Omnivore")
        let isVegetarian = preferencesSet.contains("Végétarien")
        let isVegan = preferencesSet.contains("Vegan")
        let isFlexitarian = preferencesSet.contains("Flexitarien")
        let isPescatarian = preferencesSet.contains("Pescetarien")

        // Vérifier si l'utilisateur a une préférence alimentaire spécifique
        let hasDietaryPreference = isOmnivore || isVegetarian || isVegan || isFlexitarian || isPescatarian

        // Filtrer les recettes
        return recipes.filter { recipe in
            // 1. FILTRER LES ALLERGÈNES (priorité absolue)
            let recipeAllergens = Set(recipe.allergens)
            if !allergies.isDisjoint(with: recipeAllergens) {
                return false // Contient un allergène, on exclut
            }

            // 2. Si pas de préférence alimentaire spécifique, retourner toutes les recettes
            if !hasDietaryPreference {
                return true
            }

            // 3. Si omnivore, accepter toutes les recettes
            if isOmnivore {
                return true
            }

            let recipeTags = Set(recipe.dietaryTags)

            // 4. Si VEGAN : accepter uniquement les recettes Vegan
            if isVegan {
                return recipeTags.contains("Vegan")
            }

            // 5. Si VÉGÉTARIEN : accepter Végétarien ET Vegan
            if isVegetarian {
                return recipeTags.contains("Végétarien") || recipeTags.contains("Vegan")
            }

            // 6. Si FLEXITARIEN : accepter Végétarien, Vegan, et recettes sans tag (tout)
            if isFlexitarian {
                return recipeTags.contains("Végétarien") ||
                       recipeTags.contains("Vegan") ||
                       recipeTags.isEmpty
            }

            // 7. Si PESCETARIEN : accepter poisson, végétarien et vegan ; exclure viandes terrestres
            if isPescatarian {
                if recipeTags.contains("Végétarien") || recipeTags.contains("Vegan") || recipeTags.contains("Pescetarien") {
                    return true
                }
                let meatTags: Set<String> = ["Viande", "Bœuf", "Porc", "Volaille"]
                return recipeTags.isDisjoint(with: meatTags)
            }

            // 8. Cas improbable (ne devrait jamais arriver)
            return true
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
            Logger.dataError("Erreur lors de la suppression des données", error: error)
        }
    }
}
