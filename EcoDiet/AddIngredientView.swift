import SwiftUI
import SwiftData

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
    
    var body: some View {
        NavigationStack {
            ZStack {
                AuthBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Scanner de code-barres
                        barcodeScannerButton
                        
                        // Produit scanné
                        if let product = scannedProduct {
                            scannedProductCard(product)
                        }
                        
                        // Ingrédients populaires
                        if showingPopularIngredients && scannedProduct == nil {
                            popularIngredientsSection
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Formulaire personnalisé
                        customIngredientForm
                    }
                    .padding(20)
                    .padding(.bottom, 100)
                }
                
                // Indicateur de chargement
                if isLoadingProduct {
                    loadingOverlay
                }
                
                // Bouton de création fixe en bas
                addIngredientButton
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
    
    // MARK: - Barcode Scanner Button
    
    private var barcodeScannerButton: some View {
        Button {
            checkCameraPermissionAndScan()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.5, green: 0.4, blue: 0.9),
                                    Color(red: 0.4, green: 0.3, blue: 0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scanner un code-barres")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("Recherche via OpenFoodFacts")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.5, green: 0.4, blue: 0.9).opacity(0.4),
                                Color(red: 0.4, green: 0.3, blue: 0.8).opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color(red: 0.5, green: 0.4, blue: 0.9).opacity(0.2), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Scanned Product Card
    
    private func scannedProductCard(_ product: OpenFoodFactsService.FoodProduct) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Produit scanné")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    withAnimation {
                        scannedProduct = nil
                        ingredientName = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.tertiary)
                }
            }
            
            HStack(spacing: 12) {
                // Image du produit ou placeholder
                Group {
                    if let imageUrlString = product.imageUrl,
                       let imageUrl = URL(string: imageUrlString) {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            productPlaceholder
                        }
                    } else {
                        productPlaceholder
                    }
                }
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(product.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    
                    if let brand = product.brand {
                        Text(brand)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 8) {
                        if let ecoScore = product.ecoscoreGrade?.uppercased() {
                            scoreLabel("Eco: \(ecoScore)", color: ecoScoreColor(ecoScore))
                        }
                        
                        if let nutriScore = product.nutriscoreGrade?.uppercased() {
                            scoreLabel("Nutri: \(nutriScore)", color: nutriScoreColor(nutriScore))
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), lineWidth: 2)
        )
    }
    
    private var productPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.gray.opacity(0.2))
            
            Image(systemName: "photo")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }
    
    private func scoreLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color)
            )
    }
    
    private func ecoScoreColor(_ grade: String) -> Color {
        switch grade {
        case "A": return Color.green
        case "B": return Color(red: 0.6, green: 0.8, blue: 0.3)
        case "C": return Color.yellow
        case "D": return Color.orange
        case "E": return Color.red
        default: return Color.gray
        }
    }
    
    private func nutriScoreColor(_ grade: String) -> Color {
        switch grade {
        case "A": return Color.green
        case "B": return Color(red: 0.6, green: 0.8, blue: 0.3)
        case "C": return Color.yellow
        case "D": return Color.orange
        case "E": return Color.red
        default: return Color.gray
        }
    }
    
    // MARK: - Loading Overlay
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Recherche du produit...")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
        }
    }
    
    // MARK: - Popular Ingredients Section
    
    private var popularIngredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ingrédients populaires")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    withAnimation {
                        showingPopularIngredients = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Text("Cliquez pour ajouter rapidement")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            popularIngredientsGrid
        }
        .padding(.top, 8)
    }
    
    private var popularIngredientsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ], spacing: 10) {
            ForEach(FridgeManager.popularIngredients().prefix(6)) { ingredient in
                popularIngredientButton(ingredient)
            }
        }
    }
    
    private func popularIngredientButton(_ ingredient: Ingredient) -> some View {
        Button {
            addPopularIngredient(ingredient)
        } label: {
            HStack(spacing: 10) {
                ingredientIcon(for: ingredient)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(ingredient.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Text(ingredient.category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer(minLength: 0)
                
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color(red: 0.3, green: 0.7, blue: 0.4))
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(ingredient.category.color.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func ingredientIcon(for ingredient: Ingredient) -> some View {
        ZStack {
            Circle()
                .fill(ingredient.category.color.opacity(0.2))
                .frame(width: 36, height: 36)
            
            Image(systemName: ingredient.category.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(ingredient.category.color)
        }
    }
    
    // MARK: - Custom Ingredient Form
    
    private var customIngredientForm: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Ajouter un ingrédient personnalisé")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            ingredientNameField
            categorySelector
            quantityAndUnitSection
            addToFridgeToggle
        }
    }
    
    private var ingredientNameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nom de l'ingrédient")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
            
            TextField("Ex: Tomates, Poulet...", text: $ingredientName)
                .textFieldStyle(.plain)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(selectedCategory.color.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private var categorySelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Catégorie")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(IngredientCategory.allCases, id: \.self) { category in
                        categoryButton(category)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
    
    private func categoryButton(_ category: IngredientCategory) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedCategory = category
            }
        } label: {
            VStack(spacing: 8) {
                categoryIconCircle(category)
                
                Text(category.rawValue)
                    .font(.caption2)
                    .foregroundStyle(selectedCategory == category ? category.color : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 70)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(selectedCategory == category ? category.color.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(selectedCategory == category ? category.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func categoryIconCircle(_ category: IngredientCategory) -> some View {
        ZStack {
            Circle()
                .fill(selectedCategory == category ? AnyShapeStyle(category.color.gradient) : AnyShapeStyle(category.color.opacity(0.2)))
                .frame(width: 50, height: 50)
            
            Image(systemName: category.icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(selectedCategory == category ? .white : category.color)
        }
    }
    
    private var quantityAndUnitSection: some View {
        HStack(spacing: 12) {
            quantitySelector
            unitSelector
        }
    }
    
    private var quantitySelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quantité")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
            
            HStack {
                Button {
                    if quantity > 0.5 {
                        quantity -= 0.5
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                
                Text(String(format: "%.1f", quantity))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(minWidth: 50)
                
                Button {
                    quantity += 0.5
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color(red: 0.3, green: 0.7, blue: 0.4))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
        }
    }
    
    private var unitSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Unité")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
            
            Menu {
                ForEach(IngredientUnit.allCases, id: \.self) { unit in
                    Button {
                        selectedUnit = unit
                    } label: {
                        HStack {
                            Text(unit.displayName)
                            if selectedUnit == unit {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selectedUnit.displayName)
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
            }
        }
    }
    
    private var addToFridgeToggle: some View {
        Toggle(isOn: $addToFridge) {
            HStack(spacing: 8) {
                Image(systemName: "refrigerator.fill")
                    .font(.body)
                    .foregroundStyle(addToFridge ? Color(red: 0.3, green: 0.7, blue: 0.4) : .secondary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ajouter au frigo")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                    
                    Text("Marquer comme disponible")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .tint(Color(red: 0.3, green: 0.7, blue: 0.4))
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Add Ingredient Button
    
    private var addIngredientButton: some View {
        VStack {
            Spacer()
            
            Button {
                addCustomIngredient()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Ajouter l'ingrédient")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.3, green: 0.7, blue: 0.4),
                            Color(red: 0.2, green: 0.6, blue: 0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .disabled(ingredientName.isEmpty)
            .opacity(ingredientName.isEmpty ? 0.5 : 1.0)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - Helper Methods
    
    private func checkCameraPermissionAndScan() {
        let status = CameraPermissionHelper.checkPermission()
        
        switch status {
        case .authorized:
            showingBarcodeScanner = true
            
        case .notDetermined:
            Task {
                let granted = await CameraPermissionHelper.requestPermission()
                await MainActor.run {
                    if granted {
                        showingBarcodeScanner = true
                    } else {
                        showingPermissionDenied = true
                    }
                }
            }
            
        case .denied:
            showingPermissionDenied = true
        }
    }
    
    private func handleScannedBarcode(_ barcode: String) {
        isLoadingProduct = true
        
        Task {
            do {
                if let product = try await openFoodFactsService.fetchProduct(barcode: barcode) {
                    await MainActor.run {
                        scannedProduct = product
                        ingredientName = product.name
                        selectedCategory = product.suggestedCategory
                        selectedUnit = product.suggestedUnit
                        
                        // Essayer d'extraire la quantité du produit
                        let extractedQty = product.extractedQuantity
                        if extractedQty > 0 {
                            // Convertir selon l'unité
                            if product.suggestedUnit == .kilogram && extractedQty > 50 {
                                quantity = extractedQty / 1000 // Convertir g en kg
                            } else if product.suggestedUnit == .liter && extractedQty > 50 {
                                quantity = extractedQty / 1000 // Convertir ml en L
                            } else {
                                quantity = extractedQty
                            }
                        }
                        
                        isLoadingProduct = false
                    }
                } else {
                    await MainActor.run {
                        isLoadingProduct = false
                        errorMessage = "Produit non trouvé dans la base de données OpenFoodFacts"
                        showingError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoadingProduct = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
    
    private func addPopularIngredient(_ ingredient: Ingredient) {
        let newIngredient = Ingredient(
            name: ingredient.name,
            category: ingredient.category,
            unit: ingredient.unit,
            quantity: ingredient.quantity,
            isInFridge: true,
            imageName: ingredient.imageName
        )
        fridgeManager.addIngredient(newIngredient)
        dismiss()
    }
    
    private func addCustomIngredient() {
        let newIngredient = Ingredient(
            name: ingredientName,
            category: selectedCategory,
            unit: selectedUnit,
            quantity: quantity,
            isInFridge: addToFridge,
            imageName: selectedCategory.icon
        )
        fridgeManager.addIngredient(newIngredient)
        dismiss()
    }
}

#Preview {
    @MainActor in
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let schema = Schema([
        Recipe.self,
        RecipeFolder.self,
        UserProfile.self,
        Ingredient.self
    ])
    let container = try! ModelContainer(for: schema, configurations: config)
    let context = ModelContext(container)
    let fridgeManager = FridgeManager(modelContext: context)
    
    return AddIngredientView(fridgeManager: fridgeManager)
}
