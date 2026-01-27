import SwiftUI
import SwiftData

struct HomeView: View {
    let dataManager: SwiftDataManager
    let profileManager: UserProfileManager
    let fridgeManager: FridgeManager
    @Binding var isAuthenticated: Bool
    @State private var headerAppeared = false
    @Environment(\.colorScheme) private var colorScheme

    private var greeting: String {
        HomeView.buildGreeting(for: profileManager.userProfile)
    }

    var body: some View {
        ZStack {
            ThemeColors.background(for: colorScheme).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HomeHeaderView(
                        greeting: greeting,
                        profileManager: profileManager,
                        dataManager: dataManager,
                        isAuthenticated: $isAuthenticated,
                        headerAppeared: headerAppeared
                    )

                    // Section "Juste pour vous"
                    recommendationsSection

                    // Section "Nos recettes"
                    recipesSection

                    // Section Quiz
                    QuizSection()
                }
                .padding(24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                headerAppeared = true
            }
        }
    }

    // MARK: - Sections

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HomeSectionHeader(
                icon: "sparkles",
                title: "Juste pour vous",
                iconColors: [.ecoDietOrange, .ecoDietOrange.opacity(0.8)],
                trailingContent: AnyView(
                    NavigationLink {
                        RecommendationView(dataManager: dataManager, profileManager: profileManager)
                    } label: {
                        Text("Voir tout")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                )
            )

            RecipeCarousel(
                recipes: dataManager.recipes,
                profileManager: profileManager,
                dataManager: dataManager
            )
        }
    }

    private var recipesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HomeSectionHeader(
                    icon: "book.fill",
                    title: "Nos recettes",
                    iconColors: [.ecoDietGreen, .ecoDietSecondaryGreen]
                )

                Spacer()

                NavigationLink {
                    ListView(profileManager: profileManager, dataManager: dataManager)
                } label: {
                    Text("Voir tout")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                }
            }

            RecipeCarousel(
                recipes: dataManager.recipes,
                profileManager: profileManager,
                dataManager: dataManager
            )
        }
    }
}

struct FolderCard: View {
    let folder: RecipeFolder
    let dataManager: SwiftDataManager
    let profileManager: UserProfileManager
    
    var body: some View {
        NavigationLink {
            FolderDetailView(folder: folder, dataManager: dataManager, profileManager: profileManager)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 240, height: 140)
                    VStack {
                        ZStack {
                            Circle()
                                .fill(folder.color.gradient)
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: folder.imageName)
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(.white)
                        }
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
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                // Image de la recette
                if recipe.imageName.starts(with: "http://") || recipe.imageName.starts(with: "https://") {
                    // Image depuis URL (PostgreSQL)
                    CachedAsyncImage(url: URL(string: recipe.imageName)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.primary.opacity(0.05))
                    }
                    .frame(width: 240, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                } else {
                    // Fond neutre pour SF Symbol
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.primary.opacity(0.05))
                        .frame(width: 240, height: 160)
                        .overlay {
                            Image(systemName: recipe.imageName)
                                .font(.system(size: 40, weight: .light))
                                .foregroundStyle(.primary.opacity(0.3))
                        }
                }
                
                // Badge temps en haut à droite
                VStack {
                    HStack {
                        Spacer()
                        HStack(spacing: 3) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 9, weight: .bold))
                            
                            Text("\(recipe.preparationTime)'")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(.black.opacity(0.5))
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        )
                    }
                    Spacer()
                }
                .padding(12)
                .frame(width: 240, height: 160)
                
                // Badge Eco-Score en haut à gauche
                VStack {
                    HStack {
                        EcoScoreBadge(ecoScore: recipe.ecoScore, size: .small)
                            .scaleEffect(0.85)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(12)
                .frame(width: 240, height: 160)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                // Titre de la recette
                Text(recipe.title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Text(recipe.ecoScore.emoji)
                        .font(.caption)
                    
                    Text(recipe.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                
                Text("\(recipe.requiredIngredients.count) ingrédients")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 6)
        }
        .frame(width: 240)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}

struct QuizCard: View {
    @State private var isAnimating = false
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                // Fond avec gradient organique
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                .ecoDietGreen,
                                .ecoDietSecondaryGreen
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 170)
                
                // Effet de texture organique
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.clear
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(height: 170)
                
                // Cercles décoratifs flottants
                GeometryReader { geometry in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 60, height: 60)
                        .offset(x: -20, y: pulseAnimation ? -10 : 0)
                        .blur(radius: 2)
                    
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 80, height: 80)
                        .offset(x: geometry.size.width - 40, y: geometry.size.height - 40)
                        .offset(y: pulseAnimation ? 10 : 0)
                        .blur(radius: 3)
                }
                .frame(height: 170)
                
                VStack(spacing: 14) {
                    ZStack {
                        // Cercle de fond avec pulse
                        Circle()
                            .fill(.white.opacity(0.25))
                            .frame(width: 80, height: 80)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                            .opacity(pulseAnimation ? 0.5 : 0.8)
                        
                        Circle()
                            .fill(.white.opacity(0.3))
                            .frame(width: 70, height: 70)
                        
                        // Icône avec rotation
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 38, weight: .semibold))
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                            .rotationEffect(.degrees(isAnimating ? 5 : -5))
                    }
                    
                    Text("Quiz Écologique")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "leaf.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.ecoDietGreen)
                    
                    Text("Alimentation durable")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                
                Text("5 questions sur l'écologie alimentaire")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 6)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.ecoDietGreen.opacity(0.4),
                            Color.ecoDietSecondaryGreen.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Color.ecoDietGreen.opacity(0.2), radius: 20, x: 0, y: 10)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}

struct SportsQuizCard: View {
    @State private var isAnimating = false
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ZStack {
                // Fond avec gradient énergique
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                .ecoDietOrange,
                                .ecoDietOrange.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 170)
                
                // Effet de texture organique
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.15),
                                Color.clear
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(height: 170)
                
                // Cercles décoratifs flottants
                GeometryReader { geometry in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 70, height: 70)
                        .offset(x: -30, y: pulseAnimation ? -10 : 0)
                        .blur(radius: 2)
                    
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 90, height: 90)
                        .offset(x: geometry.size.width - 50, y: geometry.size.height - 50)
                        .offset(y: pulseAnimation ? 10 : 0)
                        .blur(radius: 3)
                }
                .frame(height: 170)
                
                VStack(spacing: 14) {
                    ZStack {
                        // Cercle de fond avec pulse
                        Circle()
                            .fill(.white.opacity(0.25))
                            .frame(width: 80, height: 80)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                            .opacity(pulseAnimation ? 0.5 : 0.8)
                        
                        Circle()
                            .fill(.white.opacity(0.3))
                            .frame(width: 70, height: 70)
                        
                        // Icône avec mouvement
                        Image(systemName: "figure.run")
                            .font(.system(size: 38, weight: .semibold))
                            .foregroundStyle(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
                            .offset(x: isAnimating ? 3 : -3)
                    }
                    
                    Text("Quiz Sportif")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.ecoDietOrange)
                    
                    Text("Nutrition sportive")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                
                Text("5 questions sur l'alimentation des sportifs")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 6)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.ecoDietOrange.opacity(0.4),
                            Color.ecoDietOrange.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Color.ecoDietOrange.opacity(0.2), radius: 20, x: 0, y: 10)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}

#Preview {
    @MainActor in
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema([
            Recipe.self,
            RecipeFolder.self,
            UserProfile.self,
            Ingredient.self
        ])
        let container = try ModelContainer(for: schema, configurations: config)
        let context = ModelContext(container)
        let manager = SwiftDataManager(modelContext: context)
        let fridgeManager = FridgeManager(modelContext: context)
        let upm = UserProfileManager()
        upm.configure(with: manager)
        return NavigationStack {
            HomeView(dataManager: manager, profileManager: upm, fridgeManager: fridgeManager, isAuthenticated: .constant(true))
        }
    } catch {
        return Text("Erreur de chargement: \(error.localizedDescription)")
    }
}
