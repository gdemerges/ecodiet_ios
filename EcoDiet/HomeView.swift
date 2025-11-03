import SwiftUI
import SwiftData

struct HomeView: View {
    let dataManager: SwiftDataManager
    let profileManager: UserProfileManager

    private var greeting: String {
        let firstName = profileManager.userProfile?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return firstName.isEmpty ? "Bonjour !" : "Bonjour \(firstName) !"
    }

    var body: some View {
        ZStack {
            AuthBackground().ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text(greeting)
                            .font(.largeTitle).bold()
                        Spacer()
                        NavigationLink {
                            ProfileView(profileManager: profileManager, dataManager: dataManager)
                        } label: {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundStyle(.primary)
                                .padding(8)
                                .background(.ultraThinMaterial, in: Circle())
                        }
                        .accessibilityLabel("Profil")
                    }

                    if let prefs = profileManager.userProfile?.dietaryPreferences, !prefs.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Vos préférences")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.secondary)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(prefs, id: \.self) { pref in
                                        Text(pref)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(.ultraThinMaterial, in: Capsule())
                                            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                                    }
                                }
                            }
                        }
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
                            ForEach(dataManager.recipes) { recipe in
                                NavigationLink {
                                    RecipeDetailView(recipe: recipe, profileManager: profileManager)
                                } label: {
                                    RecipeCard(recipe: recipe)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 2)
                    }

                    HStack {
                        Text("Mes dossiers")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        NavigationLink {
                            FoldersView(dataManager: dataManager)
                        } label: {
                            Text("Gérer")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                        .accessibilityLabel("Gérer les dossiers")
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(dataManager.folders) { folder in
                                FolderCard(folder: folder, dataManager: dataManager)
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
                            ListView(profileManager: profileManager)
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
                            ForEach(dataManager.recipes) { recipe in
                                NavigationLink {
                                    RecipeDetailView(recipe: recipe, profileManager: profileManager)
                                } label: {
                                    RecipeCard(recipe: recipe)
                                }
                                .buttonStyle(PlainButtonStyle())
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

struct FolderCard: View {
    let folder: RecipeFolder
    let dataManager: SwiftDataManager
    
    var body: some View {
        NavigationLink {
            FolderDetailView(folder: folder, dataManager: dataManager)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 240, height: 140)
                    VStack {
                        Image(systemName: folder.imageName)
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text("\(folder.recipes.count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Text(folder.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("\(folder.recipes.count) recette\(folder.recipes.count > 1 ? "s" : "")")
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
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(PlainButtonStyle())
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
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)
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
        HomeView(dataManager: manager, profileManager: upm)
    }
}
