import SwiftUI

/// Formulaire de création d'ingrédient personnalisé
struct CustomIngredientForm: View {
    @Binding var ingredientName: String
    @Binding var selectedCategory: IngredientCategory
    @Binding var selectedUnit: IngredientUnit
    @Binding var quantity: Double
    @Binding var addToFridge: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Formulaire personnalisé")
                .font(.headline)
                .foregroundStyle(.secondary)

            // Nom
            VStack(alignment: .leading, spacing: 8) {
                Text("Nom de l'ingrédient")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)

                TextField("Ex: Tomates", text: $ingredientName)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
            }

            // Catégorie
            VStack(alignment: .leading, spacing: 8) {
                Text("Catégorie")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)

                Picker("Catégorie", selection: $selectedCategory) {
                    ForEach(IngredientCategory.allCases, id: \.self) { category in
                        Label(category.rawValue, systemImage: category.icon)
                            .tag(category)
                    }
                }
                .pickerStyle(.menu)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
            }

            // Quantité et unité
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quantité")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)

                    TextField("", value: $quantity, format: .number)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.plain)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Unité")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)

                    Picker("Unité", selection: $selectedUnit) {
                        ForEach(IngredientUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                }
            }

            // Toggle frigo
            Toggle(isOn: $addToFridge) {
                HStack(spacing: 8) {
                    Image(systemName: "refrigerator")
                        .foregroundStyle(addToFridge ? Color(red: 0.3, green: 0.7, blue: 0.4) : .secondary)

                    Text("Ajouter directement au frigo")
                        .font(.body.weight(.medium))
                }
            }
            .tint(Color(red: 0.3, green: 0.7, blue: 0.4))
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
        }
    }
}

#Preview {
    CustomIngredientForm(
        ingredientName: .constant("Tomates"),
        selectedCategory: .constant(.vegetable),
        selectedUnit: .constant(.piece),
        quantity: .constant(1.0),
        addToFridge: .constant(true)
    )
    .padding()
}
