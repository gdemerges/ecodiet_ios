import SwiftUI
import SwiftData

/// Section affichant une liste d'ingrédients avec un titre
struct IngredientSection: View {
    let title: String
    let icon: String
    let iconColor: Color
    let count: Int
    let ingredients: [Ingredient]
    let fridgeManager: FridgeManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(iconColor)

                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)

                Spacer()

                Text("\(count)")
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
                ForEach(ingredients) { ingredient in
                    IngredientRow(ingredient: ingredient, fridgeManager: fridgeManager)
                }
            }
        }
    }
}

#Preview {
    IngredientSection(
        title: "Dans mon frigo",
        icon: "refrigerator.fill",
        iconColor: Color(red: 0.3, green: 0.7, blue: 0.4),
        count: 5,
        ingredients: [],
        fridgeManager: FridgeManager(modelContext: ModelContext(try! ModelContainer(for: Ingredient.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))))
    )
    .padding()
}
