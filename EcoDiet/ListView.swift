import SwiftUI

struct ListView: View {
    @State private var searchText: String = ""

    let recipes: [Recipe] = [
        Recipe(title: "Bowl veggie", subtitle: "Protéines végétales", imageName: "leaf"),
        Recipe(title: "Salade césar", subtitle: "Poulet, parmesan", imageName: "fork.knife"),
        Recipe(title: "Pâtes complètes", subtitle: "Tomates & basilic", imageName: "takeoutbag.and.cup.and.straw"),
        Recipe(title: "Soupe de saison", subtitle: "Potiron & coco", imageName: "cup.and.saucer"),
        Recipe(title: "Riz aux légumes", subtitle: "Coloré et nutritif", imageName: "carrot"),
        Recipe(title: "Quiche aux épinards", subtitle: "Pâte feuilletée maison", imageName: "circle.hexagongrid"),
        Recipe(title: "Poulet rôti", subtitle: "Herbes de Provence", imageName: "bird"),
        Recipe(title: "Saumon grillé", subtitle: "Citron et aneth", imageName: "fish"),
        Recipe(title: "Curry de pois chiches", subtitle: "Épices douces", imageName: "flame"),
        Recipe(title: "Tacos végétariens", subtitle: "Haricots noirs", imageName: "tortoise")
    ]

    var filteredRecipes: [Recipe] {
        if searchText.isEmpty { return recipes }
        return recipes.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List {
            ForEach(filteredRecipes) { recipe in
                NavigationLink {
                    RecipeDetailView(recipe: recipe)
                } label: {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .frame(width: 48, height: 48)
                            .overlay(
                                Image(systemName: recipe.imageName)
                                    .font(.title3)
                                    .foregroundStyle(.tint)
                            )

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
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.thinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(.white.opacity(0.15), lineWidth: 1)
                    )
                }
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
}

#Preview {
    NavigationStack {
        ListView()
    }
}
