import Foundation

// MARK: - Modèles pour la base de données PostgreSQL

struct MarmitonRecette: Codable, Identifiable {
    let id: Int
    let url: String
    let titre: String?
    let photo: String?
    let duree: String?
    let ingredients: [MarmitonIngredient]?
    let ustensiles: [String]?
    let etapes: [String]?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, url, titre, photo, duree, ingredients, ustensiles, etapes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct MarmitonIngredient: Codable {
    let nom: String
    let quantite: String?
    let unite: String?
}

// MARK: - Service de connexion PostgreSQL

@Observable
class PostgreSQLService {
    // URL de votre API backend (vous devrez créer cette API)
    private let baseURL = "http://localhost:3000/api"

    // Configuration du retry pour les erreurs réseau transitoires
    private let maxRetries = 3
    private let initialRetryDelay: UInt64 = 500_000_000 // 0.5 seconde en nanosecondes

    // Configuration du décodeur JSON
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    // MARK: - Retry Logic

    /// Execute une requête avec retry automatique en cas d'erreur réseau transitoire
    private func executeWithRetry<T>(
        operation: @escaping () async throws -> T
    ) async throws -> T {
        var lastError: Error?

        for attempt in 0..<maxRetries {
            do {
                return try await operation()
            } catch let error as URLError where isTransientError(error) {
                lastError = error
                let delay = initialRetryDelay * UInt64(1 << attempt) // Exponential backoff
                try? await Task.sleep(nanoseconds: delay)
                Logger.networkInfo("Retry \(attempt + 1)/\(maxRetries) après erreur: \(error.localizedDescription)")
            } catch {
                throw error // Non-transient error, don't retry
            }
        }

        throw lastError ?? PostgreSQLError.networkError(NSError(domain: "RetryFailed", code: -1))
    }

    /// Vérifie si l'erreur est transitoire et mérite un retry
    private func isTransientError(_ error: URLError) -> Bool {
        switch error.code {
        case .timedOut, .cannotConnectToHost, .networkConnectionLost,
             .notConnectedToInternet, .dnsLookupFailed:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Récupération des recettes
    
    /// Recupere toutes les recettes depuis PostgreSQL
    func fetchRecettes() async throws -> [MarmitonRecette] {
        return try await fetchRecettes(page: 1, limit: 50)
    }

    /// Recupere les recettes avec pagination (avec retry automatique)
    func fetchRecettes(page: Int, limit: Int = 20) async throws -> [MarmitonRecette] {
        return try await executeWithRetry {
            var components = URLComponents(string: "\(self.baseURL)/recettes")
            components?.queryItems = [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]

            guard let url = components?.url else {
                throw PostgreSQLError.invalidURL
            }

            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw PostgreSQLError.invalidResponse
            }

            return try self.decoder.decode([MarmitonRecette].self, from: data)
        }
    }
    
    /// Récupère une recette par son ID (avec retry automatique)
    func fetchRecette(id: Int) async throws -> MarmitonRecette {
        return try await executeWithRetry {
            guard let url = URL(string: "\(self.baseURL)/recettes/\(id)") else {
                throw PostgreSQLError.invalidURL
            }

            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw PostgreSQLError.invalidResponse
            }

            return try self.decoder.decode(MarmitonRecette.self, from: data)
        }
    }
    
    /// Recherche des recettes par mot-clé (avec retry automatique)
    func searchRecettes(query: String) async throws -> [MarmitonRecette] {
        return try await executeWithRetry {
            var components = URLComponents(string: "\(self.baseURL)/recettes/search")
            components?.queryItems = [URLQueryItem(name: "q", value: query)]

            guard let url = components?.url else {
                throw PostgreSQLError.invalidURL
            }

            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw PostgreSQLError.invalidResponse
            }

            return try self.decoder.decode([MarmitonRecette].self, from: data)
        }
    }
    
    // MARK: - Conversion vers le modèle local
    
    /// Convertit une recette PostgreSQL en modèle Recipe local
    func convertToLocalRecipe(_ marmitonRecette: MarmitonRecette) -> Recipe {
        // Conversion des ingrédients
        let recipeIngredients = (marmitonRecette.ingredients ?? []).map { ingredient in
            RecipeIngredient(
                name: ingredient.nom,
                quantity: parseQuantity(ingredient.quantite),
                unit: ingredient.unite ?? "",
                isOptional: false
            )
        }
        
        // Parsing du temps de préparation
        let preparationTime = parsePreparationTime(marmitonRecette.duree)
        
        // Calcul estimé de l'empreinte carbone (vous pourrez affiner cela)
        let carbonFootprint = estimateCarbonFootprint(ingredients: recipeIngredients)
        
        // Détection automatique des tags diététiques
        let dietaryTags = detectDietaryTags(ingredients: marmitonRecette.ingredients)
        
        // Création de la recette locale
        let recipe = Recipe(
            title: marmitonRecette.titre ?? "Sans titre",
            subtitle: "\(recipeIngredients.count) ingrédients",
            imageName: marmitonRecette.photo ?? "photo.on.rectangle",
            carbonFootprint: carbonFootprint,
            preparationTime: preparationTime,
            dietaryTags: dietaryTags,
            allergens: detectAllergens(ingredients: marmitonRecette.ingredients),
            requiredIngredients: recipeIngredients,
            ustensiles: marmitonRecette.ustensiles ?? [],
            etapes: marmitonRecette.etapes ?? [],
            sourceURL: marmitonRecette.url
        )
        
        return recipe
    }
    
    /// Synchronise les recettes PostgreSQL avec SwiftData
    func syncRecipesToSwiftData(dataManager: SwiftDataManager) async throws {
        let marmitonRecettes = try await fetchRecettes()
        
        for marmitonRecette in marmitonRecettes {
            let recipe = convertToLocalRecipe(marmitonRecette)
            dataManager.addRecipe(recipe)
        }
    }
    
    // MARK: - Fonctions utilitaires
    
    private func parseQuantity(_ quantiteString: String?) -> Double {
        guard let quantite = quantiteString else { return 0 }
        
        // Enlever les caractères non numériques et essayer de parser
        let numericString = quantite.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Double(numericString) ?? 0
    }
    
    private func parsePreparationTime(_ duree: String?) -> Int {
        guard let duree = duree?.lowercased() else { return 30 }
        
        // Extraire les minutes (ex: "45 min", "1h30", etc.)
        let components = duree.components(separatedBy: CharacterSet.decimalDigits.inverted)
        let numbers = components.compactMap { Int($0) }
        
        if duree.contains("h") {
            if numbers.count >= 2 {
                return numbers[0] * 60 + numbers[1]
            } else if numbers.count == 1 {
                return numbers[0] * 60
            }
        } else if numbers.count > 0 {
            return numbers[0]
        }
        
        return 30 // Valeur par défaut
    }
    
    private func estimateCarbonFootprint(ingredients: [RecipeIngredient]) -> Double {
        // Empreinte carbone estimée basée sur le nombre d'ingrédients
        // Vous pouvez affiner cela avec une base de données d'empreintes carbone
        var totalFootprint = 0.0
        
        for ingredient in ingredients {
            let name = ingredient.name.lowercased()
            
            // Estimations approximatives en g CO2eq
            if name.contains("boeuf") || name.contains("veau") {
                totalFootprint += 2700 * ingredient.quantity
            } else if name.contains("poulet") || name.contains("volaille") {
                totalFootprint += 690 * ingredient.quantity
            } else if name.contains("poisson") {
                totalFootprint += 500 * ingredient.quantity
            } else if name.contains("fromage") {
                totalFootprint += 1150 * ingredient.quantity
            } else if name.contains("légume") || name.contains("fruit") {
                totalFootprint += 50 * ingredient.quantity
            } else {
                totalFootprint += 200 * ingredient.quantity // Valeur par défaut
            }
        }
        
        return max(100, totalFootprint) // Minimum 100g CO2eq
    }
    
    private func detectDietaryTags(ingredients: [MarmitonIngredient]?) -> [String] {
        guard let ingredients = ingredients else { return [] }
        
        var tags: [String] = []
        let ingredientNames = ingredients.map { $0.nom.lowercased() }
        
        // Vérifier si c'est végétarien
        let hasAnimalProducts = ingredientNames.contains { name in
            name.contains("viande") || name.contains("poulet") || 
            name.contains("boeuf") || name.contains("porc") ||
            name.contains("poisson") || name.contains("saumon")
        }
        
        if !hasAnimalProducts {
            tags.append("Végétarien")
            
            // Vérifier si c'est vegan
            let hasDairyOrEggs = ingredientNames.contains { name in
                name.contains("lait") || name.contains("fromage") ||
                name.contains("beurre") || name.contains("oeuf") ||
                name.contains("crème")
            }
            
            if !hasDairyOrEggs {
                tags.append("Vegan")
            }
        }
        
        // Vérifier sans gluten
        let hasGluten = ingredientNames.contains { name in
            name.contains("farine") || name.contains("pain") ||
            name.contains("pâtes")
        }
        
        if !hasGluten {
            tags.append("Sans gluten")
        }
        
        return tags
    }
    
    private func detectAllergens(ingredients: [MarmitonIngredient]?) -> [String] {
        guard let ingredients = ingredients else { return [] }
        
        var allergens: [String] = []
        let ingredientNames = ingredients.map { $0.nom.lowercased() }
        
        if ingredientNames.contains(where: { $0.contains("gluten") || $0.contains("farine") || $0.contains("blé") }) {
            allergens.append("Gluten")
        }
        
        if ingredientNames.contains(where: { $0.contains("lait") || $0.contains("lactose") || $0.contains("fromage") }) {
            allergens.append("Lactose")
        }
        
        if ingredientNames.contains(where: { $0.contains("oeuf") }) {
            allergens.append("Œufs")
        }
        
        if ingredientNames.contains(where: { $0.contains("noix") || $0.contains("noisette") || $0.contains("amande") }) {
            allergens.append("Fruits à coque")
        }
        
        return allergens
    }
}

// MARK: - Erreurs

enum PostgreSQLError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL invalide"
        case .invalidResponse:
            return "Réponse du serveur invalide"
        case .decodingError:
            return "Erreur de décodage des données"
        case .networkError(let error):
            return "Erreur réseau: \(error.localizedDescription)"
        }
    }
}
