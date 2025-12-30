import SwiftUI
import SwiftData

/// Rangée affichant un ingrédient avec action pour le frigo
struct IngredientRow: View {
    let ingredient: Ingredient
    let fridgeManager: FridgeManager
    @State private var showingDetails = false

    var body: some View {
        Button {
            showingDetails = true
        } label: {
            HStack(spacing: 14) {
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

                        ExpirationBadge(expirationDate: ingredient.expirationDate)
                    }
                }

                Spacer()

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

#Preview {
    IngredientRow(
        ingredient: Ingredient(
            name: "Tomates",
            category: .vegetable,
            unit: .piece,
            quantity: 5,
            isInFridge: true
        ),
        fridgeManager: FridgeManager(modelContext: ModelContext(try! ModelContainer(for: Ingredient.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))))
    )
    .padding()
}
