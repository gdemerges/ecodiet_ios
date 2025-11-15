import SwiftUI
import SwiftData

struct ProfileView: View {
    let profileManager: UserProfileManager
    let dataManager: SwiftDataManager
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        ZStack {
            AuthBackground().ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // En-tête du profil
                    ProfileHeaderView(profile: profileManager.userProfile ?? UserProfile())
                    
                    // Statistiques rapides
                    ProfileStatsView(
                        favoriteCount: profileManager.userProfile?.favoriteRecipes.count ?? 0,
                        folderCount: dataManager.folders.count,
                        memberSince: profileManager.userProfile?.joinDate ?? Date()
                    )
                    
                    // Recettes favorites
                    if let favoriteRecipes = profileManager.userProfile?.favoriteRecipes, !favoriteRecipes.isEmpty {
                        ProfileSectionView(
                            title: "Mes recettes favorites",
                            icon: "heart.fill",
                            content: {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(favoriteRecipes) { recipe in
                                            NavigationLink {
                                                RecipeDetailView(recipe: recipe, profileManager: profileManager, dataManager: dataManager)
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
                                    value: profileManager.userProfile?.cookingLevel.rawValue ?? CookingLevel.beginner.rawValue,
                                    icon: "chef.hat"
                                )
                                
                                if let preferences = profileManager.userProfile?.dietaryPreferences, !preferences.isEmpty {
                                    PreferenceRow(
                                        title: "Préférences alimentaires",
                                        value: preferences.joined(separator: ", "),
                                        icon: "leaf"
                                    )
                                }
                                
                                if let allergies = profileManager.userProfile?.allergies, !allergies.isEmpty {
                                    PreferenceRow(
                                        title: "Allergies",
                                        value: allergies.joined(separator: ", "),
                                        icon: "exclamationmark.triangle"
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    )
                    
                    // Actions du profil
                    VStack(spacing: 12) {
                        NavigationLink {
                            ProfileEditView(profileManager: profileManager)
                        } label: {
                            HStack {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(.primary)
                                
                                Text("Modifier les préférences")
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
                        .buttonStyle(PlainButtonStyle())
                        
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
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        ProfileActionButton(
                            title: "Déconnexion",
                            icon: "arrow.right.square.fill",
                            action: {
                                isAuthenticated = false
                            },
                            destructive: true
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
    @State private var isAppearing = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Avatar avec effet de profondeur et gradient
            ZStack {
                // Cercle de fond animé
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
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.4), radius: 20, x: 0, y: 10)
                    .scaleEffect(isAppearing ? 1.0 : 0.8)
                
                // Icône profil
                Image(systemName: profile.profileImageName)
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(.white)
                    .scaleEffect(isAppearing ? 1.0 : 0.5)
            }
            
            // Informations utilisateur
            VStack(spacing: 6) {
                Text(profile.name)
                    .font(.title.weight(.bold))
                    .foregroundStyle(.primary)
                    .opacity(isAppearing ? 1 : 0)
                    .offset(y: isAppearing ? 0 : 10)
                
                HStack(spacing: 4) {
                    Image(systemName: "envelope.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(profile.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .opacity(isAppearing ? 1 : 0)
                .offset(y: isAppearing ? 0 : 10)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                isAppearing = true
            }
        }
    }
}

struct ProfileStatsView: View {
    let favoriteCount: Int
    let folderCount: Int
    let memberSince: Date
    @State private var isAppearing = false
    
    private var memberSinceText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: memberSince)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Favoris",
                value: "\(favoriteCount)",
                icon: "heart.fill",
                gradient: [Color(red: 0.9, green: 0.3, blue: 0.3), Color(red: 1.0, green: 0.4, blue: 0.4)],
                isAppearing: isAppearing
            )
            
            StatCard(
                title: "Dossiers",
                value: "\(folderCount)",
                icon: "folder.fill",
                gradient: [Color(red: 0.9, green: 0.6, blue: 0.2), Color(red: 1.0, green: 0.7, blue: 0.3)],
                isAppearing: isAppearing
            )
            
            StatCard(
                title: "Depuis",
                value: memberSinceText.prefix(10).description,
                icon: "calendar",
                gradient: [Color(red: 0.3, green: 0.7, blue: 0.4), Color(red: 0.4, green: 0.8, blue: 0.5)],
                isAppearing: isAppearing
            )
        }
        .padding(.horizontal, 24)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                isAppearing = true
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    let isAppearing: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Icône avec gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: gradient[0].opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .scaleEffect(isAppearing ? 1.0 : 0.5)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .opacity(isAppearing ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
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
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.3, green: 0.7, blue: 0.4),
                                Color(red: 0.2, green: 0.6, blue: 0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(title)
                    .font(.title3.weight(.bold))
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
    @State private var isAppearing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                // Fond avec gradient
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
                    .frame(width: 180, height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.4, green: 0.7, blue: 0.4).opacity(0.3),
                                        Color(red: 0.3, green: 0.6, blue: 0.5).opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                
                // Icône
                VStack {
                    Spacer()
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
                        .scaleEffect(isAppearing ? 1.0 : 0.8)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                // Badge Eco-Score
                EcoScoreBadge(ecoScore: recipe.ecoScore, size: .small)
                    .padding(8)
                    .scaleEffect(isAppearing ? 1.0 : 0.5)
            }
            .frame(width: 180, height: 120)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(recipe.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(recipe.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
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
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                isAppearing = true
            }
        }
    }
}

struct ProfileFolderRow: View {
    let folder: RecipeFolder
    @State private var isPressed = false
    
    // Couleurs écologiques
    private var gradientColors: [Color] {
        let colors: [[Color]] = [
            [Color(red: 0.4, green: 0.7, blue: 0.4), Color(red: 0.3, green: 0.8, blue: 0.5)],
            [Color(red: 0.2, green: 0.6, blue: 0.8), Color(red: 0.3, green: 0.7, blue: 0.9)],
            [Color(red: 0.5, green: 0.7, blue: 0.3), Color(red: 0.6, green: 0.8, blue: 0.4)],
            [Color(red: 0.9, green: 0.6, blue: 0.2), Color(red: 1.0, green: 0.7, blue: 0.3)],
            [Color(red: 0.8, green: 0.3, blue: 0.3), Color(red: 0.9, green: 0.4, blue: 0.4)],
            [Color(red: 0.5, green: 0.4, blue: 0.7), Color(red: 0.6, green: 0.5, blue: 0.8)]
        ]
        let index = abs(folder.id.hashValue) % colors.count
        return colors[index]
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Icône avec gradient
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: gradientColors[0].opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: folder.imageName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(folder.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text("\(folder.recipes.count) recette\(folder.recipes.count > 1 ? "s" : "")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.tertiary)
                .scaleEffect(isPressed ? 1.2 : 1.0)
                .offset(x: isPressed ? 3 : 0)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
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
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 24)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
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
    var destructive: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(destructive ? .red : .primary)
                
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(destructive ? .red : .primary)
                
                Spacer()
                
                if !destructive {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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
    let schema = Schema([Recipe.self, RecipeFolder.self, UserProfile.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = ModelContext(container)
    let manager = SwiftDataManager(modelContext: context)
    let upm = UserProfileManager()
    upm.configure(with: manager)
    return NavigationStack {
        ProfileView(profileManager: upm, dataManager: manager, isAuthenticated: .constant(true))
    }
}
