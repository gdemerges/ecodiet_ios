import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    let recipe: Recipe
    let profileManager: UserProfileManager
    let dataManager: SwiftDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingFolderPicker = false
    @State private var showingShareSheet = false

    var body: some View {
        ZStack {
            // Background avec le même style que HomeView
            AuthBackground().ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Image principale de la recette
                    RecipeHeaderImage(imageName: recipe.imageName)

                    VStack(alignment: .leading, spacing: 16) {
                        // Titre et sous-titre
                        VStack(alignment: .leading, spacing: 8) {
                            Text(recipe.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)

                            Text(recipe.subtitle)
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }

                        Divider()
                            .padding(.vertical, 8)

                        // Informations pratiques
                        RecipeInfoCards(recipe: recipe)

                        Divider()
                            .padding(.vertical, 8)

                        // Eco-Score - Impact environnemental
                        EcoScoreDetailView(recipe: recipe)

                        Divider()
                            .padding(.vertical, 8)

                        // Ingrédients
                        RecipeIngredientsSection(ingredients: formattedIngredients)

                        Divider()
                            .padding(.vertical, 8)

                        // Instructions
                        RecipeInstructionsSection(instructions: recipe.etapes.isEmpty ? sampleInstructions : recipe.etapes)

                        // Boutons d'action
                        RecipeActionButtons(
                            recipe: recipe,
                            profileManager: profileManager,
                            showingFolderPicker: $showingFolderPicker,
                            showingShareSheet: $showingShareSheet
                        )
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingFolderPicker) {
            FolderPickerView(recipe: recipe, dataManager: dataManager)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [shareText])
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingShareSheet = true
                    } label: {
                        Label("Partager", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        showingFolderPicker = true
                    } label: {
                        Label("Ajouter à un dossier", systemImage: "folder.badge.plus")
                    }

                    Divider()

                    Button {
                        if profileManager.isFavorite(recipe) {
                            profileManager.removeFavoriteRecipe(recipe)
                        } else {
                            profileManager.addFavoriteRecipe(recipe)
                        }
                    } label: {
                        Label(
                            profileManager.isFavorite(recipe) ? "Retirer des favoris" : "Ajouter aux favoris",
                            systemImage: profileManager.isFavorite(recipe) ? "heart.slash" : "heart"
                        )
                    }

                    Divider()

                    Button(role: .destructive) {
                        // Action pour signaler un problème
                    } label: {
                        Label("Signaler un problème", systemImage: "exclamationmark.triangle")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
        }
    }

    // Formatte les ingrédients pour l'affichage
    private var formattedIngredients: [String] {
        // Utiliser les vrais ingrédients si disponibles
        if !recipe.requiredIngredients.isEmpty {
            return recipe.requiredIngredients.map { ingredient in
                let quantityStr = ingredient.quantity > 0 ? "\(Int(ingredient.quantity))" : ""
                let unitStr = ingredient.unit.isEmpty ? "" : ingredient.unit
                let optional = ingredient.isOptional ? " (optionnel)" : ""

                if quantityStr.isEmpty && unitStr.isEmpty {
                    return "\(ingredient.name)\(optional)"
                } else if quantityStr.isEmpty {
                    return "\(unitStr) de \(ingredient.name)\(optional)"
                } else if unitStr.isEmpty {
                    return "\(quantityStr) \(ingredient.name)\(optional)"
                } else {
                    return "\(quantityStr)\(unitStr) de \(ingredient.name)\(optional)"
                }
            }
        }
        // Fallback sur les données d'exemple
        return sampleIngredients
    }

    // Texte de partage pour la recette
    private var shareText: String {
        """
        🍽️ Découvrez cette recette : \(recipe.title)

        \(recipe.subtitle)

        ⏱️ Temps de préparation : \(recipe.preparationTime) minutes
        🌱 Eco-Score : \(recipe.ecoScore.rawValue) - \(recipe.ecoScore.description)
        🌍 Empreinte carbone : \(Int(recipe.carbonFootprint))g CO2eq

        Partagé depuis EcoDiet - L'app pour une alimentation saine et durable ! 🌿
        """
    }

    // Données d'exemple basées sur le type de recette
    private var sampleIngredients: [String] {
        switch recipe.title {
        case "Bowl veggie":
            return [
                "200g de quinoa",
                "150g de pois chiches",
                "1 avocat mûr",
                "100g d'épinards frais",
                "2 carottes",
                "Graines de tournesol",
                "Huile d'olive",
                "Citron"
            ]
        case "Salade césar":
            return [
                "1 laitue romaine",
                "200g de blanc de poulet",
                "50g de parmesan",
                "Croûtons",
                "2 œufs",
                "Anchois",
                "Huile d'olive",
                "Ail"
            ]
        case "Pâtes complètes":
            return [
                "300g de pâtes complètes",
                "400g de tomates fraîches",
                "Basilic frais",
                "3 gousses d'ail",
                "Huile d'olive",
                "Parmesan râpé",
                "Sel et poivre"
            ]
        case "Soupe de saison":
            return [
                "1kg de potiron",
                "200ml de lait de coco",
                "1 oignon",
                "2 gousses d'ail",
                "Gingembre frais",
                "Bouillon de légumes",
                "Épices (curcuma, curry)"
            ]
        default:
            return [
                "Ingrédient 1",
                "Ingrédient 2",
                "Ingrédient 3",
                "Ingrédient 4"
            ]
        }
    }

    private var sampleInstructions: [String] {
        switch recipe.title {
        case "Bowl veggie":
            return [
                "Rincer le quinoa et le cuire dans 400ml d'eau salée pendant 15 minutes.",
                "Faire revenir les pois chiches avec un peu d'huile d'olive et des épices.",
                "Laver et couper les légumes en julienne.",
                "Disposer tous les ingrédients dans un bol et arroser d'un mélange huile d'olive-citron."
            ]
        case "Salade césar":
            return [
                "Laver et couper la salade romaine en morceaux.",
                "Cuire le poulet à la poêle avec un peu d'huile, saler et poivrer.",
                "Préparer la sauce césar avec l'ail, les anchois, l'œuf et l'huile d'olive.",
                "Mélanger la salade avec la sauce, ajouter le poulet et parsemer de parmesan."
            ]
        case "Pâtes complètes":
            return [
                "Faire cuire les pâtes dans un grand volume d'eau salée selon les instructions.",
                "Faire revenir l'ail émincé dans l'huile d'olive.",
                "Ajouter les tomates coupées en dés et laisser mijoter 10 minutes.",
                "Mélanger les pâtes égouttées avec la sauce, ajouter le basilic et le parmesan."
            ]
        case "Soupe de saison":
            return [
                "Éplucher et couper le potiron en cubes.",
                "Faire revenir l'oignon et l'ail dans un peu d'huile.",
                "Ajouter le potiron, le gingembre et couvrir de bouillon.",
                "Laisser mijoter 20 minutes, mixer et ajouter le lait de coco."
            ]
        default:
            return [
                "Étape 1 de préparation",
                "Étape 2 de préparation",
                "Étape 3 de préparation"
            ]
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.primary)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// Composant pour le partage natif iOS
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    @MainActor in
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let schema = Schema([
        Recipe.self,
        RecipeFolder.self,
        UserProfile.self
    ])
    let container = try! ModelContainer(for: schema, configurations: config)
    let context = ModelContext(container)
    let manager = SwiftDataManager(modelContext: context)
    let upm = UserProfileManager()
    upm.configure(with: manager)

    return NavigationStack {
        RecipeDetailView(
            recipe: Recipe(title: "Bowl veggie", subtitle: "Protéines végétales", imageName: "leaf"),
            profileManager: upm,
            dataManager: manager
        )
    }
}
