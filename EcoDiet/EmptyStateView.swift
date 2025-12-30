import SwiftUI

// MARK: - Empty State View

/// Vue reutilisable pour les etats vides
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    var actionTitle: String?
    var action: (() -> Void)?

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 24) {
            // Icone animee
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.ecoDietGreen.opacity(0.15),
                                Color.ecoDietGreen.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.ecoDietGreen.opacity(0.2),
                                Color.ecoDietSecondaryGreen.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: icon)
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.ecoDietGreen, .ecoDietSecondaryGreen],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .offset(y: isAnimating ? -4 : 4)
            }

            // Texte
            VStack(spacing: 8) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(.horizontal, 32)

            // Bouton d'action optionnel
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text(actionTitle)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.ecoDietGreen, .ecoDietSecondaryGreen],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: Capsule()
                    )
                    .shadow(color: .ecoDietGreen.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
        }
        .padding(.vertical, 40)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Preset Empty States

extension EmptyStateView {
    /// Etat vide pour le frigo
    static func fridge(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "refrigerator",
            title: "Votre frigo est vide",
            description: "Ajoutez vos ingredients pour decouvrir des recettes adaptees",
            actionTitle: "Ajouter un ingredient",
            action: action
        )
    }

    /// Etat vide pour les recettes
    static func recipes(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "book.closed",
            title: "Aucune recette",
            description: "Importez des recettes depuis PostgreSQL ou creez les votres",
            actionTitle: "Importer des recettes",
            action: action
        )
    }

    /// Etat vide pour les dossiers
    static func folders(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "folder",
            title: "Aucun dossier",
            description: "Creez des dossiers pour organiser vos recettes favorites",
            actionTitle: "Creer un dossier",
            action: action
        )
    }

    /// Etat vide pour les favoris
    static var favorites: EmptyStateView {
        EmptyStateView(
            icon: "heart",
            title: "Pas encore de favoris",
            description: "Ajoutez des recettes a vos favoris pour les retrouver facilement"
        )
    }

    /// Etat vide pour la recherche
    static func searchNoResults(query: String) -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "Aucun resultat",
            description: "Aucun resultat pour \"\(query)\". Essayez d'autres termes de recherche."
        )
    }

    /// Etat d'erreur
    static func error(message: String, action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "exclamationmark.triangle",
            title: "Une erreur est survenue",
            description: message,
            actionTitle: "Reessayer",
            action: action
        )
    }

    /// Etat de connexion requise
    static func connectionRequired(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "wifi.slash",
            title: "Connexion requise",
            description: "Verifiez votre connexion internet et reessayez",
            actionTitle: "Reessayer",
            action: action
        )
    }
}

// MARK: - Loading State View

/// Vue pour les etats de chargement
struct LoadingStateView: View {
    let message: String

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.ecoDietGreen.opacity(0.2), lineWidth: 4)
                    .frame(width: 50, height: 50)

                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [.ecoDietGreen, .ecoDietSecondaryGreen],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 50, height: 50)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
            }

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

#Preview("Empty Fridge") {
    EmptyStateView.fridge { }
}

#Preview("Loading") {
    LoadingStateView(message: "Chargement des recettes...")
}
