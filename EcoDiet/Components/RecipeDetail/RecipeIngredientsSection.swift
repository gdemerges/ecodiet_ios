import SwiftUI

/// Composant affichant la liste des ingrédients d'une recette
struct RecipeIngredientsSection: View {
    let ingredients: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ingrédients")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(ingredients, id: \.self) { ingredient in
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
    }
}

#Preview {
    RecipeIngredientsSection(ingredients: [
        "200g de quinoa",
        "150g de pois chiches",
        "1 avocat mûr",
        "100g d'épinards frais"
    ])
    .padding()
}
