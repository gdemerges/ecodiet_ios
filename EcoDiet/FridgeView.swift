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

    /// Résultat du filtrage optimisé en une seule passe
    private var filteredResults: (inFridge: [Ingredient], notInFridge: [Ingredient]) {
        var inFridge: [Ingredient] = []
        var notInFridge: [Ingredient] = []

        for ingredient in fridgeManager.ingredients {
            // Filtre par texte de recherche
            if !debouncedSearchText.isEmpty {
                guard ingredient.name.localizedCaseInsensitiveContains(debouncedSearchText) else {
                    continue
                }
            }

            // Filtre par catégorie
            if let category = selectedCategory {
                guard ingredient.category == category else {
                    continue
                }
            }

            // Répartir dans les bonnes listes
            if ingredient.isInFridge {
                inFridge.append(ingredient)
            } else {
                notInFridge.append(ingredient)
            }
        }

        return (inFridge, notInFridge)
    }

    var ingredientsInFridge: [Ingredient] {
        filteredResults.inFridge
    }

    var ingredientsNotInFridge: [Ingredient] {
        filteredResults.notInFridge
    }

    var body: some View {
        ZStack {
            AuthBackground().ignoresSafeArea()

            VStack(spacing: 0) {
                // Header avec stats et recherche
                FridgeHeaderStats(
                    ingredientsInFridgeCount: ingredientsInFridge.count,
                    totalIngredientsCount: fridgeManager.ingredients.count,
                    searchText: $searchText,
                    selectedCategory: selectedCategory,
                    showingCategoryPicker: $showingCategoryPicker
                )

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
                            IngredientSection(
                                title: "Dans mon frigo",
                                icon: "refrigerator.fill",
                                iconColor: Color(red: 0.3, green: 0.7, blue: 0.4),
                                count: ingredientsInFridge.count,
                                ingredients: ingredientsInFridge,
                                fridgeManager: fridgeManager
                            )
                        }

                        // Ingrédients pas encore dans le frigo
                        if !ingredientsNotInFridge.isEmpty {
                            IngredientSection(
                                title: "Autres ingrédients",
                                icon: "basket.fill",
                                iconColor: .secondary,
                                count: ingredientsNotInFridge.count,
                                ingredients: ingredientsNotInFridge,
                                fridgeManager: fridgeManager
                            )
                        }

                        // Message si aucun ingrédient
                        if fridgeManager.ingredients.isEmpty {
                            EmptyFridgeView()
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 80)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showingCategoryPicker)
            }

            // Boutons flottants
            FridgeFloatingActions(
                showingBarcodeScanner: $showingBarcodeScanner,
                showingAddIngredient: $showingAddIngredient
            )
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
