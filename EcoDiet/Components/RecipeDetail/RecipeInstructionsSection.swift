import SwiftUI

/// Composant affichant les instructions de préparation d'une recette
struct RecipeInstructionsSection: View {
    let instructions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Instructions")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
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
    }
}

#Preview {
    RecipeInstructionsSection(instructions: [
        "Rincer le quinoa et le faire cuire dans de l'eau bouillante pendant 15 minutes.",
        "Couper l'avocat en tranches et les carottes en julienne.",
        "Disposer tous les ingrédients dans un bol et arroser d'huile d'olive.",
        "Saupoudrer de graines de tournesol et servir immédiatement."
    ])
    .padding()
}
