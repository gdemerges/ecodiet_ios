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

                    if !dataManager.folders.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Mes dossiers")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.secondary)
                            
                            // Grille de dossiers compacts style Spotify
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

                    HStack {
                        Text("Testez vos connaissances")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.secondary)
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

struct QuizCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.green.opacity(0.6), .mint.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 160)
                
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 70, height: 70)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .opacity(isAnimating ? 0.3 : 0.5)
                        
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(.white)
                            .rotationEffect(.degrees(isAnimating ? 5 : -5))
                    }
                    
                    Text("Quiz Écologique")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Alimentation durable")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("5 questions sur l'écologie alimentaire")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.green.opacity(0.3), .mint.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Color.green.opacity(0.15), radius: 16, x: 0, y: 8)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct SportsQuizCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.6), .red.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 160)
                
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 70, height: 70)
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .opacity(isAnimating ? 0.3 : 0.5)
                        
                        Image(systemName: "figure.run")
                            .font(.system(size: 36, weight: .semibold))
                            .foregroundStyle(.white)
                            .offset(x: isAnimating ? 3 : -3)
                    }
                    
                    Text("Quiz Sportif")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Nutrition sportive")
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("5 questions sur l'alimentation des sportifs")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.orange.opacity(0.3), .red.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .shadow(color: Color.orange.opacity(0.15), radius: 16, x: 0, y: 8)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// Nouveau bouton compact de dossier style Spotify
struct CompactFolderButton: View {
    let folder: RecipeFolder
    @State private var isPressed = false
    
    // Couleurs aléatoires mais cohérentes pour chaque dossier
    private var gradientColors: [Color] {
        let colors: [[Color]] = [
            [.purple, .pink],
            [.blue, .cyan],
            [.green, .mint],
            [.orange, .yellow],
            [.red, .pink],
            [.indigo, .purple]
        ]
        // Utiliser l'ID du dossier pour avoir une couleur cohérente
        let index = abs(folder.id.hashValue) % colors.count
        return colors[index]
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icône à gauche
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: folder.imageName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            // Texte à droite
            VStack(alignment: .leading, spacing: 2) {
                Text(folder.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text("\(folder.recipes.count) recette\(folder.recipes.count > 1 ? "s" : "")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 0)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
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
        HomeView(dataManager: manager, profileManager: upm)
    }
}
