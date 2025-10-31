import SwiftUI

struct ListView: View {
    @State private var searchText: String = ""

    let items: [String] = [
        "Bowl veggie",
        "Salade césar",
        "Pâtes complètes",
        "Soupe de saison",
        "Riz aux légumes",
        "Quiche aux épinards",
        "Poulet rôti",
        "Saumon grillé",
        "Curry de pois chiches",
        "Tacos végétariens"
    ]

    var filteredItems: [String] {
        if searchText.isEmpty { return items }
        return items.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List {
            ForEach(filteredItems, id: \.self) { item in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(systemName: "fork.knife.circle")
                                .font(.title3)
                                .foregroundStyle(.tint)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item)
                            .font(.headline)
                        Text("Recette équilibrée et savoureuse")
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
