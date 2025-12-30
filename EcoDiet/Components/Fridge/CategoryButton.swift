import SwiftUI

/// Bouton de sélection de catégorie
struct CategoryButton: View {
    let name: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))

                Text(name)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? color.gradient : Color.clear.gradient)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : color.opacity(0.4), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        CategoryButton(
            name: "Fruits",
            icon: "apple.logo",
            color: .red,
            isSelected: true,
            action: {}
        )

        CategoryButton(
            name: "Légumes",
            icon: "carrot",
            color: .green,
            isSelected: false,
            action: {}
        )
    }
    .padding()
}
