import Foundation

// MARK: - Modèles pour la base de données PostgreSQL

struct MarmitonRecette: Codable, Identifiable {
    let id: Int
    let url: String
    let titre: String?
    let photo: String?
    let duree: String?
    let ingredients: [String]?  // Tableau de strings, pas d'objets
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

    // Initializer pour créer depuis une string
    init(fromString string: String) {
        // Parser "2 kg de tomates" en nom/quantite/unite
        self.nom = string
        self.quantite = nil
        self.unite = nil
    }

    init(nom: String, quantite: String?, unite: String?) {
        self.nom = nom
        self.quantite = quantite
        self.unite = unite
    }
}

// MARK: - Service de connexion PostgreSQL

@Observable
class PostgreSQLService {
    // URL de votre API backend (vous devrez créer cette API)
    private let baseURL = "http://localhost:3002/api"

    private let maxRetries = 3
    private let initialRetryDelay: UInt64 = 500_000_000

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(
            memoryCapacity: 10 * 1024 * 1024,
            diskCapacity: 50 * 1024 * 1024
        )
        return URLSession(configuration: config)
    }()

    // Configuration du décodeur JSON
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()

        // Formatter personnalisé pour gérer les millisecondes dans les dates ISO8601
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Essayer d'abord avec les millisecondes
            if let date = formatter.date(from: dateString) {
                return date
            }

            // Fallback sans millisecondes
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Date invalide: \(dateString)"
            )
        }

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

            let (data, response) = try await session.data(from: url)

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

            let (data, response) = try await session.data(from: url)

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

            let (data, response) = try await session.data(from: url)

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
        // Conversion des ingrédients (depuis strings)
        let recipeIngredients = (marmitonRecette.ingredients ?? []).map { ingredientString in
            let parsedIngredient = parseIngredientString(ingredientString)
            return RecipeIngredient(
                name: parsedIngredient.nom,
                quantity: parseQuantity(parsedIngredient.quantite),
                unit: parsedIngredient.unite ?? "",
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
    
    /// Parse une string d'ingrédient "2 kg de tomates" en objet MarmitonIngredient
    private func parseIngredientString(_ ingredientString: String) -> MarmitonIngredient {
        // Extraire le premier nombre de la string
        let numbers = ingredientString.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .filter { !$0.isEmpty }

        let quantityString = numbers.first

        // Détecter les unités courantes
        let unitsPattern = "(kg|g|ml|cl|l|cuillères?|c\\.|pièces?|tranches?|sachets?)"
        let unite: String?
        if ingredientString.range(of: unitsPattern, options: .regularExpression) != nil {
            if ingredientString.contains("kg") { unite = "kg" }
            else if ingredientString.contains(" g") || ingredientString.contains("grammes") { unite = "g" }
            else if ingredientString.contains("ml") { unite = "ml" }
            else if ingredientString.contains("cl") { unite = "cl" }
            else if ingredientString.contains(" l") || ingredientString.contains("litre") { unite = "l" }
            else if ingredientString.contains("cuillère") || ingredientString.contains("c.") { unite = "c." }
            else { unite = nil }
        } else {
            unite = nil
        }

        return MarmitonIngredient(
            nom: ingredientString,
            quantite: quantityString,
            unite: unite
        )
    }

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
        // Empreinte carbone estimée basée sur les ingrédients
        var totalFootprint = 0.0

        for ingredient in ingredients {
            let name = ingredient.name.lowercased()
            let quantity = max(ingredient.quantity, 1.0) // Au moins 1 si 0

            // Estimations approximatives en g CO2eq par ingrédient/portion
            if name.contains("boeuf") || name.contains("veau") {
                totalFootprint += 2700 * quantity * 0.1 // Facteur 0.1 pour portion standard
            } else if name.contains("poulet") || name.contains("volaille") || name.contains("canard") {
                totalFootprint += 690 * quantity * 0.1
            } else if name.contains("poisson") || name.contains("saumon") || name.contains("thon") {
                totalFootprint += 500 * quantity * 0.1
            } else if name.contains("porc") || name.contains("jambon") || name.contains("lard") || name.contains("cochon") {
                totalFootprint += 1200 * quantity * 0.1
            } else if name.contains("fromage") || name.contains("parmesan") || name.contains("cheddar") {
                totalFootprint += 1150 * quantity * 0.1
            } else if name.contains("lait") || name.contains("crème") || name.contains("beurre") {
                totalFootprint += 300 * quantity * 0.1
            } else if name.contains("oeuf") {
                totalFootprint += 450 * quantity * 0.5
            } else if name.contains("légume") || name.contains("salade") || name.contains("tomate") ||
                      name.contains("carotte") || name.contains("oignon") || name.contains("ail") {
                totalFootprint += 50 * quantity * 0.1
            } else if name.contains("fruit") {
                totalFootprint += 60 * quantity * 0.1
            } else if name.contains("riz") || name.contains("pâtes") || name.contains("pain") {
                totalFootprint += 150 * quantity * 0.1
            } else {
                totalFootprint += 100 // Valeur par défaut par ingrédient
            }
        }

        return max(200, totalFootprint) // Minimum 200g CO2eq
    }
    
    private func detectDietaryTags(ingredients: [String]?) -> [String] {
        guard let ingredients = ingredients else { return [] }

        var tags: [String] = []
        let ingredientNames = ingredients.map { $0.lowercased() }

        // Liste étendue de produits animaux (viandes, poissons, fruits de mer)
        let meatKeywords = [
            // Viandes rouges - Base
            "viande", "boeuf", "bœuf", "veau", "agneau", "mouton", "chevreau",
            // Viandes rouges - Morceaux et préparations
            "rosbif", "rôti", "côte", "entrecôte", "filet mignon", "gigot", "épaule",
            "paleron", "bourguignon", "pot-au-feu", "blanquette", "daube", "carbonade",
            // Viandes blanches - Base
            "poulet", "poule", "dinde", "canard", "oie", "pintade", "volaille",
            // Viandes blanches - Morceaux
            "cuisse", "blanc de poulet", "escalope", "aile", "magret", "confit",
            // Porc
            "porc", "cochon", "jambon", "lard", "lardon", "bacon", "saucisse", "saucisson",
            "chorizo", "pancetta", "coppa", "chipolata", "merguez", "échine", "travers",
            // Produits transformés
            "boulette", "haché", "farce", "brochette", "nugget", "cordon bleu",
            // Poissons
            "poisson", "saumon", "thon", "cabillaud", "merlu", "sole", "truite",
            "bar", "dorade", "anchois", "sardine", "maquereau", "hareng",
            "lotte", "haddock", "pavé", "surimi", "saint-pierre",
            // Fruits de mer
            "crevette", "gambas", "homard", "langouste", "crabe", "moule",
            "huître", "coquille", "saint-jacques", "calmar", "seiche", "poulpe",
            // Abats et charcuterie
            "foie", "rognon", "ris", "langue", "cervelle", "andouillette",
            "boudin", "andouille", "pâté", "terrine", "rillette"
        ]

        // Vérifier si c'est végétarien
        let hasAnimalProducts = ingredientNames.contains { name in
            meatKeywords.contains { keyword in
                name.contains(keyword)
            }
        }

        if !hasAnimalProducts {
            tags.append("Végétarien")

            // Liste étendue de produits laitiers et œufs
            let dairyKeywords = [
                // Produits laitiers de base
                "lait", "fromage", "beurre", "crème", "yaourt", "yogourt",
                // Fromages à pâte dure
                "parmesan", "gruyère", "emmental", "comté", "pecorino",
                "mimolette", "beaufort", "abondance", "tomme",
                // Fromages à pâte molle
                "camembert", "brie", "reblochon", "morbier",
                // Fromages de chèvre et brebis
                "chèvre", "cottin", "bûche", "crottin", "picodon", "sainte-maure", "feta",
                // Fromages italiens
                "mozzarella", "ricotta", "mascarpone", "gorgonzola",
                // Fromages à raclette/fondue
                "raclette", "vacherin",
                // Fromages persillés
                "roquefort", "bleu",
                // Fromages à tartiner
                "kiri", "boursin", "philadelphia", "caprice",
                // Fromages divers
                "cheddar", "gouda", "edam",
                // Œufs
                "oeuf", "œuf", "jaune", "blanc d'oeuf"
            ]

            // Vérifier si c'est vegan
            let hasDairyOrEggs = ingredientNames.contains { name in
                dairyKeywords.contains { keyword in
                    name.contains(keyword)
                }
            }

            if !hasDairyOrEggs {
                tags.append("Vegan")
            }
        }

        // Vérifier sans gluten
        let glutenKeywords = ["farine", "pain", "pâtes", "blé", "orge", "seigle"]
        let hasGluten = ingredientNames.contains { name in
            glutenKeywords.contains { keyword in
                name.contains(keyword)
            }
        }

        if !hasGluten {
            tags.append("Sans gluten")
        }

        return tags
    }
    
    private func detectAllergens(ingredients: [String]?) -> [String] {
        guard let ingredients = ingredients else { return [] }

        var allergens: [String] = []
        let ingredientNames = ingredients.map { $0.lowercased() }

        // Gluten (céréales)
        let glutenKeywords = ["gluten", "farine", "blé", "pain", "pâtes", "orge", "seigle"]
        if ingredientNames.contains(where: { name in
            glutenKeywords.contains { keyword in name.contains(keyword) }
        }) {
            allergens.append("Gluten")
        }

        // Lactose (produits laitiers)
        let lactoseKeywords = [
            "lait", "lactose", "fromage", "beurre", "crème", "yaourt", "yogourt",
            "parmesan", "gruyère", "emmental", "comté", "roquefort", "camembert",
            "brie", "chèvre", "mozzarella", "ricotta", "mascarpone", "cheddar",
            "feta", "reblochon", "raclette", "morbier"
        ]
        if ingredientNames.contains(where: { name in
            lactoseKeywords.contains { keyword in name.contains(keyword) }
        }) {
            allergens.append("Lactose")
        }

        // Œufs
        if ingredientNames.contains(where: { $0.contains("oeuf") || $0.contains("œuf") }) {
            allergens.append("Œufs")
        }

        // Fruits à coque
        let nutsKeywords = [
            "noix", "noisette", "amande", "pistache", "cajou", "cacahuète",
            "arachide", "pécan", "macadamia", "pignon"
        ]
        if ingredientNames.contains(where: { name in
            nutsKeywords.contains { keyword in name.contains(keyword) }
        }) {
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
