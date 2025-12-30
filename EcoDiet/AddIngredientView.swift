import SwiftUI
import SwiftData
import AVFoundation

struct AddIngredientView: View {
    let fridgeManager: FridgeManager
    @Environment(\.dismiss) private var dismiss

    @State private var ingredientName = ""
    @State private var selectedCategory: IngredientCategory = .vegetable
    @State private var selectedUnit: IngredientUnit = .piece
    @State private var quantity: Double = 1.0
    @State private var addToFridge = true
    @State private var showingPopularIngredients = true

    // OpenFoodFacts & Scanner
    @State private var showingBarcodeScanner = false
    @State private var showingPermissionDenied = false
    @State private var showingGuide = false
    @State private var isLoadingProduct = false
    @State private var scannedProduct: OpenFoodFactsService.FoodProduct?
    @State private var errorMessage: String?
    @State private var showingError = false
    private let openFoodFactsService = OpenFoodFactsService()

    var isFormValid: Bool {
        !ingredientName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AuthBackground().ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Scanner de code-barres
                        BarcodeScannerButton(action: checkCameraPermissionAndScan)

                        // Produit scanné
                        if let product = scannedProduct {
                            ScannedProductCard(product: product) {
                                withAnimation {
                                    scannedProduct = nil
                                    ingredientName = ""
                                }
                            }
                        }

                        // Ingrédients populaires
                        if showingPopularIngredients && scannedProduct == nil {
                            PopularIngredientsSection { ingredient in
                                selectPopularIngredient(ingredient)
                            }
                        }

                        Divider()
                            .padding(.vertical, 8)

                        // Formulaire personnalisé
                        CustomIngredientForm(
                            ingredientName: $ingredientName,
                            selectedCategory: $selectedCategory,
                            selectedUnit: $selectedUnit,
                            quantity: $quantity,
                            addToFridge: $addToFridge
                        )
                    }
                    .padding(20)
                    .padding(.bottom, 100)
                }

                // Indicateur de chargement
                if isLoadingProduct {
                    LoadingOverlay()
                }

                // Bouton de création fixe en bas
                AddIngredientButton(isEnabled: isFormValid, action: addIngredient)
            }
            .navigationTitle("Nouvel ingrédient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingGuide = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(Color(red: 0.5, green: 0.4, blue: 0.9))
                    }
                }
            }
            .sheet(isPresented: $showingBarcodeScanner) {
                BarcodeScannerView { barcode in
                    showingBarcodeScanner = false
                    handleScannedBarcode(barcode)
                }
            }
            .sheet(isPresented: $showingPermissionDenied) {
                CameraPermissionDeniedView()
            }
            .sheet(isPresented: $showingGuide) {
                BarcodeScannerGuideView()
            }
            .alert("Erreur", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Une erreur est survenue")
            }
        }
    }

    // MARK: - Actions

    private func checkCameraPermissionAndScan() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            showingBarcodeScanner = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showingBarcodeScanner = true
                    } else {
                        showingPermissionDenied = true
                    }
                }
            }
        case .denied, .restricted:
            showingPermissionDenied = true
        @unknown default:
            showingPermissionDenied = true
        }
    }

    private func handleScannedBarcode(_ barcode: String) {
        isLoadingProduct = true
        errorMessage = nil

        Task {
            do {
                if let product = try await openFoodFactsService.fetchProduct(barcode: barcode) {
                    await MainActor.run {
                        scannedProduct = product
                        ingredientName = product.name

                        if let category = mapProductCategoryToIngredientCategory(product.categories.first) {
                            selectedCategory = category
                        }

                        isLoadingProduct = false
                    }
                } else {
                    await MainActor.run {
                        errorMessage = "Produit non trouvé dans la base OpenFoodFacts"
                        showingError = true
                        isLoadingProduct = false
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Erreur lors de la recherche du produit"
                    showingError = true
                    isLoadingProduct = false
                }
            }
        }
    }

    private func selectPopularIngredient(_ ingredient: (String, IngredientCategory)) {
        ingredientName = ingredient.0
        selectedCategory = ingredient.1
        showingPopularIngredients = false
    }

    private func addIngredient() {
        let trimmedName = ingredientName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let newIngredient = Ingredient(
            name: trimmedName,
            category: selectedCategory,
            unit: selectedUnit,
            quantity: quantity,
            isInFridge: addToFridge
        )

        fridgeManager.addIngredient(newIngredient)
        dismiss()
    }

    private func mapProductCategoryToIngredientCategory(_ category: String?) -> IngredientCategory? {
        guard let category = category?.lowercased() else { return nil }

        if category.contains("fruit") { return .fruit }
        if category.contains("vegetable") || category.contains("légume") { return .vegetable }
        if category.contains("dairy") || category.contains("lait") { return .dairy }
        if category.contains("meat") || category.contains("viande") { return .protein }
        if category.contains("grain") || category.contains("céréale") { return .grain }

        return nil
    }
}
