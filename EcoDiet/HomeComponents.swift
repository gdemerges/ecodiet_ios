import SwiftUI
import SwiftData

// MARK: - Home Header View

/// En-tete de la page d'accueil avec salutation et profil
struct HomeHeaderView: View {
    let greeting: String
    let profileManager: UserProfileManager
    let dataManager: SwiftDataManager
    @Binding var isAuthenticated: Bool
    let headerAppeared: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.largeTitle).bold()
                    .opacity(headerAppeared ? 1 : 0)
                    .offset(x: headerAppeared ? 0 : -20)

                HStack(spacing: 4) {
                    Image(systemName: "leaf.fill")
                        .font(.caption2)
                        .foregroundStyle(.ecoDietSecondaryGreen)

                    Text("Mangez sainement, naturellement")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .opacity(headerAppeared ? 1 : 0)
                .offset(x: headerAppeared ? 0 : -20)
            }

            Spacer()

            NavigationLink {
                ProfileView(
                    profileManager: profileManager,
                    dataManager: dataManager,
                    isAuthenticated: $isAuthenticated
                )
            } label: {
                ProfileButton(headerAppeared: headerAppeared)
            }
            .accessibilityLabel("Profil")
        }
        .padding(.top, 8)
    }
}

// MARK: - Profile Button

struct ProfileButton: View {
    let headerAppeared: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.ecoDietGreen, .ecoDietSecondaryGreen],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 44)
                .shadow(color: Color.ecoDietGreen.opacity(0.3), radius: 8, x: 0, y: 4)

            Image(systemName: "person.crop.circle")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
        }
        .scaleEffect(headerAppeared ? 1 : 0.5)
        .opacity(headerAppeared ? 1 : 0)
    }
}

// MARK: - Section Header View

/// En-tete de section reutilisable
struct HomeSectionHeader: View {
    let icon: String
    let title: String
    let iconColors: [Color]
    var trailingContent: AnyView? = nil

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: iconColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
            }

            Spacer()

            if let trailing = trailingContent {
                trailing
            }
        }
    }
}

// MARK: - See All Button

struct SeeAllButton: View {
    let destination: AnyView

    var body: some View {
        NavigationLink {
            destination
        } label: {
            Text("Voir tout")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
        }
    }
}

// MARK: - Recipe Carousel

/// Carrousel horizontal de recettes
struct RecipeCarousel: View {
    let recipes: [Recipe]
    let profileManager: UserProfileManager
    let dataManager: SwiftDataManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(recipes) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe, profileManager: profileManager, dataManager: dataManager)
                    } label: {
                        RecipeCard(recipe: recipe)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 2)
        }
        .background(Color.clear)
    }
}

// MARK: - PostgreSQL Import Button

struct PostgreSQLImportButton: View {
    let dataManager: SwiftDataManager

    var body: some View {
        NavigationLink {
            RecettesPostgreSQLView(dataManager: dataManager)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "arrow.down.circle")
                    .font(.caption)
                Text("PostgreSQL")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ecoDietGreen, in: Capsule())
        }
        .accessibilityLabel("Importer depuis PostgreSQL")
    }
}

// MARK: - Quiz Section

struct QuizSection: View {
    var body: some View {
        VStack(spacing: 16) {
            HomeSectionHeader(
                icon: "brain.head.profile",
                title: "Testez vos connaissances",
                iconColors: [
                    Color(red: 0.5, green: 0.4, blue: 0.7),
                    Color(red: 0.6, green: 0.5, blue: 0.8)
                ]
            )

            VStack(spacing: 16) {
                NavigationLink {
                    EcoQuizView()
                } label: {
                    QuizCard()
                }
                .buttonStyle(PlainButtonStyle())

                NavigationLink {
                    SportsQuizView()
                } label: {
                    SportsQuizCard()
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Greeting Helper

extension HomeView {
    static func buildGreeting(for profile: UserProfile?) -> String {
        let firstName = profile?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let hour = Calendar.current.component(.hour, from: Date())

        let timeGreeting: String
        switch hour {
        case 6..<18:
            timeGreeting = "Bonjour"
        case 18..<22:
            timeGreeting = "Bonsoir"
        default:
            timeGreeting = "Bonsoir"
        }

        return firstName.isEmpty ? "\(timeGreeting) !" : "\(timeGreeting) \(firstName) !"
    }
}
