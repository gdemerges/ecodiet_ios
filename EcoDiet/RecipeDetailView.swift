import SwiftUI
import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    let recipe: Recipe
    let profileManager: UserProfileManager
    let dataManager: SwiftDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingFolderPicker = false
    @State private var showingShareSheet = false
    
    var body: some View {
        ZStack {
            // Background avec le même style que HomeView
            AuthBackground().ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Image principale de la recette
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .frame(height: 280)
                            
                            Image(systemName: recipe.imageName)
                                .font(.system(size: 80, weight: .light))
                                .foregroundStyle(.primary)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Titre et sous-titre
                        VStack(alignment: .leading, spacing: 8) {
                            Text(recipe.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            
                            Text(recipe.subtitle)
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Informations pratiques
                        HStack(spacing: 32) {
                            InfoCard(
                                icon: "clock",
                                title: "Temps",
                                value: "\(recipe.preparationTime) min"
                            )
                            
                            InfoCard(
                                icon: "person.2",
                                title: "Portions",
                                value: "4 pers."
                            )
                            
                            InfoCard(
                                icon: "chart.bar",
                                title: "Difficulté",
                                value: "Facile"
                            )
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Eco-Score - Impact environnemental
                        EcoScoreDetailView(recipe: recipe)
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Ingrédients
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Ingrédients")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(sampleIngredients, id: \.self) { ingredient in
                                    HStack {
                                        Circle()
                                            .fill(.primary)
                                            .frame(width: 6, height: 6)
                                        
                                        Text(ingredient)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 8)
                                }
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        // Instructions
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Instructions")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(Array(sampleInstructions.enumerated()), id: \.offset) { index, instruction in
                                    HStack(alignment: .top, spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(.thinMaterial)
                                                .frame(width: 32, height: 32)
                                            
                                            Text("\(index + 1)")
                                                .font(.body)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.primary)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(instruction)
                                                .font(.body)
                                                .foregroundStyle(.primary)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                        
                        // Boutons d'action
                        VStack(spacing: 12) {
                            Button {
                                if profileManager.isFavorite(recipe) {
                                    profileManager.removeFavoriteRecipe(recipe)
                                } else {
                                    profileManager.addFavoriteRecipe(recipe)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: profileManager.isFavorite(recipe) ? "heart.fill" : "heart")
                                        .font(.system(size: 18, weight: .medium))
                                    
                                    Text(profileManager.isFavorite(recipe) ? "Retirer des favoris" : "Ajouter aux favoris")
                                        .font(.body)
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(profileManager.isFavorite(recipe) ? .red : .primary, in: RoundedRectangle(cornerRadius: 12))
                            }
                            
                            Button {
                                showingFolderPicker = true
                            } label: {
                                HStack {
                                    Image(systemName: "folder.badge.plus")
                                        .font(.system(size: 18, weight: .medium))
                                    
                                    Text("Ajouter à un dossier")
                                        .font(.body)
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.primary.opacity(0.2), lineWidth: 1)
                                )
                            }
                            
                            Button {
                                showingShareSheet = true
                            } label: {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 18, weight: .medium))
                                    
                                    Text("Partager cette recette")
                                        .font(.body)
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.primary.opacity(0.2), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingFolderPicker) {
            FolderPickerView(recipe: recipe, dataManager: dataManager)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [shareText])
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Action pour le menu
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                        .padding(8)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
        }
    }
    
    // Texte de partage pour la recette
    private var shareText: String {
        """
        🍽️ Découvrez cette recette : \(recipe.title)
        
        \(recipe.subtitle)
        
        ⏱️ Temps de préparation : \(recipe.preparationTime) minutes
        🌱 Eco-Score : \(recipe.ecoScore.rawValue) - \(recipe.ecoScore.description)
        🌍 Empreinte carbone : \(Int(recipe.carbonFootprint))g CO2eq
        
        Partagé depuis EcoDiet - L'app pour une alimentation saine et durable ! 🌿
        """
    }
    
    // Données d'exemple basées sur le type de recette
    private var sampleIngredients: [String] {
        switch recipe.title {
        case "Bowl veggie":
            return [
                "200g de quinoa",
                "150g de pois chiches",
                "1 avocat mûr",
                "100g d'épinards frais",
                "2 carottes",
                "Graines de tournesol",
                "Huile d'olive",
                "Citron"
            ]
        case "Salade césar":
            return [
                "1 laitue romaine",
                "200g de blanc de poulet",
                "50g de parmesan",
                "Croûtons",
                "2 œufs",
                "Anchois",
                "Huile d'olive",
                "Ail"
            ]
        case "Pâtes complètes":
            return [
                "300g de pâtes complètes",
                "400g de tomates fraîches",
                "Basilic frais",
                "3 gousses d'ail",
                "Huile d'olive",
                "Parmesan râpé",
                "Sel et poivre"
            ]
        case "Soupe de saison":
            return [
                "1kg de potiron",
                "200ml de lait de coco",
                "1 oignon",
                "2 gousses d'ail",
                "Gingembre frais",
                "Bouillon de légumes",
                "Épices (curcuma, curry)"
            ]
        default:
            return [
                "Ingrédient 1",
                "Ingrédient 2",
                "Ingrédient 3",
                "Ingrédient 4"
            ]
        }
    }
    
    private var sampleInstructions: [String] {
        switch recipe.title {
        case "Bowl veggie":
            return [
                "Rincer le quinoa et le cuire dans 400ml d'eau salée pendant 15 minutes.",
                "Faire revenir les pois chiches avec un peu d'huile d'olive et des épices.",
                "Laver et couper les légumes en julienne.",
                "Disposer tous les ingrédients dans un bol et arroser d'un mélange huile d'olive-citron."
            ]
        case "Salade césar":
            return [
                "Laver et couper la salade romaine en morceaux.",
                "Cuire le poulet à la poêle avec un peu d'huile, saler et poivrer.",
                "Préparer la sauce césar avec l'ail, les anchois, l'œuf et l'huile d'olive.",
                "Mélanger la salade avec la sauce, ajouter le poulet et parsemer de parmesan."
            ]
        case "Pâtes complètes":
            return [
                "Faire cuire les pâtes dans un grand volume d'eau salée selon les instructions.",
                "Faire revenir l'ail émincé dans l'huile d'olive.",
                "Ajouter les tomates coupées en dés et laisser mijoter 10 minutes.",
                "Mélanger les pâtes égouttées avec la sauce, ajouter le basilic et le parmesan."
            ]
        case "Soupe de saison":
            return [
                "Éplucher et couper le potiron en cubes.",
                "Faire revenir l'oignon et l'ail dans un peu d'huile.",
                "Ajouter le potiron, le gingembre et couvrir de bouillon.",
                "Laisser mijoter 20 minutes, mixer et ajouter le lait de coco."
            ]
        default:
            return [
                "Étape 1 de préparation",
                "Étape 2 de préparation",
                "Étape 3 de préparation"
            ]
        }
    }
}

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// Vue pour sélectionner un dossier ou en créer un nouveau
struct FolderPickerView: View {
    let recipe: Recipe
    let dataManager: SwiftDataManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingNewFolderSheet = false
    @State private var newFolderTitle = ""
    @State private var selectedIcon = "folder"
    
    private let availableIcons = [
        "folder", "folder.fill", "figure.run", "snowflake", "leaf.fill",
        "flame", "moon.stars", "sun.max", "heart.fill", "star.fill"
    ]
    
    var body: some View {
        NavigationStack {
            List {
                if !dataManager.folders.isEmpty {
                    Section("Dossiers existants") {
                        ForEach(dataManager.folders) { folder in
                            Button {
                                addToFolder(folder)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: folder.imageName)
                                        .font(.title3)
                                        .foregroundStyle(folderColor(for: folder))
                                        .frame(width: 32)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(folder.title)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                        
                                        Text("\(folder.recipes.count) recette\(folder.recipes.count > 1 ? "s" : "")")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if folder.recipes.contains(recipe) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.title3)
                                            .foregroundStyle(.green)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Section {
                    Button {
                        showingNewFolderSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.4, green: 0.7, blue: 0.4),
                                            Color(red: 0.3, green: 0.6, blue: 0.5)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Créer un nouveau dossier")
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Ajouter à un dossier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingNewFolderSheet) {
                NavigationStack {
                    Form {
                        Section("Informations du dossier") {
                            TextField("Nom du dossier", text: $newFolderTitle)
                            
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
                    .navigationTitle("Nouveau dossier")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Annuler") {
                                showingNewFolderSheet = false
                                resetForm()
                            }
                        }
                        
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Créer et ajouter") {
                                createFolderAndAdd()
                            }
                            .disabled(newFolderTitle.isEmpty)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    private func addToFolder(_ folder: RecipeFolder) {
        if folder.recipes.contains(recipe) {
            // Retirer de ce dossier
            dataManager.removeRecipe(recipe, from: folder)
        } else {
            // Ajouter à ce dossier
            dataManager.addRecipe(recipe, to: folder)
        }
    }
    
    private func createFolderAndAdd() {
        let newFolder = RecipeFolder(
            title: newFolderTitle,
            imageName: selectedIcon
        )
        dataManager.addFolder(newFolder)
        dataManager.addRecipe(recipe, to: newFolder)
        
        showingNewFolderSheet = false
        resetForm()
        dismiss()
    }
    
    private func resetForm() {
        newFolderTitle = ""
        selectedIcon = "folder"
    }
    
    // Couleur basée sur l'icône du dossier (même logique que CompactFolderButton)
    private func folderColor(for folder: RecipeFolder) -> Color {
        switch folder.imageName {
        case "figure.run", "bolt.fill":
            return Color(red: 0.95, green: 0.5, blue: 0.2) // Orange sport
        case "snowflake", "drop.fill":
            return Color(red: 0.3, green: 0.6, blue: 0.9) // Bleu hiver
        case "leaf.fill", "leaf", "leaf.circle":
            return Color(red: 0.4, green: 0.7, blue: 0.4) // Vert nature
        case "flame", "sun.max":
            return Color(red: 0.95, green: 0.4, blue: 0.2) // Orange/rouge feu
        case "moon.stars":
            return Color(red: 0.5, green: 0.4, blue: 0.7) // Violet nuit
        case "heart.fill", "heart":
            return Color(red: 0.9, green: 0.3, blue: 0.4) // Rose/rouge
        case "star.fill", "star":
            return Color(red: 0.95, green: 0.7, blue: 0.2) // Jaune doré
        default:
            return Color(red: 0.4, green: 0.7, blue: 0.4) // Vert par défaut
        }
    }
}

// Composant pour le partage natif iOS
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    @MainActor in
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let schema = Schema([
        Recipe.self,
        RecipeFolder.self,
        UserProfile.self
    ])
    let container = try! ModelContainer(for: schema, configurations: config)
    let context = ModelContext(container)
    let manager = SwiftDataManager(modelContext: context)
    let upm = UserProfileManager()
    upm.configure(with: manager)
    
    return NavigationStack {
        RecipeDetailView(
            recipe: Recipe(title: "Bowl veggie", subtitle: "Protéines végétales", imageName: "leaf"),
            profileManager: upm,
            dataManager: manager
        )
    }
}
