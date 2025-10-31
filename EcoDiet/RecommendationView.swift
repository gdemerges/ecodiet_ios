import SwiftUI

struct RecommendationView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Recommandations")
                    .font(.largeTitle.bold())
                Text("Voici des suggestions personnalisées pour vous.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Placeholder cards
                ForEach(0..<8) { index in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .frame(width: 64, height: 64)
                            .overlay(
                                Image(systemName: "star.fill")
                                    .font(.title3)
                                    .foregroundStyle(.yellow)
                            )
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Suggestion #\(index + 1)")
                                .font(.headline)
                            Text("Une recommandation adaptée à vos goûts.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.thinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(.white.opacity(0.15), lineWidth: 1)
                    )
                }
            }
            .padding(24)
        }
        .navigationTitle("Recommandations")
        .navigationBarTitleDisplayMode(.inline)
        .background(AuthBackground().ignoresSafeArea())
    }
}

#Preview {
    NavigationStack {
        RecommendationView()
    }
}
