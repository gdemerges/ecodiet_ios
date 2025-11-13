//
//  OpenFoodFactsService.swift
//  EcoDiet
//
//  Created by Guillaume Demergès on 13/11/2025.
//

import Foundation

/// Service pour interagir avec l'API OpenFoodFacts
@Observable
class OpenFoodFactsService {
    
    // MARK: - Models
    
    struct ProductResponse: Codable {
        let status: Int
        let product: Product?
        
        struct Product: Codable {
            let productName: String?
            let brands: String?
            let categories: String?
            let imageUrl: String?
            let nutriments: Nutriments?
            let ingredients: [Ingredient]?
            let ecoscoreGrade: String?
            let nutriscoreGrade: String?
            let quantity: String?
            
            enum CodingKeys: String, CodingKey {
                case productName = "product_name"
                case brands
                case categories
                case imageUrl = "image_url"
                case nutriments
                case ingredients
                case ecoscoreGrade = "ecoscore_grade"
                case nutriscoreGrade = "nutriscore_grade"
                case quantity
            }
            
            struct Nutriments: Codable {
                let energyKcal100g: Double?
                let proteins100g: Double?
                let carbohydrates100g: Double?
                let fat100g: Double?
                let fiber100g: Double?
                
                enum CodingKeys: String, CodingKey {
                    case energyKcal100g = "energy-kcal_100g"
                    case proteins100g = "proteins_100g"
                    case carbohydrates100g = "carbohydrates_100g"
                    case fat100g = "fat_100g"
                    case fiber100g = "fiber_100g"
                }
            }
            
            struct Ingredient: Codable {
                let id: String?
                let text: String?
                let vegan: String?
                let vegetarian: String?
            }
        }
    }
    
    struct FoodProduct: Identifiable {
        let id = UUID()
        let barcode: String
        let name: String
        let brand: String?
        let categories: [String]
        let imageUrl: String?
        let quantity: String?
        let ecoscoreGrade: String?
        let nutriscoreGrade: String?
        let ingredientsList: [String]
        
        var suggestedCategory: IngredientCategory {
            let categoriesText = categories.joined(separator: " ").lowercased()
            
            if categoriesText.contains("fruit") {
                return .fruit
            } else if categoriesText.contains("légume") || categoriesText.contains("vegetable") {
                return .vegetable
            } else if categoriesText.contains("viande") || categoriesText.contains("poisson") ||
                      categoriesText.contains("meat") || categoriesText.contains("fish") ||
                      categoriesText.contains("œuf") || categoriesText.contains("egg") {
                return .protein
            } else if categoriesText.contains("lait") || categoriesText.contains("fromage") ||
                      categoriesText.contains("dairy") || categoriesText.contains("cheese") ||
                      categoriesText.contains("yaourt") || categoriesText.contains("yogurt") {
                return .dairy
            } else if categoriesText.contains("céréale") || categoriesText.contains("pain") ||
                      categoriesText.contains("pâte") || categoriesText.contains("riz") ||
                      categoriesText.contains("grain") || categoriesText.contains("bread") {
                return .grain
            } else if categoriesText.contains("huile") || categoriesText.contains("oil") {
                return .oil
            } else if categoriesText.contains("épice") || categoriesText.contains("spice") ||
                      categoriesText.contains("condiment") {
                return .spice
            } else {
                return .other
            }
        }
        
        var suggestedUnit: IngredientUnit {
            guard let quantity = quantity?.lowercased() else { return .piece }
            
            if quantity.contains("kg") {
                return .kilogram
            } else if quantity.contains("g") {
                return .gram
            } else if quantity.contains("l") && !quantity.contains("ml") {
                return .liter
            } else if quantity.contains("ml") {
                return .milliliter
            } else {
                return .piece
            }
        }
        
        var extractedQuantity: Double {
            guard let quantity = quantity else { return 1.0 }
            
            // Extraire le nombre du texte (ex: "500g" -> 500)
            let numbers = quantity.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return Double(numbers) ?? 1.0
        }
    }
    
    // MARK: - Properties
    
    private let baseURL = "https://world.openfoodfacts.org/api/v2/product"
    private let session: URLSession
    
    // MARK: - Initialization
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Public Methods
    
    /// Recherche un produit par code-barres
    func fetchProduct(barcode: String) async throws -> FoodProduct? {
        guard !barcode.isEmpty else {
            throw OpenFoodFactsError.invalidBarcode
        }
        
        let urlString = "\(baseURL)/\(barcode).json"
        
        guard let url = URL(string: urlString) else {
            throw OpenFoodFactsError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("EcoDiet - iOS - Version 1.0", forHTTPHeaderField: "User-Agent")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenFoodFactsError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw OpenFoodFactsError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let productResponse = try decoder.decode(ProductResponse.self, from: data)
        
        guard productResponse.status == 1, let product = productResponse.product else {
            return nil // Produit non trouvé
        }
        
        return mapProductToFoodProduct(product: product, barcode: barcode)
    }
    
    // MARK: - Private Methods
    
    private func mapProductToFoodProduct(product: ProductResponse.Product, barcode: String) -> FoodProduct {
        let name = product.productName ?? "Produit inconnu"
        let categories = (product.categories ?? "").split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        
        // Extraire les noms des ingrédients
        let ingredientsList = product.ingredients?.compactMap { $0.text } ?? []
        
        return FoodProduct(
            barcode: barcode,
            name: name,
            brand: product.brands,
            categories: categories,
            imageUrl: product.imageUrl,
            quantity: product.quantity,
            ecoscoreGrade: product.ecoscoreGrade,
            nutriscoreGrade: product.nutriscoreGrade,
            ingredientsList: ingredientsList
        )
    }
}

// MARK: - Errors

enum OpenFoodFactsError: LocalizedError {
    case invalidBarcode
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case productNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidBarcode:
            return "Code-barres invalide"
        case .invalidURL:
            return "URL invalide"
        case .invalidResponse:
            return "Réponse du serveur invalide"
        case .httpError(let statusCode):
            return "Erreur HTTP \(statusCode)"
        case .productNotFound:
            return "Produit non trouvé dans la base de données"
        }
    }
}
