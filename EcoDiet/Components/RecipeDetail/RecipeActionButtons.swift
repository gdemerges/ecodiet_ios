import SwiftUI

/// Composant affichant les boutons d'action d'une recette (favoris, dossiers, partage)
struct RecipeActionButtons: View {
    let recipe: Recipe
    let profileManager: UserProfileManager
    @Binding var showingFolderPicker: Bool
    @Binding var showingShareSheet: Bool

    var body: some View {
        VStack(spacing: 12) {
            // Bouton Favoris
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

            // Bouton Ajouter à un dossier
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

            // Bouton Partager
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
}

#Preview {
    @Previewable @State var showingFolder = false
    @Previewable @State var showingShare = false

    RecipeActionButtons(
        recipe: Recipe(
            title: "Bowl veggie",
            subtitle: "Protéines végétales",
            imageName: "leaf"
        ),
        profileManager: UserProfileManager(),
        showingFolderPicker: $showingFolder,
        showingShareSheet: $showingShare
    )
    .padding()
}
