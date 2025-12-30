import SwiftUI

/// Carte affichant les informations d'un produit scanné
struct ScannedProductCard: View {
    let product: OpenFoodFactsService.FoodProduct
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Produit scanné")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.tertiary)
                }
            }

            HStack(spacing: 12) {
                if let imageUrlString = product.imageUrl,
                   let imageUrl = URL(string: imageUrlString) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .frame(width: 60, height: 60)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)

                    if let brand = product.brand {
                        Text(brand)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0.5, green: 0.4, blue: 0.9).opacity(0.1))
            )
        }
    }
}

#Preview {
    ScannedProductCard(
        product: OpenFoodFactsService.FoodProduct(
            barcode: "1234567890",
            name: "Tomates Bio",
            brand: "Marque Test",
            categories: ["Légumes"],
            imageUrl: nil,
            quantity: "500g",
            ecoscoreGrade: "a",
            nutriscoreGrade: "a",
            ingredientsList: ["Tomates"]
        ),
        onDismiss: {}
    )
    .padding()
}
