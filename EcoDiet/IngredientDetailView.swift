import SwiftUI
import SwiftData

/// Vue de détail d'un ingrédient
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
