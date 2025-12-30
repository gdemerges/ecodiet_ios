import SwiftUI

/// Section affichant les ingrédients populaires
struct PopularIngredientsSection: View {
    let onSelect: ((String, IngredientCategory)) -> Void

    private let popularIngredients: [(String, IngredientCategory)] = [
        ("Tomates", .vegetable),
        ("Oignons", .vegetable),
        ("Pommes", .fruit),
        ("Bananes", .fruit),
        ("Lait", .dairy),
        ("Œufs", .protein),
        ("Riz", .grain),
        ("Pâtes", .grain)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingrédients populaires")
                .font(.headline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(popularIngredients, id: \.0) { ingredient in
                    Button {
                        onSelect(ingredient)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: ingredient.1.icon)
                                .font(.body)
                                .foregroundStyle(ingredient.1.color)

                            Text(ingredient.0)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.primary)

                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    PopularIngredientsSection { ingredient in
        print("Selected: \(ingredient.0)")
    }
    .padding()
}
