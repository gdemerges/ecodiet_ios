import SwiftUI

/// Composant affichant les informations pratiques d'une recette (temps, portions, difficulté)
struct RecipeInfoCards: View {
    let recipe: Recipe

    var body: some View {
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
    }
}

#Preview {
    RecipeInfoCards(recipe: Recipe(
        title: "Bowl veggie",
        subtitle: "Protéines végétales",
        imageName: "leaf",
        carbonFootprint: 350,
        preparationTime: 15
    ))
}
