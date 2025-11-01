import SwiftUI

struct ProfileView: View {
    @State private var profileManager = UserProfileManager()
    @State private var dataManager = RecipeDataManager()
    
    var body: some View {
        ZStack {
            AuthBackground().ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // En-tête du profil
                    ProfileHeaderView(profile: profileManager.userProfile)
                    
                    // Statistiques rapides
                    ProfileStatsView(
                        favoriteCount: profileManager.userProfile.favoriteRecipes.count,
                        folderCount: dataManager.folders.count,
                        memberSince: profileManager.userProfile.joinDate
                    )
                    
                    // Recettes favorites
                    if !profileManager.userProfile.favoriteRecipes.isEmpty {
                        ProfileSectionView(
                            title: "Mes recettes favorites",
                            icon: "heart.fill",
                            content: {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(profileManager.userProfile.favoriteRecipes) { recipe in
                                            NavigationLink {
                                                RecipeDetailView(recipe: recipe)
                                            } label: {
                                                FavoriteRecipeCard(recipe: recipe)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }
                        )
                    }
                    
                    // Mes dossiers
                    if !dataManager.folders.isEmpty {
                        ProfileSectionView(
                            title: "Mes dossiers",
                            icon: "folder.fill",
                            content: {
                                VStack(spacing: 12) {
                                    ForEach(dataManager.folders.prefix(3)) { folder in
                                        NavigationLink {
                                            FolderDetailView(folder: folder, dataManager: dataManager)
                                        } label: {
                                            ProfileFolderRow(folder: folder)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    
                                    if dataManager.folders.count > 3 {
                                        NavigationLink {
                                            FoldersView(dataManager: dataManager)
                                        } label: {
                                            HStack {
                                                Text("Voir tous les dossiers (\(dataManager.folders.count))")
                                                    .font(.subheadline.weight(.medium))
                                                    .foregroundStyle(.secondary)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            .padding(.horizontal, 24)
                                            .padding(.vertical, 12)
                                        }
                                    }
                                }
                            }
                        )
                    }
                    
                    // Préférences et allergies
                    ProfileSectionView(
                        title: "Mes préférences",
                        icon: "gear",
                        content: {
                            VStack(spacing: 16) {
                                PreferenceRow(
                                    title: "Niveau de cuisine",
                                    value: profileManager.userProfile.cookingLevel.rawValue,
                                    icon: "chef.hat"
                                )
                                
                                if !profileManager.userProfile.dietaryPreferences.isEmpty {
                                    PreferenceRow(
                                        title: "Préférences alimentaires",
                                        value: profileManager.userProfile.dietaryPreferences.joined(separator: ", "),
                                        icon: "leaf"
                                    )
                                }
                                
                                if !profileManager.userProfile.allergies.isEmpty {
                                    PreferenceRow(
                                        title: "Allergies",
                                        value: profileManager.userProfile.allergies.joined(separator: ", "),
                                        icon: "exclamationmark.triangle"
                                    )
                                }
                                
                                NavigationLink {
                                    ProfileEditView(profileManager: profileManager)
                                } label: {
                                    HStack {
                                        Text("Modifier les préférences")
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    )
                    
                    // Actions du profil
                    VStack(spacing: 12) {
                        ProfileActionButton(
                            title: "Paramètres du compte",
                            icon: "gearshape.fill",
                            action: { }
                        )
                        
                        ProfileActionButton(
                            title: "Aide et support",
                            icon: "questionmark.circle.fill",
                            action: { }
                        )
                        
                        ProfileActionButton(
                            title: "Confidentialité",
                            icon: "lock.fill",
                            action: { }
                        )
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Profil")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProfileHeaderView: View {
    let profile: UserProfile
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: profile.profileImageName)
                .font(.system(size: 80, weight: .light))
                .foregroundStyle(.primary)
                .padding(20)
                .background(.ultraThinMaterial, in: Circle())
            
            VStack(spacing: 4) {
                Text(profile.name)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Text(profile.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
}

struct ProfileStatsView: View {
    let favoriteCount: Int
    let folderCount: Int
    let memberSince: Date
    
    private var memberSinceText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: memberSince)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            StatCard(
                title: "Favoris",
                value: "\(favoriteCount)",
                icon: "heart.fill"
            )
            
            Divider()
                .frame(height: 40)
            
            StatCard(
                title: "Dossiers",
                value: "\(folderCount)",
                icon: "folder.fill"
            )
            
            Divider()
                .frame(height: 40)
            
            StatCard(
                title: "Membre depuis",
                value: memberSinceText,
                icon: "calendar"
            )
        }
        .padding(.vertical, 16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.primary)
            
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileSectionView<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.primary)
                
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            content
        }
    }
}

struct FavoriteRecipeCard: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 160, height: 100)
                Image(systemName: recipe.imageName)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.primary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                Text(recipe.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct ProfileFolderRow: View {
    let folder: RecipeFolder
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: folder.imageName)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.primary)
                .frame(width: 32, height: 32)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(folder.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                Text("\(folder.recipes.count) recette\(folder.recipes.count > 1 ? "s" : "")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct PreferenceRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                Text(value)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

struct ProfileActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.primary)
                
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
