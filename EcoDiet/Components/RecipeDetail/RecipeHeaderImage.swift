import SwiftUI

/// Composant affichant l'image d'en-tête d'une recette
struct RecipeHeaderImage: View {
    let imageName: String

    var body: some View {
        VStack {
            // Essayer d'abord de charger une URL, sinon afficher un SF Symbol
            if imageName.starts(with: "http://") || imageName.starts(with: "https://") {
                // Image depuis URL (PostgreSQL)
                CachedAsyncImage(url: URL(string: imageName)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .frame(height: 280)
                        ProgressView()
                    }
                }
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 24)
            } else {
                // SF Symbol (recettes par défaut)
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(height: 280)

                    Image(systemName: imageName)
                        .font(.system(size: 80, weight: .light))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

#Preview {
    RecipeHeaderImage(imageName: "leaf.fill")
}
