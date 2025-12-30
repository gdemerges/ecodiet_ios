import SwiftUI
import SwiftData

/// Vue pour scanner un code-barres et ajouter l'ingredient au frigo
struct BarcodeScanIngredientView: View {
    let fridgeManager: FridgeManager
    @Environment(\.dismiss) private var dismiss

    @State private var openFoodFactsService = OpenFoodFactsService()
    @State private var scannedProduct: OpenFoodFactsService.FoodProduct?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showScanner = true
    @State private var ingredientAdded = false

    // Champs editables pour l'ingredient
    @State private var ingredientName = ""
    @State private var selectedCategory: IngredientCategory = .other
    @State private var selectedUnit: IngredientUnit = .piece
    @State private var quantity: Double = 1.0

    var body: some View {
        NavigationStack {
            ZStack {
                AuthBackground().ignoresSafeArea()

                if showScanner && scannedProduct == nil {
                    // Vue du scanner
                    VStack {
                        BarcodeScannerView { barcode in
                            Task {
                                await fetchProduct(barcode: barcode)
                            }
                        }

                        if isLoading {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                Text("Recherche du produit...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }

                        if let error = errorMessage {
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.orange)
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .padding()
                        }
                    }
                } else if let product = scannedProduct {
                    // Vue du produit scanne
                    ScrollView {
                        VStack(spacing: 24) {
                            // Image et infos produit
                            productInfoCard(product)

                            // Formulaire d'edition
                            editFormCard

                            // Bouton d'ajout
                            addButton
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Scanner un produit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }

                if scannedProduct != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Rescanner") {
                            resetScanner()
                        }
                    }
                }
            }
            .overlay {
                if ingredientAdded {
                    successOverlay
                }
            }
        }
    }

    // MARK: - Subviews

    private func productInfoCard(_ product: OpenFoodFactsService.FoodProduct) -> some View {
        VStack(spacing: 16) {
            // Image du produit
            if let imageUrl = product.imageUrl, let url = URL(string: imageUrl) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            ProgressView()
                        }
                }
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(spacing: 8) {
                Text(product.name)
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)

                if let brand = product.brand {
                    Text(brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Scores
                HStack(spacing: 16) {
                    if let nutriscore = product.nutriscoreGrade {
                        ScoreBadge(label: "Nutri-Score", grade: nutriscore.uppercased())
                    }
                    if let ecoscore = product.ecoscoreGrade {
                        ScoreBadge(label: "Eco-Score", grade: ecoscore.uppercased())
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    private var editFormCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details de l'ingredient")
                .font(.headline)

            // Nom
            VStack(alignment: .leading, spacing: 8) {
                Text("Nom")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                TextField("Nom de l'ingredient", text: $ingredientName)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                    )
            }

            // Categorie
            VStack(alignment: .leading, spacing: 8) {
                Text("Categorie")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Picker("Categorie", selection: $selectedCategory) {
                    ForEach(IngredientCategory.allCases, id: \.self) { category in
                        Label(category.rawValue, systemImage: category.icon)
                            .tag(category)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                )
            }

            // Quantite et unite
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quantite")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    TextField("Quantite", value: $quantity, format: .number)
                        .textFieldStyle(.plain)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Unite")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Picker("Unite", selection: $selectedUnit) {
                        ForEach(IngredientUnit.allCases, id: \.self) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }

    private var addButton: some View {
        Button {
            addIngredientToFridge()
        } label: {
            HStack {
                Image(systemName: "refrigerator.fill")
                Text("Ajouter au frigo")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [.ecoDietGreen, .ecoDietSecondaryGreen],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 14)
            )
        }
        .disabled(ingredientName.isEmpty)
        .opacity(ingredientName.isEmpty ? 0.6 : 1)
    }

    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)

                Text("Ingredient ajoute !")
                    .font(.title2.weight(.semibold))

                Text(ingredientName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
        }
        .transition(.opacity)
    }

    // MARK: - Actions

    private func fetchProduct(barcode: String) async {
        isLoading = true
        errorMessage = nil

        do {
            if let product = try await openFoodFactsService.fetchProduct(barcode: barcode) {
                await MainActor.run {
                    scannedProduct = product
                    ingredientName = product.name
                    selectedCategory = product.suggestedCategory
                    selectedUnit = product.suggestedUnit
                    quantity = product.extractedQuantity
                    showScanner = false
                }
            } else {
                await MainActor.run {
                    errorMessage = "Produit non trouve dans la base de donnees"
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }

        await MainActor.run {
            isLoading = false
        }
    }

    private func addIngredientToFridge() {
        let ingredient = Ingredient(
            name: ingredientName,
            category: selectedCategory,
            unit: selectedUnit,
            quantity: quantity,
            isInFridge: true
        )

        fridgeManager.addIngredient(ingredient)

        // Feedback haptique
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Afficher le succes
        withAnimation {
            ingredientAdded = true
        }

        // Fermer apres un delai
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }

    private func resetScanner() {
        scannedProduct = nil
        ingredientName = ""
        selectedCategory = .other
        selectedUnit = .piece
        quantity = 1.0
        showScanner = true
        errorMessage = nil
    }
}

// MARK: - Score Badge

private struct ScoreBadge: View {
    let label: String
    let grade: String

    private var gradeColor: Color {
        switch grade.lowercased() {
        case "a": return .green
        case "b": return Color(red: 0.5, green: 0.8, blue: 0.3)
        case "c": return .yellow
        case "d": return .orange
        case "e": return .red
        default: return .gray
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(grade)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(gradeColor, in: Circle())

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    BarcodeScanIngredientView(fridgeManager: {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema([Ingredient.self])
        let container = try! ModelContainer(for: schema, configurations: config)
        return FridgeManager(modelContext: ModelContext(container))
    }())
}
