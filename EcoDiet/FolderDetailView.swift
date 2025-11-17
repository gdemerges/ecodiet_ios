import SwiftUI
import SwiftData

struct FolderDetailView: View {
    let folder: RecipeFolder
    let dataManager: SwiftDataManager
    let profileManager: UserProfileManager
    @State private var showingAddRecipe = false
    
    // Computed property to get the current folder state
    private var currentFolder: RecipeFolder? {
        dataManager.folder(with: folder.id)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header avec logo
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(folder.color.gradient)
                            .frame(width: 70, height: 70)
                            .shadow(color: folder.color.opacity(0.3), radius: 12, x: 0, y: 6)
                        
                        Image(systemName: folder.imageName)
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(folder.title)
                            .font(.title.weight(.bold))
                        
                        if let currentFolder = currentFolder {
                            Text("\(currentFolder.recipes.count) recette\(currentFolder.recipes.count > 1 ? "s" : "")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Liste des recettes
                if let currentFolder = currentFolder, !currentFolder.recipes.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(currentFolder.recipes) { recipe in
                            NavigationLink {
                                RecipeDetailView(recipe: recipe, profileManager: profileManager, dataManager: dataManager)
                            } label: {
                                EnhancedRecipeRowView(recipe: recipe, folderColor: folder.color)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contextMenu {
                                Button(role: .destructive) {
                                    dataManager.removeRecipe(recipe, from: currentFolder)
                                } label: {
                                    Label("Retirer du dossier", systemImage: "folder.badge.minus")
                                }
                            }
                        }
                        
                        // Bouton pour ajouter une recette
                        Button {
                            showingAddRecipe = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 20))
                                Text("Ajouter une recette")
                                    .font(.headline)
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(folder.color.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .shadow(color: folder.color.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                } else {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(folder.color.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: folder.imageName)
                                .font(.system(size: 40, weight: .medium))
                                .foregroundStyle(folder.color)
                        }
                        
                        Text("Aucune recette")
                            .font(.title3.weight(.semibold))
                        
                        Text("Ajoutez des recettes à ce dossier pour les organiser")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button {
                            showingAddRecipe = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                Text("Ajouter une recette")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(folder.color.gradient)
                            .clipShape(Capsule())
                            .shadow(color: folder.color.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                }
            }
            .padding(.bottom, 20)
        }
        .background(AuthBackground().ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddRecipe) {
            AddRecipeToFolderView(folder: folder, dataManager: dataManager)
        }
    }
}

struct EnhancedRecipeRowView: View {
    let recipe: Recipe
    let folderColor: Color
    
    var body: some View {
        HStack(spacing: 14) {
            // Image/icône de la recette
            ZStack {
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
                    .frame(width: 60, height: 60)
                
                Image(systemName: recipe.imageName)
                    .font(.system(size: 24, weight: .medium))
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
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(recipe.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Badge temps
            HStack(spacing: 4) {
                Image(systemName: "clock.fill")
                    .font(.caption2)
                Text("\(recipe.preparationTime) min")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

struct AddRecipeToFolderView: View {
    let folder: RecipeFolder
    let dataManager: SwiftDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedRecipes: Set<Recipe.ID> = []
    
    // Récupérer le dossier actuel avec ses recettes
    private var currentFolder: RecipeFolder? {
        dataManager.folder(with: folder.id)
    }
    
    // IDs des recettes déjà dans le dossier
    private var existingRecipeIDs: Set<Recipe.ID> {
        Set(currentFolder?.recipes.map { $0.id } ?? [])
    }
    
    // Filtrer les recettes par recherche et exclure celles déjà dans le dossier
    private var filteredRecipes: [Recipe] {
        let allRecipes = dataManager.recipes
        let availableRecipes = allRecipes.filter { !existingRecipeIDs.contains($0.id) }
        
        if searchText.isEmpty {
            return availableRecipes
        } else {
            return availableRecipes.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(searchText) ||
                recipe.subtitle.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AuthBackground().ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Barre de recherche
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.secondary)
                            
                            TextField("Rechercher une recette...", text: $searchText)
                                .textFieldStyle(.plain)
                                .font(.body)
                            
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        
                        // Compteur de sélection
                        if !selectedRecipes.isEmpty {
                            HStack {
                                Text("\(selectedRecipes.count) recette\(selectedRecipes.count > 1 ? "s" : "") sélectionnée\(selectedRecipes.count > 1 ? "s" : "")")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                Button {
                                    selectedRecipes.removeAll()
                                } label: {
                                    Text("Tout désélectionner")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(folder.color)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    
                    // Liste des recettes
                    if filteredRecipes.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: searchText.isEmpty ? "fork.knife.circle" : "magnifyingglass")
                                .font(.system(size: 60))
                                .foregroundStyle(.secondary)
                            
                            Text(searchText.isEmpty ? "Toutes les recettes sont déjà dans ce dossier" : "Aucune recette trouvée")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            if !searchText.isEmpty {
                                Text("Essayez avec d'autres mots-clés")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(40)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredRecipes) { recipe in
                                    RecipeSelectionRow(
                                        recipe: recipe,
                                        isSelected: selectedRecipes.contains(recipe.id),
                                        folderColor: folder.color
                                    )
                                    .onTapGesture {
                                        toggleSelection(for: recipe)
                                    }
                                }
                            }
                            .padding(20)
                        }
                    }
                }
            }
            .navigationTitle("Ajouter des recettes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter (\(selectedRecipes.count))") {
                        addSelectedRecipes()
                    }
                    .disabled(selectedRecipes.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func toggleSelection(for recipe: Recipe) {
        if selectedRecipes.contains(recipe.id) {
            selectedRecipes.remove(recipe.id)
        } else {
            selectedRecipes.insert(recipe.id)
        }
    }
    
    private func addSelectedRecipes() {
        guard let currentFolder = dataManager.folder(with: folder.id) else { return }
        
        let recipesToAdd = dataManager.recipes.filter { selectedRecipes.contains($0.id) }
        
        for recipe in recipesToAdd {
            dataManager.addRecipe(recipe, to: currentFolder)
        }
        
        dismiss()
    }
}

// MARK: - Recipe Selection Row
struct RecipeSelectionRow: View {
    let recipe: Recipe
    let isSelected: Bool
    let folderColor: Color
    @State private var isPressed = false
    
    // Break down complex computed properties
    private var checkboxStrokeColor: Color {
        isSelected ? folderColor : Color.gray.opacity(0.3)
    }
    
    private var backgroundFill: AnyShapeStyle {
        isSelected ? AnyShapeStyle(folderColor.opacity(0.1)) : AnyShapeStyle(.ultraThinMaterial)
    }
    
    private var overlayStrokeColor: Color {
        isSelected ? folderColor.opacity(0.4) : Color.white.opacity(0.3)
    }
    
    private var overlayLineWidth: CGFloat {
        isSelected ? 2 : 1
    }
    
    private var shadowColor: Color {
        isSelected ? folderColor.opacity(0.2) : Color.black.opacity(0.04)
    }
    
    private var recipeImageGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.97, blue: 0.95),
                Color(red: 0.92, green: 0.95, blue: 0.92)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var recipeIconGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.3, green: 0.6, blue: 0.4),
                Color(red: 0.2, green: 0.5, blue: 0.5)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        HStack(spacing: 14) {
            // Checkbox
            checkboxView
            
            // Image/icône de la recette
            recipeImageView
            
            // Recipe info
            recipeInfoView
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(backgroundFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(overlayStrokeColor, lineWidth: overlayLineWidth)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .shadow(color: shadowColor, radius: 8, x: 0, y: 4)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var checkboxView: some View {
        ZStack {
            Circle()
                .stroke(checkboxStrokeColor, lineWidth: 2)
                .frame(width: 24, height: 24)
            
            if isSelected {
                Circle()
                    .fill(folderColor)
                    .frame(width: 24, height: 24)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private var recipeImageView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(recipeImageGradient)
                .frame(width: 60, height: 60)
            
            Image(systemName: recipe.imageName)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(recipeIconGradient)
        }
    }
    
    private var recipeInfoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(recipe.title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            HStack(spacing: 8) {
                Text(recipe.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                // Badge temps
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                    Text("\(recipe.preparationTime)'")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    let schema = Schema([Recipe.self, RecipeFolder.self, UserProfile.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = ModelContext(container)
    let manager = SwiftDataManager(modelContext: context)
    let profileManager = UserProfileManager()
    profileManager.configure(with: manager)
    let sampleFolder = RecipeFolder(title: "Recettes sport", imageName: "figure.run", colorHex: "#EF4444")
    manager.addFolder(sampleFolder)
    let recipe1 = Recipe(title: "Smoothie protéiné", subtitle: "Banane et whey", imageName: "cup.and.saucer")
    let recipe2 = Recipe(title: "Bowl énergétique", subtitle: "Avoine et fruits", imageName: "leaf")
    manager.addRecipe(recipe1)
    manager.addRecipe(recipe2)
    if let current = manager.folder(with: sampleFolder.id) {
        manager.addRecipe(recipe1, to: current)
        manager.addRecipe(recipe2, to: current)
    }
    return NavigationStack {
        FolderDetailView(folder: sampleFolder, dataManager: manager, profileManager: profileManager)
    }
}
