import SwiftUI

/// Header avec statistiques et barre de recherche pour le frigo
struct FridgeHeaderStats: View {
    let ingredientsInFridgeCount: Int
    let totalIngredientsCount: Int
    @Binding var searchText: String
    let selectedCategory: IngredientCategory?
    @Binding var showingCategoryPicker: Bool

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                FridgeStatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(ingredientsInFridgeCount)",
                    label: "Disponibles",
                    color: Color(red: 0.3, green: 0.7, blue: 0.4)
                )

                FridgeStatCard(
                    icon: "list.bullet.circle.fill",
                    value: "\(totalIngredientsCount)",
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
    }
}

#Preview {
    FridgeHeaderStats(
        ingredientsInFridgeCount: 12,
        totalIngredientsCount: 25,
        searchText: .constant(""),
        selectedCategory: nil,
        showingCategoryPicker: .constant(false)
    )
}
