import SwiftUI

/// Vue affichée quand le frigo est vide
struct EmptyFridgeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "refrigerator")
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(.secondary)

            Text("Aucun ingrédient")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)

            Text("Ajoutez vos premiers ingrédients\npour commencer")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    EmptyFridgeView()
}
