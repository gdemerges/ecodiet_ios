import SwiftUI
import SwiftData

struct FolderDetailView: View {
    let folder: RecipeFolder
    let dataManager: SwiftDataManager
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
                            EnhancedRecipeRowView(recipe: recipe, folderColor: folder.color)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        dataManager.removeRecipe(recipe, from: currentFolder)
                                    } label: {
                                        Label("Retirer du dossier", systemImage: "folder.badge.minus")
                                    }
                                }
                        }
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddRecipe = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
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
    @State private var newRecipeTitle = ""
    @State private var newRecipeSubtitle = ""
    @State private var selectedIcon = "fork.knife"
    
    private let availableIcons = [
        "fork.knife", "leaf", "cup.and.saucer", "takeoutbag.and.cup.and.straw",
        "carrot", "fish", "birthday.cake", "mug", "wineglass", "drop"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informations de la recette") {
                    TextField("Titre de la recette", text: $newRecipeTitle)
                    TextField("Description", text: $newRecipeSubtitle)
                    
                    Picker("Icône", selection: $selectedIcon) {
                        ForEach(availableIcons, id: \.self) { icon in
                            HStack {
                                Image(systemName: icon)
                                Text(icon)
                            }
                            .tag(icon)
                        }
                    }
                }
            }
            .navigationTitle("Nouvelle recette")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        addRecipe()
                    }
                    .disabled(newRecipeTitle.isEmpty)
                }
            }
        }
    }
    
    private func addRecipe() {
        let newRecipe = Recipe(
            title: newRecipeTitle,
            subtitle: newRecipeSubtitle,
            imageName: selectedIcon
        )
        
        dataManager.addRecipe(newRecipe)
        if let current = dataManager.folder(with: folder.id) {
            dataManager.addRecipe(newRecipe, to: current)
        }
        dismiss()
    }
}

#Preview {
    let schema = Schema([Recipe.self, RecipeFolder.self, UserProfile.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = ModelContext(container)
    let manager = SwiftDataManager(modelContext: context)
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
        FolderDetailView(folder: sampleFolder, dataManager: manager)
    }
}
