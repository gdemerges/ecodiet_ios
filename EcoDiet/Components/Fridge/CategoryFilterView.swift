import SwiftUI

/// Vue de filtrage par catégorie d'ingrédient
struct CategoryFilterView: View {
    @Binding var selectedCategory: IngredientCategory?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filtrer par catégorie")
                .font(.headline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
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

#Preview {
    CategoryFilterView(selectedCategory: .constant(nil))
        .padding()
}
