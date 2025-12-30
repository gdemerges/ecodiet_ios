import SwiftUI
import SwiftData

struct RecettesPostgreSQLView: View {
    let dataManager: SwiftDataManager
    @State private var postgreSQLService = PostgreSQLService()
    @State private var recettes: [MarmitonRecette] = []
    @State private var isLoading = false
    @State private var isLoadingMore = false
    @State private var errorMessage: String?
    @State private var searchQuery = ""
    @State private var debouncedSearchQuery = ""
    @State private var showingSyncConfirmation = false
    @State private var searchDebouncer = Debouncer(delay: 0.3)
    @State private var currentPage = 1
    @State private var hasMorePages = true
    private let pageSize = 20

    var filteredRecettes: [MarmitonRecette] {
        if debouncedSearchQuery.isEmpty {
            return recettes
        }
        return recettes.filter { recette in
            recette.titre?.localizedCaseInsensitiveContains(debouncedSearchQuery) ?? false
        }
    }
    
    var body: some View {
        ZStack {
            Color.ecoDietSand.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Barre de recherche
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField("Rechercher une recette...", text: $searchQuery)
                        .textFieldStyle(.plain)
                    
                    if !searchQuery.isEmpty {
                        Button {
                            searchQuery = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding()
                
                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Chargement des recettes...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.orange)
                        
                        Text("Erreur")
                            .font(.title2.bold())
                        
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button {
                            Task {
                                await loadRecettes()
                            }
                        } label: {
                            Label("Réessayer", systemImage: "arrow.clockwise")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding()
                                .background(.ecoDietGreen, in: Capsule())
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .padding()
                } else if recettes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        
                        Text("Aucune recette")
                            .font(.title2.bold())
                        
                        Text("Chargez les recettes depuis PostgreSQL")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredRecettes) { recette in
                                PostgreSQLRecetteCard(
                                    recette: recette,
                                    onImport: {
                                        importRecette(recette)
                                    }
                                )
                                .onAppear {
                                    // Infinite scroll: charger plus quand on approche de la fin
                                    if recette.id == filteredRecettes.last?.id && hasMorePages && !isLoadingMore {
                                        Task {
                                            await loadMoreRecettes()
                                        }
                                    }
                                }
                            }

                            // Indicateur de chargement en bas
                            if isLoadingMore {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .padding()
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Recettes PostgreSQL")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        Task {
                            await loadRecettes()
                        }
                    } label: {
                        Label("Charger toutes", systemImage: "arrow.clockwise")
                    }
                    
                    Button {
                        Task {
                            await loadRandomRecettes()
                        }
                    } label: {
                        Label("Charger aléatoires", systemImage: "shuffle")
                    }
                    
                    Divider()
                    
                    Button {
                        showingSyncConfirmation = true
                    } label: {
                        Label("Synchroniser tout", systemImage: "arrow.down.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                }
            }
        }
        .alert("Synchroniser les recettes", isPresented: $showingSyncConfirmation) {
            Button("Annuler", role: .cancel) { }
            Button("Synchroniser") {
                Task {
                    await syncAllRecettes()
                }
            }
        } message: {
            Text("Voulez-vous importer toutes les recettes PostgreSQL dans l'application ? Cela peut prendre quelques instants.")
        }
        .task {
            await loadRecettes()
        }
        .onChange(of: searchQuery) { _, newValue in
            searchDebouncer.debounce {
                await MainActor.run {
                    debouncedSearchQuery = newValue
                }
            }
        }
    }
    
    // MARK: - Actions

    private func loadRecettes() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        hasMorePages = true

        do {
            let newRecettes = try await postgreSQLService.fetchRecettes(page: currentPage, limit: pageSize)
            recettes = newRecettes
            hasMorePages = newRecettes.count == pageSize
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func loadMoreRecettes() async {
        guard !isLoadingMore && hasMorePages else { return }

        isLoadingMore = true
        currentPage += 1

        do {
            let newRecettes = try await postgreSQLService.fetchRecettes(page: currentPage, limit: pageSize)
            recettes.append(contentsOf: newRecettes)
            hasMorePages = newRecettes.count == pageSize
        } catch {
            currentPage -= 1 // Revenir en arriere en cas d'erreur
        }

        isLoadingMore = false
    }

    private func loadRandomRecettes() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1

        do {
            recettes = try await postgreSQLService.fetchRecettes(page: 1, limit: pageSize)
            recettes.shuffle()
            hasMorePages = false // Pas de pagination pour aleatoire
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    private func importRecette(_ recette: MarmitonRecette) {
        let recipe = postgreSQLService.convertToLocalRecipe(recette)
        dataManager.addRecipe(recipe)
        
        // Feedback haptique
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func syncAllRecettes() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await postgreSQLService.syncRecipesToSwiftData(dataManager: dataManager)
            
            // Feedback haptique
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

struct PostgreSQLRecetteCard: View {
    let recette: MarmitonRecette
    let onImport: () -> Void
    @State private var isImported = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Image ou placeholder avec cache
            if let photoURL = recette.photo, !photoURL.isEmpty {
                CachedAsyncImage(url: URL(string: photoURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            ProgressView()
                        }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(recette.titre ?? "Sans titre")
                    .font(.headline)
                    .lineLimit(2)
                
                if let duree = recette.duree {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text(duree)
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
                
                if let ingredients = recette.ingredients {
                    Text("\(ingredients.count) ingrédients")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Button {
                onImport()
                withAnimation {
                    isImported = true
                }
                
                // Réinitialiser après 2 secondes
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isImported = false
                    }
                }
            } label: {
                Image(systemName: isImported ? "checkmark.circle.fill" : "arrow.down.circle")
                    .font(.title2)
                    .foregroundStyle(isImported ? .green : .ecoDietGreen)
            }
            .disabled(isImported)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let schema = Schema([Recipe.self, RecipeFolder.self, UserProfile.self, Ingredient.self])
    let container = try! ModelContainer(for: schema, configurations: config)
    let context = ModelContext(container)
    let manager = SwiftDataManager(modelContext: context)
    
    return NavigationStack {
        RecettesPostgreSQLView(dataManager: manager)
    }
}
