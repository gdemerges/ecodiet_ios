import SwiftUI

struct FolderDetailView: View {
    let folder: RecipeFolder
    let dataManager: RecipeDataManager
    @State private var showingAddRecipe = false
    
    // Computed property to get the current folder state
    private var currentFolder: RecipeFolder? {
        dataManager.folder(with: folder.id)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if let currentFolder = currentFolder, !currentFolder.recipes.isEmpty {
                    List {
                        ForEach(currentFolder.recipes) { recipe in
                            RecipeRowView(recipe: recipe)
                        }
                        .onDelete { offsets in
                            dataManager.removeRecipe(from: folder.id, at: offsets)
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "Aucune recette",
                        systemImage: folder.imageName,
                        description: Text("Ajoutez des recettes à ce dossier pour les organiser")
                    )
                }
            }
            .navigationTitle(folder.title)
            .navigationBarTitleDisplayMode(.large)
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
}

struct RecipeRowView: View {
    let recipe: Recipe
    
    var body: some View {
        HStack {
            Image(systemName: recipe.imageName)
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.title)
                    .font(.headline)
                Text(recipe.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct AddRecipeToFolderView: View {
    let folder: RecipeFolder
    let dataManager: RecipeDataManager
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
        
        dataManager.addRecipe(to: folder.id, recipe: newRecipe)
        dismiss()
    }
}

#Preview {
    let dataManager = RecipeDataManager()
    let sampleFolder = RecipeFolder(
        title: "Recettes sport",
        recipes: [
            Recipe(title: "Smoothie protéiné", subtitle: "Banane et whey", imageName: "cup.and.saucer"),
            Recipe(title: "Bowl énergétique", subtitle: "Avoine et fruits", imageName: "leaf")
        ],
        imageName: "figure.run"
    )
    
    return FolderDetailView(folder: sampleFolder, dataManager: dataManager)
}