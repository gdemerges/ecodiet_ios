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

    private var filteredResults: (inFridge: [Ingredient], notInFridge: [Ingredient]) {
        var inFridge: [Ingredient] = []
        var notInFridge: [Ingredient] = []

        for ingredient in fridgeManager.ingredients {
            if !debouncedSearchText.isEmpty {
                guard ingredient.name.localizedCaseInsensitiveContains(debouncedSearchText) else { continue }
            }
            if let category = selectedCategory {
                guard ingredient.category == category else { continue }
            }
            if ingredient.isInFridge {
                inFridge.append(ingredient)
            } else {
                notInFridge.append(ingredient)
            }
        }

        return (inFridge, notInFridge)
    }

    var body: some View {
        let results = filteredResults
        ZStack {
            AuthBackground().ignoresSafeArea()

            VStack(spacing: 0) {
                FridgeHeaderStats(
                    ingredientsInFridgeCount: results.inFridge.count,
                    totalIngredientsCount: fridgeManager.ingredients.count,
                    searchText: $searchText,
                    selectedCategory: selectedCategory,
                    showingCategoryPicker: $showingCategoryPicker
                )

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if showingCategoryPicker {
                            CategoryFilterView(selectedCategory: $selectedCategory)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        if !results.inFridge.isEmpty {
                            IngredientSection(
                                title: "Dans mon frigo",
                                icon: "refrigerator.fill",
                                iconColor: Color(red: 0.3, green: 0.7, blue: 0.4),
                                count: results.inFridge.count,
                                ingredients: results.inFridge,
                                fridgeManager: fridgeManager
                            )
                        }

                        if !results.notInFridge.isEmpty {
                            IngredientSection(
                                title: "Autres ingrédients",
                                icon: "basket.fill",
                                iconColor: .secondary,
                                count: results.notInFridge.count,
                                ingredients: results.notInFridge,
                                fridgeManager: fridgeManager
                            )
                        }

                        if fridgeManager.ingredients.isEmpty {
                            EmptyFridgeView()
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 80)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showingCategoryPicker)
            }

            FridgeFloatingActions(
                showingBarcodeScanner: $showingBarcodeScanner,
                showingAddIngredient: $showingAddIngredient
            )
        }
        .navigationTitle("Mon frigo")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddIngredient) {
            AddIngredientView(fridgeManager: fridgeManager)
        }
        .sheet(isPresented: $showingBarcodeScanner) {
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
