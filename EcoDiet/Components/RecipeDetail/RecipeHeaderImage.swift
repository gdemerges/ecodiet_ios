import SwiftUI

/// Composant affichant l'image d'en-tête d'une recette
struct RecipeHeaderImage: View {
    let imageName: String

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(height: 280)

                Image(systemName: imageName)
                    .font(.system(size: 80, weight: .light))
                    .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    RecipeHeaderImage(imageName: "leaf.fill")
}
