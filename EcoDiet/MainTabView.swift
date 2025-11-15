import SwiftUI
import SwiftData

struct MainTabView: View {
    let dataManager: SwiftDataManager
    let profileManager: UserProfileManager
    let fridgeManager: FridgeManager
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        TabView {
            // Onglet Accueil
            NavigationStack {
                HomeView(
                    dataManager: dataManager,
                    profileManager: profileManager,
                    fridgeManager: fridgeManager,
                    isAuthenticated: $isAuthenticated
                )
            }
            .tabItem {
                Label("Accueil", systemImage: "house.fill")
            }
            
            // Onglet Dossiers
            NavigationStack {
                FoldersTabView(dataManager: dataManager)
            }
            .tabItem {
                Label("Dossiers", systemImage: "folder.fill")
            }
            
            // Onglet Frigo
            NavigationStack {
                FridgeTabView(
                    fridgeManager: fridgeManager,
                    dataManager: dataManager,
                    profileManager: profileManager
                )
            }
            .tabItem {
                Label("Frigo", systemImage: "refrigerator.fill")
            }
        }
        .tint(Color(red: 0.3, green: 0.7, blue: 0.4))
    }
}

// MARK: - Folders Tab View
struct FoldersTabView: View {
    let dataManager: SwiftDataManager
    @State private var showingCreateFolder = false
    
    var body: some View {
        ZStack {
            AuthBackground().ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Mes dossiers")
                                    .font(.largeTitle.weight(.bold))
                                    .foregroundStyle(.primary)
                                
                                Text("\(dataManager.folders.count) dossier\(dataManager.folders.count > 1 ? "s" : "")")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                showingCreateFolder = true
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
                                    
                                    Image(systemName: "plus")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                            }
                            .accessibilityLabel("Créer un dossier")
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    // Liste des dossiers
                    if dataManager.folders.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "folder.badge.plus")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            
                            Text("Aucun dossier")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.primary)
                            
                            Text("Créez des dossiers pour organiser vos recettes")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button {
                                showingCreateFolder = true
                            } label: {
                                Text("Créer mon premier dossier")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.3, green: 0.7, blue: 0.4),
                                                Color(red: 0.2, green: 0.6, blue: 0.5)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        in: RoundedRectangle(cornerRadius: 12)
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(dataManager.folders) { folder in
                                NavigationLink {
                                    FolderDetailView(folder: folder, dataManager: dataManager)
                                } label: {
                                    FolderRowCard(folder: folder)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCreateFolder) {
            // TODO: Create folder sheet
            Text("Créer un dossier")
        }
    }
}

// MARK: - Fridge Tab View
struct FridgeTabView: View {
    let fridgeManager: FridgeManager
    let dataManager: SwiftDataManager
    let profileManager: UserProfileManager
    @State private var showingAddIngredient = false
    
    var ingredientsCount: Int {
        fridgeManager.ingredientsInFridge().count
    }
    
    var availableRecipesCount: Int {
        dataManager.recipes.filter { recipe in
            fridgeManager.canMakeRecipe(recipe, allowMissing: 2)
        }.count
    }
    
    var body: some View {
        ZStack {
            AuthBackground().ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Mon frigo")
                                    .font(.largeTitle.weight(.bold))
                                    .foregroundStyle(.primary)
                                
                                Text("\(ingredientsCount) ingrédient\(ingredientsCount > 1 ? "s" : "")")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Button {
                                showingAddIngredient = true
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.4, green: 0.6, blue: 0.9),
                                                    Color(red: 0.3, green: 0.5, blue: 0.8)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 44, height: 44)
                                        .shadow(color: Color(red: 0.4, green: 0.6, blue: 0.9).opacity(0.3), radius: 8, x: 0, y: 4)
                                    
                                    Image(systemName: "plus")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(.white)
                                }
                            }
                            .accessibilityLabel("Ajouter un ingrédient")
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    
                    // Recettes possibles
                    if availableRecipesCount > 0 {
                        VStack(alignment: .leading, spacing: 16) {
                            NavigationLink {
                                FridgeRecommendationsView(
                                    dataManager: dataManager,
                                    fridgeManager: fridgeManager,
                                    profileManager: profileManager
                                )
                            } label: {
                                HStack(spacing: 16) {
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
                                        
                                        VStack(spacing: 2) {
                                            Image(systemName: "sparkles")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundStyle(.white)
                                            
                                            Text("\(availableRecipesCount)")
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Recettes possibles")
                                            .font(.headline.weight(.bold))
                                            .foregroundStyle(.primary)
                                        
                                        Text("Basé sur vos ingrédients")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
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
                                .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.2), radius: 12, x: 0, y: 6)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    // Liste des ingrédients
                    NavigationLink {
                        FridgeView(fridgeManager: fridgeManager)
                    } label: {
                        HStack {
                            Text("Tous mes ingrédients")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    if ingredientsCount == 0 {
                        VStack(spacing: 16) {
                            Image(systemName: "refrigerator")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            
                            Text("Frigo vide")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.primary)
                            
                            Text("Ajoutez les ingrédients que vous avez chez vous")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddIngredient) {
            AddIngredientView(fridgeManager: fridgeManager)
        }
    }
}

// MARK: - Folder Row Card
struct FolderRowCard: View {
    let folder: RecipeFolder
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icône avec gradient
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(folder.color.gradient)
                    .frame(width: 60, height: 60)
                    .shadow(color: folder.color.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: folder.imageName)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(folder.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text("\(folder.recipes.count) recette\(folder.recipes.count > 1 ? "s" : "")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.tertiary)
                .scaleEffect(isPressed ? 1.2 : 1.0)
                .offset(x: isPressed ? 3 : 0)
        }
        .padding(16)
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
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
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
        UserProfile.self,
        Ingredient.self
    ])
    let container: ModelContainer = try! ModelContainer(for: schema, configurations: config)
    let context: ModelContext = ModelContext(container)
    let manager = SwiftDataManager(modelContext: context)
    let fridgeManager = FridgeManager(modelContext: context)
    let upm = UserProfileManager()
    upm.configure(with: manager)
    return MainTabView(
        dataManager: manager,
        profileManager: upm,
        fridgeManager: fridgeManager,
        isAuthenticated: .constant(true)
    )
}
