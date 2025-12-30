import SwiftUI
import SwiftData

struct FridgeView: View {
    let fridgeManager: FridgeManager
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var debouncedSearchText = ""
    @State private var showingAddIngredient = false
    @State private var showingBarcodeScanner = false
    @State private var selectedCategory: IngredientCategory? = nil
    @State private var showingCategoryPicker = false
    @State private var searchDebouncer = Debouncer(delay: 0.3)

    var filteredIngredients: [Ingredient] {
        let filtered = debouncedSearchText.isEmpty ? fridgeManager.ingredients : fridgeManager.ingredients.filter { ingredient in
            ingredient.name.localizedCaseInsensitiveContains(debouncedSearchText)
        }
        
        if let category = selectedCategory {
            return filtered.filter { $0.category == category }
        }
        
        return filtered
    }
    
    var ingredientsInFridge: [Ingredient] {
        filteredIngredients.filter { $0.isInFridge }
    }
    
    var ingredientsNotInFridge: [Ingredient] {
        filteredIngredients.filter { !$0.isInFridge }
    }
    
    var body: some View {
        ZStack {
            AuthBackground().ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header avec stats
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        // Stat carte : Ingrédients disponibles
                        FridgeStatCard(
                            icon: "checkmark.circle.fill",
                            value: "\(ingredientsInFridge.count)",
                            label: "Disponibles",
                            color: Color(red: 0.3, green: 0.7, blue: 0.4)
                        )
                        
                        // Stat carte : Total
                        FridgeStatCard(
                            icon: "list.bullet.circle.fill",
                            value: "\(fridgeManager.ingredients.count)",
                            label: "Total",
                            color: Color(red: 0.4, green: 0.6, blue: 0.9)
                        )
                    }
                    
                    // Barre de recherche
                    HStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.secondary)
                            
                            TextField("Rechercher un ingrédient", text: $searchText)
                                .textFieldStyle(.plain)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                        
                        // Bouton filtre par catégorie
                        Button {
                            showingCategoryPicker.toggle()
                        } label: {
                            Image(systemName: selectedCategory != nil ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundStyle(selectedCategory != nil ? Color(red: 0.3, green: 0.7, blue: 0.4) : .secondary)
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // Liste des ingrédients
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Catégories si filtre actif
                        if showingCategoryPicker {
                            CategoryFilterView(selectedCategory: $selectedCategory)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Ingrédients dans le frigo
                        if !ingredientsInFridge.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "refrigerator.fill")
                                        .font(.title3)
                                        .foregroundStyle(Color(red: 0.3, green: 0.7, blue: 0.4))
                                    
                                    Text("Dans mon frigo")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    Text("\(ingredientsInFridge.count)")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(.ultraThinMaterial)
                                        )
                                }
                                
                                VStack(spacing: 10) {
                                    ForEach(ingredientsInFridge) { ingredient in
                                        IngredientRow(ingredient: ingredient, fridgeManager: fridgeManager)
                                    }
                                }
                            }
                        }
                        
                        // Ingrédients pas encore dans le frigo
                        if !ingredientsNotInFridge.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "basket.fill")
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("Autres ingrédients")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(.primary)
                                    
                                    Spacer()
                                    
                                    Text("\(ingredientsNotInFridge.count)")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(.ultraThinMaterial)
                                        )
                                }
                                
                                VStack(spacing: 10) {
                                    ForEach(ingredientsNotInFridge) { ingredient in
                                        IngredientRow(ingredient: ingredient, fridgeManager: fridgeManager)
                                    }
                                }
                            }
                        }
                        
                        // Message si aucun ingrédient
                        if fridgeManager.ingredients.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "refrigerator")
                                    .font(.system(size: 60, weight: .light))
                                    .foregroundStyle(.secondary)
                                
                                Text("Aucun ingrédient")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(.primary)
                                
                                Text("Ajoutez vos premiers ingrédients\npour commencer")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 80)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showingCategoryPicker)
            }
            
            // Boutons flottants pour ajouter un ingredient
            VStack {
                Spacer()

                HStack(spacing: 12) {
                    Spacer()

                    // Bouton scanner
                    Button {
                        showingBarcodeScanner = true
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 50, height: 50)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.ecoDietOrange, .ecoDietOrange.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: Color.ecoDietOrange.opacity(0.4), radius: 8, x: 0, y: 4)
                    }

                    // Bouton ajouter manuellement
                    Button {
                        showingAddIngredient = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))

                            Text("Ajouter")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
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
                        .clipShape(Capsule())
                        .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Mon frigo")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddIngredient) {
            fridgeManager.loadIngredients()
        } content: {
            AddIngredientView(fridgeManager: fridgeManager)
        }
        .sheet(isPresented: $showingBarcodeScanner) {
            fridgeManager.loadIngredients()
        } content: {
            BarcodeScanIngredientView(fridgeManager: fridgeManager)
        }
        .onAppear {
            // Rafraîchir la liste des ingrédients quand la vue apparaît
            fridgeManager.loadIngredients()
        }
        .onChange(of: searchText) { _, newValue in
            searchDebouncer.debounce {
                await MainActor.run {
                    debouncedSearchText = newValue
                }
            }
        }
    }
}

// Vue pour les stats
struct FridgeStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.gradient)
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// Vue de filtre par catégorie
struct CategoryFilterView: View {
    @Binding var selectedCategory: IngredientCategory?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filtrer par catégorie")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    // Bouton "Toutes"
                    CategoryButton(
                        name: "Toutes",
                        icon: "square.grid.2x2",
                        color: Color(red: 0.6, green: 0.6, blue: 0.6),
                        isSelected: selectedCategory == nil
                    ) {
                        selectedCategory = nil
                    }
                    
                    ForEach(IngredientCategory.allCases, id: \.self) { category in
                        CategoryButton(
                            name: category.rawValue,
                            icon: category.icon,
                            color: category.color,
                            isSelected: selectedCategory == category
                        ) {
                            if selectedCategory == category {
                                selectedCategory = nil
                            } else {
                                selectedCategory = category
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

struct CategoryButton: View {
    let name: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(name)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? color.gradient : Color.clear.gradient)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : color.opacity(0.4), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// Rangée d'ingrédient
struct IngredientRow: View {
    let ingredient: Ingredient
    let fridgeManager: FridgeManager
    @State private var showingDetails = false
    
    var body: some View {
        Button {
            showingDetails = true
        } label: {
            HStack(spacing: 14) {
                // Icône de catégorie
                ZStack {
                    Circle()
                        .fill(ingredient.category.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: ingredient.category.icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(ingredient.category.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(ingredient.name)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)

                    HStack(spacing: 8) {
                        Text(ingredient.category.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if ingredient.isInFridge {
                            HStack(spacing: 2) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption2)

                                Text("Disponible")
                                    .font(.caption2)
                            }
                            .foregroundStyle(Color(red: 0.3, green: 0.7, blue: 0.4))
                        }

                        // Badge d'expiration
                        ExpirationBadge(expirationDate: ingredient.expirationDate)
                    }
                }
                
                Spacer()
                
                // Toggle pour ajouter/retirer du frigo
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        fridgeManager.toggleFridgeStatus(ingredient)
                    }
                } label: {
                    Image(systemName: ingredient.isInFridge ? "refrigerator.fill" : "refrigerator")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(ingredient.isInFridge ? Color(red: 0.3, green: 0.7, blue: 0.4) : .secondary)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(ingredient.isInFridge ? Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.15) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(ingredient.isInFridge ? Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDetails) {
            IngredientDetailView(ingredient: ingredient, fridgeManager: fridgeManager)
        }
    }
}

// Vue de détail d'un ingrédient
struct IngredientDetailView: View {
    let ingredient: Ingredient
    let fridgeManager: FridgeManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AuthBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Icon et infos principales
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(ingredient.category.color.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: ingredient.category.icon)
                                    .font(.system(size: 44, weight: .medium))
                                    .foregroundStyle(ingredient.category.color)
                            }
                            
                            VStack(spacing: 8) {
                                Text(ingredient.name)
                                    .font(.title.weight(.bold))
                                    .foregroundStyle(.primary)
                                
                                Text(ingredient.category.rawValue)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                        
                        // Statut
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Statut")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Image(systemName: ingredient.isInFridge ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(ingredient.isInFridge ? Color(red: 0.3, green: 0.7, blue: 0.4) : .secondary)
                                
                                Text(ingredient.isInFridge ? "Disponible dans le frigo" : "Pas dans le frigo")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                        
                        // Quantité
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quantité")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Image(systemName: "scalemass")
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                                
                                Text("\(String(format: "%.1f", ingredient.quantity)) \(ingredient.unit.rawValue)")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                        
                        // Actions
                        VStack(spacing: 12) {
                            Button {
                                fridgeManager.toggleFridgeStatus(ingredient)
                            } label: {
                                HStack {
                                    Image(systemName: ingredient.isInFridge ? "minus.circle" : "plus.circle")
                                        .font(.system(size: 18, weight: .medium))
                                    
                                    Text(ingredient.isInFridge ? "Retirer du frigo" : "Ajouter au frigo")
                                        .font(.body.weight(.medium))
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.3, green: 0.7, blue: 0.4),
                                            Color(red: 0.2, green: 0.6, blue: 0.5)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    in: RoundedRectangle(cornerRadius: 12)
                                )
                            }
                            
                            Button(role: .destructive) {
                                showingDeleteAlert = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                        .font(.system(size: 18, weight: .medium))
                                    
                                    Text("Supprimer l'ingrédient")
                                        .font(.body.weight(.medium))
                                }
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.red.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Détails")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
            .alert("Supprimer l'ingrédient ?", isPresented: $showingDeleteAlert) {
                Button("Annuler", role: .cancel) {}
                Button("Supprimer", role: .destructive) {
                    fridgeManager.removeIngredient(ingredient)
                    dismiss()
                }
            } message: {
                Text("Cette action est irréversible.")
            }
        }
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
    
    return NavigationStack {
        FridgeView(fridgeManager: fridgeManager)
    }
}
