import SwiftUI
import SwiftData

struct ListView: View {
    let profileManager: UserProfileManager
    let dataManager: SwiftDataManager
    @State private var searchText: String = ""

    var filteredRecipes: [Recipe] {
        if searchText.isEmpty { return dataManager.recipes }
        return dataManager.recipes.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List {
            ForEach(filteredRecipes) { recipe in
                recipeRow(for: recipe)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic))
        .navigationTitle("Toutes les recettes")
        .navigationBarTitleDisplayMode(.inline)
        .background(AuthBackground().ignoresSafeArea())
    }
    
    @ViewBuilder
    private func recipeRow(for recipe: Recipe) -> some View {
        NavigationLink(destination: RecipeDetailView(recipe: recipe, profileManager: profileManager, dataManager: dataManager)) {
            HStack(spacing: 12) {
                recipeIcon(for: recipe)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(recipe.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(12)
            .background(recipeCardBackground())
        }
    }
    
    @ViewBuilder
    private func recipeIcon(for recipe: Recipe) -> some View {
        if recipe.imageName.starts(with: "http://") || recipe.imageName.starts(with: "https://") {
            // Image depuis URL (PostgreSQL)
            CachedAsyncImage(url: URL(string: recipe.imageName)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        ProgressView()
                    }
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        } else {
            // SF Symbol
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: recipe.imageName)
                        .font(.title3)
                        .foregroundStyle(.tint)
                )
        }
    }
    
    @ViewBuilder
    private func recipeCardBackground() -> some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(.thinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
    }
}

#Preview {
    @MainActor in
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let schema = Schema([Recipe.self, RecipeFolder.self, UserProfile.self])
    let container = try! ModelContainer(for: schema, configurations: config)
    let context = ModelContext(container)
    let manager = SwiftDataManager(modelContext: context)
    let upm = UserProfileManager()
    upm.configure(with: manager)
    
    return NavigationStack {
        ListView(profileManager: upm, dataManager: manager)
    }
}
