import SwiftUI

// MARK: - Theme Manager

/// Gestionnaire de theme pour l'application
@Observable
class ThemeManager {
    static let shared = ThemeManager()

    // Stockage persistant
    private let themeKey = "selectedTheme"

    var selectedTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: themeKey)
        }
    }

    var colorScheme: ColorScheme? {
        switch selectedTheme {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    private init() {
        let savedTheme = UserDefaults.standard.string(forKey: themeKey) ?? AppTheme.system.rawValue
        self.selectedTheme = AppTheme(rawValue: savedTheme) ?? .system
    }
}

// MARK: - App Theme

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "Systeme"
    case light = "Clair"
    case dark = "Sombre"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

// MARK: - Theme Colors

/// Couleurs adaptees au theme
struct ThemeColors {
    @Environment(\.colorScheme) private var colorScheme

    // Couleurs de fond
    static func background(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.1, green: 0.1, blue: 0.1) : .ecoDietSand
    }

    static func cardBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.15, green: 0.15, blue: 0.15) : .white
    }

    static func secondaryBackground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color(red: 0.2, green: 0.2, blue: 0.2) : Color.gray.opacity(0.1)
    }

    // Couleurs de texte
    static func primaryText(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .white : .primary
    }

    static func secondaryText(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.7) : .secondary
    }
}

// MARK: - Themed Background Modifier

struct ThemedBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(ThemeColors.background(for: colorScheme))
    }
}

extension View {
    func themedBackground() -> some View {
        modifier(ThemedBackgroundModifier())
    }
}

// MARK: - Themed Card Modifier

struct ThemedCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(ThemeColors.cardBackground(for: colorScheme))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        colorScheme == .dark
                            ? Color.white.opacity(0.1)
                            : Color.black.opacity(0.05),
                        lineWidth: 1
                    )
            )
    }
}

extension View {
    func themedCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(ThemedCardModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Theme Picker View

/// Vue pour selectionner le theme
struct ThemePickerView: View {
    @Bindable var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Apparence")
                .font(.headline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                ForEach(AppTheme.allCases) { theme in
                    ThemeOptionButton(
                        theme: theme,
                        isSelected: themeManager.selectedTheme == theme,
                        colorScheme: colorScheme
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            themeManager.selectedTheme = theme
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

struct ThemeOptionButton: View {
    let theme: AppTheme
    let isSelected: Bool
    let colorScheme: ColorScheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(previewBackground)
                        .frame(width: 60, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isSelected ? Color.ecoDietGreen : Color.clear, lineWidth: 2)
                        )

                    Image(systemName: theme.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(previewIconColor)
                }

                Text(theme.rawValue)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
    }

    private var previewBackground: Color {
        switch theme {
        case .system:
            return colorScheme == .dark ? Color(white: 0.2) : Color(white: 0.95)
        case .light:
            return Color(white: 0.95)
        case .dark:
            return Color(white: 0.15)
        }
    }

    private var previewIconColor: Color {
        switch theme {
        case .system:
            return .ecoDietGreen
        case .light:
            return .orange
        case .dark:
            return .yellow
        }
    }
}

// MARK: - Theme Applied Modifier

struct ThemeAppliedModifier: ViewModifier {
    @Bindable var themeManager = ThemeManager.shared

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.colorScheme)
    }
}

extension View {
    func withThemeSupport() -> some View {
        modifier(ThemeAppliedModifier())
    }
}

#Preview {
    ThemePickerView()
        .padding()
}
