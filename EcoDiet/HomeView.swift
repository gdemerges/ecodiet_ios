import SwiftUI

struct Recipe: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String
}

struct HomeView: View {
    @State private var recipes: [Recipe] = [
        Recipe(title: "Bowl veggie", subtitle: "Protéines végétales", imageName: "leaf"),
        Recipe(title: "Salade césar", subtitle: "Poulet, parmesan", imageName: "fork.knife"),
        Recipe(title: "Pâtes complètes", subtitle: "Tomates & basilic", imageName: "takeoutbag.and.cup.and.straw"),
        Recipe(title: "Soupe de saison", subtitle: "Potiron & coco", imageName: "cup.and.saucer")
    ]

    var body: some View {
        ZStack {
            AuthBackground().ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text("Bonjour !")
                            .font(.largeTitle).bold()
                        Spacer()
                        NavigationLink {
                            ProfileView()
                        } label: {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundStyle(.primary)
                                .padding(8)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .accessibilityLabel("Profil")
                    }

                    HStack {
                        Text("Juste pour vous")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        NavigationLink {
                            RecommendationView()
                        } label: {
                            Text("Voir tout")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                        .accessibilityLabel("Voir toutes les recommandations")
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(recipes) { recipe in
                                RecipeCard(recipe: recipe)
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                    
                    HStack {
                        Text("Nos recettes")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        NavigationLink {
                            ListView()
                        } label: {
                            Text("Voir tout")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                        .accessibilityLabel("Voir toutes les recettes")
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(recipes) { recipe in
                                RecipeCard(recipe: recipe)
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
                .padding(24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 240, height: 140)
                Image(systemName: recipe.imageName)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            Text(recipe.title)
                .font(.headline)
            Text(recipe.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 8)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
