import SwiftUI
import SwiftData

struct HomeView: View {
    let dataManager: SwiftDataManager
    let profileManager: UserProfileManager
    @Binding var isAuthenticated: Bool
    @State private var headerAppeared = false

    private var greeting: String {
        let firstName = profileManager.userProfile?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let hour = Calendar.current.component(.hour, from: Date())
        
        let timeGreeting: String
        switch hour {
        case 6..<18:
            timeGreeting = "Bonjour"
        case 18..<22:
            timeGreeting = "Bonsoir"
        default:
            timeGreeting = "Bonsoir"
        }
        
        return firstName.isEmpty ? "\(timeGreeting) !" : "\(timeGreeting) \(firstName) !"
    }

    var body: some View {
        ZStack {
            AuthBackground().ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header amélioré avec animation
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(greeting)
                                .font(.largeTitle).bold()
                                .opacity(headerAppeared ? 1 : 0)
                                .offset(x: headerAppeared ? 0 : -20)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "leaf.fill")
                                    .font(.caption2)
                                    .foregroundStyle(Color(red: 0.3, green: 0.7, blue: 0.4))
                                
                                Text("Mangez sainement, naturellement")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .opacity(headerAppeared ? 1 : 0)
                            .offset(x: headerAppeared ? 0 : -20)
                        }
                        
                        Spacer()
                        
                        NavigationLink {
                            ProfileView(
                                profileManager: profileManager,
                                dataManager: dataManager,
                                isAuthenticated: $isAuthenticated
                            )
                        } label: {
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
                                    .frame(width: 44, height: 44)
                                    .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                            .scaleEffect(headerAppeared ? 1 : 0.5)
                            .opacity(headerAppeared ? 1 : 0)
                        }
                        .accessibilityLabel("Profil")
                    }
                    .padding(.top, 8)

                    if !dataManager.folders.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Mes dossiers")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.primary)
                            
                            // Grille de dossiers minimaliste
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(dataManager.folders) { folder in
                                    NavigationLink {
                                        FolderDetailView(folder: folder, dataManager: dataManager)
                                    } label: {
                                        CompactFolderButton(folder: folder)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }

                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.title3)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.9, green: 0.6, blue: 0.2),
                                            Color(red: 1.0, green: 0.7, blue: 0.3)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Juste pour vous")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.primary)
                        }
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
                                    RecipeDetailView(recipe: recipe, profileManager: profileManager, dataManager: dataManager)
                                } label: {
                                    RecipeCard(recipe: recipe)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 2)
                    }

                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "book.fill")
                                .font(.title3)
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
                            
                            Text("Nos recettes")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.primary)
                        }
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
                        .accessibilityLabel("Voir toutes les recettes")
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(dataManager.recipes) { recipe in
                                NavigationLink {
                                    RecipeDetailView(recipe: recipe, profileManager: profileManager, dataManager: dataManager)
                                } label: {
                                    RecipeCard(recipe: recipe)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 2)
                    }

                    HStack {
                        HStack(spacing: 8) {
                            Image(systemName: "brain.head.profile")
                                .font(.title3)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.5, green: 0.4, blue: 0.7),
                                            Color(red: 0.6, green: 0.5, blue: 0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Testez vos connaissances")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.primary)
                        }
                        Spacer()
                    }

                    VStack(spacing: 16) {
                        NavigationLink {
                            EcoQuizView()
                        } label: {
                            QuizCard()
                        }
                        .buttonStyle(PlainButtonStyle())

                        NavigationLink {
                            SportsQuizView()
                        } label: {
                            SportsQuizCard()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
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
    @State private var isAppearing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                // Fond avec gradient doux
                RoundedRectangle(cornerRadius: 20, style: .continuous)
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
                    .frame(width: 240, height: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
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
                
                // Icône avec effet de profondeur
                VStack {
                    Spacer()
                    Image(systemName: recipe.imageName)
                        .font(.system(size: 42, weight: .medium))
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
                        .shadow(color: Color(red: 0.3, green: 0.6, blue: 0.4).opacity(0.3), radius: 8, x: 0, y: 4)
                        .scaleEffect(isAppearing ? 1.0 : 0.8)
                        .rotationEffect(.degrees(isAppearing ? 0 : -10))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                // Badge temps de préparation (bas à droite)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.white)
                            
                            Text("\(recipe.preparationTime) min")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(.black.opacity(0.6))
                        )
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .padding(8)
                    }
                }
                
                // Badge Eco-Score amélioré avec ombre
                EcoScoreBadge(ecoScore: recipe.ecoScore, size: .small)
                    .padding(10)
                    .scaleEffect(isAppearing ? 1.0 : 0.5)
                    .opacity(isAppearing ? 1.0 : 0.0)
            }
            .frame(width: 240, height: 140)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack {
                    Text(recipe.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Emoji avec animation subtile
                    Text(recipe.ecoScore.emoji)
                        .font(.caption)
                        .scaleEffect(isAppearing ? 1.0 : 0)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
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
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                isAppearing = true
            }
        }
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
                                Color(red: 0.3, green: 0.7, blue: 0.4),
                                Color(red: 0.2, green: 0.6, blue: 0.5)
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
                        .foregroundStyle(Color(red: 0.3, green: 0.7, blue: 0.4))
                    
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
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.4),
                            Color(red: 0.2, green: 0.6, blue: 0.5).opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.2), radius: 20, x: 0, y: 10)
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
                                Color(red: 0.95, green: 0.5, blue: 0.2),
                                Color(red: 0.9, green: 0.3, blue: 0.3)
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
                        .foregroundStyle(Color(red: 0.95, green: 0.5, blue: 0.2))
                    
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
                            Color(red: 0.95, green: 0.5, blue: 0.2).opacity(0.4),
                            Color(red: 0.9, green: 0.3, blue: 0.3).opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Color(red: 0.95, green: 0.5, blue: 0.2).opacity(0.2), radius: 20, x: 0, y: 10)
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

// Bouton compact de dossier avec design minimaliste
struct CompactFolderButton: View {
    let folder: RecipeFolder
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Icône simple à gauche
            Image(systemName: folder.imageName)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.primary.opacity(0.05))
                )
            
            // Texte à gauche
            VStack(alignment: .leading, spacing: 2) {
                Text(folder.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text("\(folder.recipes.count) recette\(folder.recipes.count > 1 ? "s" : "")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 0)
            
            // Chevron discret
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.tertiary)
                .offset(x: isPressed ? 2 : 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(0.03))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
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
        HomeView(dataManager: manager, profileManager: upm, isAuthenticated: .constant(true))
    }
}
