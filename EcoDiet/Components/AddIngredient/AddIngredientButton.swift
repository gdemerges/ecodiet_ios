import SwiftUI

/// Bouton flottant pour ajouter un ingrédient
struct AddIngredientButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        VStack {
            Spacer()

            Button(action: action) {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))

                    Text("Ajouter l'ingrédient")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.3, green: 0.7, blue: 0.4),
                            Color(red: 0.2, green: 0.6, blue: 0.5)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .disabled(!isEnabled)
            .opacity(isEnabled ? 1.0 : 0.5)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    AddIngredientButton(isEnabled: true, action: {})
}
