import SwiftUI

import SwiftUI
import SwiftData

struct RecommendationView: View {
    let dataManager: SwiftDataManager
    let profileManager: UserProfileManager
    
    private var recommendedRecipes: [Recipe] {
        dataManager.getRecommendedRecipes()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommandations")
                        .font(.largeTitle.bold())
                    
                    if let profile = profileManager.userProfile, !profile.dietaryPreferences.isEmpty {
                        Text("Basé sur vos préférences : \(profile.dietaryPreferences.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Voici toutes nos recettes disponibles.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if recommendedRecipes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        
                        Text("Aucune recette correspondante")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text("Modifiez vos préférences alimentaires dans votre profil pour voir plus de recommandations.")
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(recommendedRecipes) { recipe in
                            NavigationLink {
                                RecipeDetailView(recipe: recipe, profileManager: profileManager, dataManager: dataManager)
                            } label: {
                                CompactRecipeCard(recipe: recipe)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle("Recommandations")
        .navigationBarTitleDisplayMode(.inline)
        .background(AuthBackground().ignoresSafeArea())
    }
}

// Carte compacte pour la grille
struct CompactRecipeCard: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(spacing: 0) {
            // Section image/icône
            ZStack(alignment: .topTrailing) {
                if recipe.imageName.starts(with: "http://") || recipe.imageName.starts(with: "https://") {
                    // Image depuis URL (PostgreSQL)
                    CachedAsyncImage(url: URL(string: recipe.imageName)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
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
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                } else {
                    // SF Symbol
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
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
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: recipe.imageName)
                                .font(.system(size: 36, weight: .medium))
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
                        )
                }

                // Badge Eco-Score
                EcoScoreBadge(ecoScore: recipe.ecoScore, size: .small)
                    .padding(8)
            }
            
            // Section infos
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text("\(recipe.preparationTime) min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(recipe.ecoScore.emoji)
                        .font(.caption)
                }
            }
            .padding(12)
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.5),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    @MainActor in
    let config: ModelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
    let schema: Schema = Schema([
        Recipe.self,
        RecipeFolder.self,
        UserProfile.self
    ])
    let container: ModelContainer = try! ModelContainer(for: schema, configurations: config)
    let context: ModelContext = ModelContext(container)
    let manager = SwiftDataManager(modelContext: context)
    let upm = UserProfileManager()
    upm.configure(with: manager)
    return NavigationStack {
        RecommendationView(dataManager: manager, profileManager: upm)
    }
}

