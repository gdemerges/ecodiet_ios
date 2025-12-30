import SwiftUI

/// Boutons flottants pour scanner et ajouter des ingrédients
struct FridgeFloatingActions: View {
    @Binding var showingBarcodeScanner: Bool
    @Binding var showingAddIngredient: Bool

    var body: some View {
        VStack {
            Spacer()

            HStack(spacing: 12) {
                Spacer()

                // Bouton scanner
                Button {
                    showingBarcodeScanner = true
                } label: {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.ecoDietOrange, .ecoDietOrange.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: Color.ecoDietOrange.opacity(0.4), radius: 8, x: 0, y: 4)
                }

                // Bouton ajouter manuellement
                Button {
                    showingAddIngredient = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))

                        Text("Ajouter")
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
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
                    .clipShape(Capsule())
                    .shadow(color: Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.4), radius: 12, x: 0, y: 6)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
}

#Preview {
    FridgeFloatingActions(
        showingBarcodeScanner: .constant(false),
        showingAddIngredient: .constant(false)
    )
}
