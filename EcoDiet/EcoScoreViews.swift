import SwiftUI

/// Badge d'Eco-Score à afficher sur les cartes de recettes
struct EcoScoreBadge: View {
    let ecoScore: EcoScore
    let size: BadgeSize
    
    enum BadgeSize {
        case small   // Pour les cartes
        case medium  // Pour les détails
        case large   // Pour les en-têtes
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 24
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 10
            case .large: return 14
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 10
            case .large: return 12
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text(ecoScore.rawValue)
                .font(.system(size: size.fontSize, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, size.padding)
        .padding(.vertical, size.padding * 0.6)
        .background(
            RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                .fill(Color(red: ecoScore.swiftUIColor.red, 
                           green: ecoScore.swiftUIColor.green, 
                           blue: ecoScore.swiftUIColor.blue))
        )
        .overlay(
            RoundedRectangle(cornerRadius: size.cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
    }
}

/// Vue détaillée de l'Eco-Score avec informations complètes
struct EcoScoreDetailView: View {
    let recipe: Recipe
    @State private var showInfo = false
    
    private var carbonText: String {
        let kg = recipe.carbonFootprint / 1000
        if kg < 1 {
            return String(format: "%.0f g", recipe.carbonFootprint)
        } else {
            return String(format: "%.1f kg", kg)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Impact environnemental")
                    .font(.headline)
                Spacer()
                Button {
                    showInfo.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack(spacing: 16) {
                // Grand badge Eco-Score
                VStack(spacing: 8) {
                    EcoScoreBadge(ecoScore: recipe.ecoScore, size: .large)
                    
                    Text(recipe.ecoScore.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Détails des émissions
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "cloud.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Empreinte carbone")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("\(carbonText) CO₂eq")
                        .font(.title3.weight(.bold))
                    
                    Text("par portion")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(red: recipe.ecoScore.swiftUIColor.red,
                                green: recipe.ecoScore.swiftUIColor.green,
                                blue: recipe.ecoScore.swiftUIColor.blue).opacity(0.3),
                           lineWidth: 2)
            )
            
            if showInfo {
                infoBox
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showInfo)
    }
    
    private var infoBox: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.blue)
                Text("Comprendre l'Eco-Score")
                    .font(.subheadline.weight(.semibold))
            }
            
            Text("L'Eco-Score évalue l'impact environnemental d'une recette en fonction de ses émissions de CO₂. Il va de A (très faible impact) à E (impact très élevé).")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                scoreRow(score: .a, range: "< 500g")
                scoreRow(score: .b, range: "500g - 1kg")
                scoreRow(score: .c, range: "1kg - 2kg")
                scoreRow(score: .d, range: "2kg - 3,5kg")
                scoreRow(score: .e, range: "> 3,5kg")
            }
            .font(.caption2)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.thinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func scoreRow(score: EcoScore, range: String) -> some View {
        HStack(spacing: 8) {
            EcoScoreBadge(ecoScore: score, size: .small)
            Text(score.description)
                .foregroundStyle(.secondary)
            Spacer()
            Text(range)
                .foregroundStyle(.tertiary)
        }
    }
}

/// Vue compacte de l'Eco-Score pour les listes
struct EcoScoreCompactView: View {
    let ecoScore: EcoScore
    
    var body: some View {
        HStack(spacing: 6) {
            Text(ecoScore.emoji)
                .font(.caption)
            
            Text(ecoScore.rawValue)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(red: ecoScore.swiftUIColor.red,
                                     green: ecoScore.swiftUIColor.green,
                                     blue: ecoScore.swiftUIColor.blue))
            
            Text(ecoScore.description)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview("Badge Small") {
    VStack(spacing: 16) {
        EcoScoreBadge(ecoScore: .a, size: .small)
        EcoScoreBadge(ecoScore: .b, size: .small)
        EcoScoreBadge(ecoScore: .c, size: .small)
        EcoScoreBadge(ecoScore: .d, size: .small)
        EcoScoreBadge(ecoScore: .e, size: .small)
    }
    .padding()
}

#Preview("Badge Medium") {
    VStack(spacing: 16) {
        EcoScoreBadge(ecoScore: .a, size: .medium)
        EcoScoreBadge(ecoScore: .b, size: .medium)
        EcoScoreBadge(ecoScore: .c, size: .medium)
        EcoScoreBadge(ecoScore: .d, size: .medium)
        EcoScoreBadge(ecoScore: .e, size: .medium)
    }
    .padding()
}

#Preview("Badge Large") {
    VStack(spacing: 16) {
        EcoScoreBadge(ecoScore: .a, size: .large)
        EcoScoreBadge(ecoScore: .b, size: .large)
        EcoScoreBadge(ecoScore: .c, size: .large)
        EcoScoreBadge(ecoScore: .d, size: .large)
        EcoScoreBadge(ecoScore: .e, size: .large)
    }
    .padding()
}

#Preview("Compact View") {
    VStack(spacing: 12) {
        EcoScoreCompactView(ecoScore: .a)
        EcoScoreCompactView(ecoScore: .b)
        EcoScoreCompactView(ecoScore: .c)
        EcoScoreCompactView(ecoScore: .d)
        EcoScoreCompactView(ecoScore: .e)
    }
    .padding()
}
