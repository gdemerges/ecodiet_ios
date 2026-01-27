import SwiftUI
import SwiftData

struct FridgeRecommendationsView: View {
    let dataManager: SwiftDataManager
    let fridgeManager: FridgeManager
    let profileManager: UserProfileManager
    
    @State private var maxMissingIngredients: Int = 2
    
    var sortedRecipes: [(recipe: Recipe, match: Double, missing: [RecipeIngredient])] {
        dataManager.recipes.map { recipe in
            let match = fridgeManager.matchPercentage(for: recipe)
            let missing = fridgeManager.missingIngredients(for: recipe)
            return (recipe, match, missing)
        }
        .filter { $0.missing.count <= maxMissingIngredients }
        .sorted { $0.match > $1.match }
    }
    
    var perfectMatches: [(recipe: Recipe, match: Double, missing: [RecipeIngredient])] {
        sortedRecipes.filter { $0.match == 1.0 }
    }
    
    var nearMatches: [(recipe: Recipe, match: Double, missing: [RecipeIngredient])] {
        sortedRecipes.filter { $0.match < 1.0 && $0.match >= 0.5 }
    }
    
    var body: some View {
        ZStack {
            AuthBackground().ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    filterSection
                    perfectMatchesSection
                    nearMatchesSection
                    emptyStateSection
                }
                .padding(20)
            }
        }
        .navigationTitle("Recettes disponibles")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.3, green: 0.7, blue: 0.4),
                                    Color(red: 0.2, green: 0.6, blue: 0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "refrigerator.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recettes possibles")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.primary)
                    
                    Text("Basé sur votre frigo")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            
            // Statistiques
            HStack(spacing: 12) {
                StatCard2(
                    icon: "checkmark.circle.fill",
                    value: "\(perfectMatches.count)",
                    label: "Possibles",
                    color: Color(red: 0.3, green: 0.7, blue: 0.4)
                )
                
                StatCard2(
                    icon: "exclamationmark.circle.fill",
                    value: "\(nearMatches.count)",
                    label: "Presque",
                    color: Color(red: 0.9, green: 0.6, blue: 0.2)
                )
            }
        }
    }
    
    @ViewBuilder
    private var filterSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingrédients manquants tolérés")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                ForEach(0...3, id: \.self) { count in
                    filterButton(for: count)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func filterButton(for count: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                maxMissingIngredients = count
            }
        } label: {
            Text(count == 0 ? "Aucun" : "\(count)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(maxMissingIngredients == count ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(filterButtonBackground(isSelected: maxMissingIngredients == count))
                .overlay(filterButtonBorder(isSelected: maxMissingIngredients == count))
        }
        .buttonStyle(.plain)
    }
    
    private func filterButtonBackground(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(isSelected ? AnyShapeStyle(Color(red: 0.3, green: 0.7, blue: 0.4).gradient) : AnyShapeStyle(.ultraThinMaterial))
    }
    
    private func filterButtonBorder(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .stroke(isSelected ? Color.clear : Color.primary.opacity(0.1), lineWidth: 1)
    }
    
    @ViewBuilder
    private var perfectMatchesSection: some View {
        if !perfectMatches.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .font(.title3)
                        .foregroundStyle(Color(red: 0.3, green: 0.7, blue: 0.4))
                    
                    Text("Vous avez tout !")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("\(perfectMatches.count)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color(red: 0.3, green: 0.7, blue: 0.4))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.2))
                        )
                }
                
                VStack(spacing: 12) {
                    ForEach(perfectMatches, id: \.recipe.id) { item in
                        recipeLink(for: item)
                    }
                }
            }
        }
    }
    
    private func recipeLink(for item: (recipe: Recipe, match: Double, missing: [RecipeIngredient])) -> some View {
        NavigationLink {
            RecipeDetailView(
                recipe: item.recipe,
                profileManager: profileManager,
                dataManager: dataManager
            )
        } label: {
            FridgeRecipeCard(
                recipe: item.recipe,
                matchPercentage: item.match,
                missingIngredients: item.missing
            )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var nearMatchesSection: some View {
        if !nearMatches.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "cart.fill")
                        .font(.title3)
                        .foregroundStyle(Color(red: 0.9, green: 0.6, blue: 0.2))
                    
                    Text("Il manque peu de choses")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("\(nearMatches.count)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color(red: 0.9, green: 0.6, blue: 0.2))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.9, green: 0.6, blue: 0.2).opacity(0.2))
                        )
                }
                
                VStack(spacing: 12) {
                    ForEach(nearMatches, id: \.recipe.id) { item in
                        recipeLink(for: item)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateSection: some View {
        if sortedRecipes.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 60, weight: .light))
                    .foregroundStyle(.secondary)
                
                Text("Aucune recette disponible")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text("Ajoutez plus d'ingrédients à votre frigo\nou augmentez le nombre d'ingrédients manquants tolérés")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
        }
    }
}

struct StatCard2: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)
                
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

struct FridgeRecipeCard: View {
    let recipe: Recipe
    let matchPercentage: Double
    let missingIngredients: [RecipeIngredient]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                // Image de la recette
                ZStack {
                    if recipe.imageName.starts(with: "http://") || recipe.imageName.starts(with: "https://") {
                        // Image depuis URL (PostgreSQL)
                        CachedAsyncImage(url: URL(string: recipe.imageName)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.95, green: 0.97, blue: 0.95),
                                            Color(red: 0.92, green: 0.95, blue: 0.92)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .overlay {
                                    ProgressView()
                                }
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    } else {
                        // SF Symbol
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.95, green: 0.97, blue: 0.95),
                                        Color(red: 0.92, green: 0.95, blue: 0.92)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)

                        Image(systemName: recipe.imageName)
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.3, green: 0.6, blue: 0.4),
                                        Color(red: 0.2, green: 0.5, blue: 0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    // Titre
                    Text(recipe.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    // Sous-titre
                    Text(recipe.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    // Badge de match
                    HStack(spacing: 6) {
                        if matchPercentage == 1.0 {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(Color(red: 0.3, green: 0.7, blue: 0.4))
                            
                            Text("100% compatible")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Color(red: 0.3, green: 0.7, blue: 0.4))
                        } else {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(Color(red: 0.9, green: 0.6, blue: 0.2))
                            
                            Text("\(Int(matchPercentage * 100))% compatible")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(Color(red: 0.9, green: 0.6, blue: 0.2))
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill((matchPercentage == 1.0 ? Color(red: 0.3, green: 0.7, blue: 0.4) : Color(red: 0.9, green: 0.6, blue: 0.2)).opacity(0.15))
                    )
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            
            // Ingrédients manquants
            if !missingIngredients.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Il manque :")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    FlowLayout(spacing: 6) {
                        ForEach(missingIngredients, id: \.name) { ingredient in
                            HStack(spacing: 4) {
                                Image(systemName: "cart")
                                    .font(.caption2)
                                
                                Text(ingredient.name)
                                    .font(.caption2)
                            }
                            .foregroundStyle(Color(red: 0.9, green: 0.6, blue: 0.2))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(Color(red: 0.9, green: 0.6, blue: 0.2).opacity(0.15))
                            )
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    matchPercentage == 1.0 ?
                    Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3) :
                    Color.clear,
                    lineWidth: 2
                )
        )
    }
}



#Preview {
    @MainActor in
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let schema = Schema([
        Recipe.self,
        RecipeFolder.self,
        UserProfile.self,
        Ingredient.self
    ])
    let container = try! ModelContainer(for: schema, configurations: config)
    let context = ModelContext(container)
    let manager = SwiftDataManager(modelContext: context)
    let fridgeManager = FridgeManager(modelContext: context)
    let upm = UserProfileManager()
    upm.configure(with: manager)
    
    return NavigationStack {
        FridgeRecommendationsView(
            dataManager: manager,
            fridgeManager: fridgeManager,
            profileManager: upm
        )
    }
}
