//
//  BarcodeScannerTestView.swift
//  EcoDiet
//
//  Created by Guillaume Demergès on 13/11/2025.
//

import SwiftUI

/// Vue de test pour l'intégration OpenFoodFacts (sans besoin de scanner réel)
/// Utile pour le développement et les tests sur simulateur
struct BarcodeScannerTestView: View {
    @State private var isLoading = false
    @State private var scannedProduct: OpenFoodFactsService.FoodProduct?
    @State private var errorMessage: String?
    @State private var showingError = false
    @State private var customBarcode = ""
    
    private let openFoodFactsService = OpenFoodFactsService()
    
    // Codes-barres de test connus
    private let testBarcodes = [
        TestBarcode(name: "Nutella", barcode: "3017620422003", category: "Petit-déjeuner"),
        TestBarcode(name: "Coca-Cola", barcode: "5449000000996", category: "Boissons"),
        TestBarcode(name: "Haribo Dragibus", barcode: "3175681851870", category: "Confiseries"),
        TestBarcode(name: "Lu Petit Beurre", barcode: "7622210449283", category: "Biscuits"),
        TestBarcode(name: "Danone Activia", barcode: "3033490001032", category: "Yaourts"),
        TestBarcode(name: "Pain de mie", barcode: "3256220109406", category: "Boulangerie")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AuthBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Instructions
                        instructionsCard
                        
                        // Code-barres personnalisé
                        customBarcodeSection
                        
                        // Produits de test
                        testProductsSection
                        
                        // Résultat
                        if let product = scannedProduct {
                            productResultCard(product)
                        }
                    }
                    .padding(20)
                }
                
                // Loading overlay
                if isLoading {
                    loadingOverlay
                }
            }
            .navigationTitle("Test OpenFoodFacts")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Erreur", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "Une erreur est survenue")
            }
        }
    }
    
    // MARK: - Instructions Card
    
    private var instructionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color(red: 0.5, green: 0.4, blue: 0.9))
                
                Text("Vue de test")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            Text("Cette vue permet de tester l'intégration OpenFoodFacts sans scanner de code-barres. Parfait pour le développement sur simulateur.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(red: 0.5, green: 0.4, blue: 0.9).opacity(0.3), lineWidth: 2)
        )
    }
    
    // MARK: - Custom Barcode Section
    
    private var customBarcodeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Code-barres personnalisé")
                .font(.headline)
                .foregroundStyle(.primary)
            
            HStack(spacing: 12) {
                TextField("Entrez un code-barres", text: $customBarcode)
                    .textFieldStyle(.plain)
                    .keyboardType(.numberPad)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), lineWidth: 1)
                    )
                
                Button {
                    searchProduct(barcode: customBarcode)
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.3, green: 0.7, blue: 0.4),
                                            Color(red: 0.2, green: 0.6, blue: 0.5)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                }
                .disabled(customBarcode.isEmpty)
                .opacity(customBarcode.isEmpty ? 0.5 : 1.0)
            }
        }
    }
    
    // MARK: - Test Products Section
    
    private var testProductsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Produits de test")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("Cliquez pour tester avec des produits connus")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(testBarcodes) { testBarcode in
                    testProductButton(testBarcode)
                }
            }
        }
    }
    
    private func testProductButton(_ testBarcode: TestBarcode) -> some View {
        Button {
            searchProduct(barcode: testBarcode.barcode)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: testBarcode.icon)
                        .font(.title2)
                        .foregroundStyle(testBarcode.color)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                Text(testBarcode.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(testBarcode.category)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(testBarcode.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Product Result Card
    
    private func productResultCard(_ product: OpenFoodFactsService.FoodProduct) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Résultat de la recherche")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button {
                    withAnimation {
                        scannedProduct = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.tertiary)
                }
            }
            
            HStack(spacing: 12) {
                // Image du produit
                Group {
                    if let imageUrlString = product.imageUrl,
                       let imageUrl = URL(string: imageUrlString) {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            productPlaceholder
                        }
                    } else {
                        productPlaceholder
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(product.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if let brand = product.brand {
                        Text(brand)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 8) {
                        if let ecoScore = product.ecoscoreGrade?.uppercased() {
                            scoreLabel("Eco: \(ecoScore)", color: ecoScoreColor(ecoScore))
                        }
                        
                        if let nutriScore = product.nutriscoreGrade?.uppercased() {
                            scoreLabel("Nutri: \(nutriScore)", color: nutriScoreColor(nutriScore))
                        }
                    }
                }
            }
            
            Divider()
            
            // Informations détaillées
            VStack(alignment: .leading, spacing: 8) {
                detailRow(icon: "barcode", label: "Code-barres", value: product.barcode)
                
                if let quantity = product.quantity {
                    detailRow(icon: "scalemass", label: "Quantité", value: quantity)
                }
                
                detailRow(icon: "tag", label: "Catégorie suggérée", value: product.suggestedCategory.rawValue)
                detailRow(icon: "ruler", label: "Unité suggérée", value: product.suggestedUnit.displayName)
                
                if !product.categories.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "list.bullet")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 20)
                            
                            Text("Catégories")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(product.categories.prefix(3).joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .padding(.leading, 28)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(red: 0.3, green: 0.7, blue: 0.4).opacity(0.3), lineWidth: 2)
        )
    }
    
    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .foregroundStyle(.primary)
        }
    }
    
    private var productPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.gray.opacity(0.2))
            
            Image(systemName: "photo")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }
    
    private func scoreLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color)
            )
    }
    
    private func ecoScoreColor(_ grade: String) -> Color {
        switch grade {
        case "A": return Color.green
        case "B": return Color(red: 0.6, green: 0.8, blue: 0.3)
        case "C": return Color.yellow
        case "D": return Color.orange
        case "E": return Color.red
        default: return Color.gray
        }
    }
    
    private func nutriScoreColor(_ grade: String) -> Color {
        switch grade {
        case "A": return Color.green
        case "B": return Color(red: 0.6, green: 0.8, blue: 0.3)
        case "C": return Color.yellow
        case "D": return Color.orange
        case "E": return Color.red
        default: return Color.gray
        }
    }
    
    // MARK: - Loading Overlay
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Recherche du produit...")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func searchProduct(barcode: String) {
        isLoading = true
        scannedProduct = nil
        
        Task {
            do {
                if let product = try await openFoodFactsService.fetchProduct(barcode: barcode) {
                    await MainActor.run {
                        withAnimation {
                            scannedProduct = product
                        }
                        isLoading = false
                    }
                } else {
                    await MainActor.run {
                        isLoading = false
                        errorMessage = "Produit non trouvé dans la base de données OpenFoodFacts"
                        showingError = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
}

// MARK: - Test Barcode Model

struct TestBarcode: Identifiable {
    let id = UUID()
    let name: String
    let barcode: String
    let category: String
    
    var icon: String {
        switch category {
        case "Petit-déjeuner": return "cup.and.saucer.fill"
        case "Boissons": return "drop.fill"
        case "Confiseries": return "heart.fill"
        case "Biscuits": return "circle.grid.3x3.fill"
        case "Yaourts": return "cube.fill"
        case "Boulangerie": return "circle.fill"
        default: return "bag.fill"
        }
    }
    
    var color: Color {
        switch category {
        case "Petit-déjeuner": return Color(red: 0.9, green: 0.6, blue: 0.2)
        case "Boissons": return Color(red: 0.4, green: 0.6, blue: 0.9)
        case "Confiseries": return Color(red: 0.9, green: 0.4, blue: 0.6)
        case "Biscuits": return Color(red: 0.8, green: 0.7, blue: 0.4)
        case "Yaourts": return Color(red: 0.5, green: 0.7, blue: 0.9)
        case "Boulangerie": return Color(red: 0.7, green: 0.5, blue: 0.3)
        default: return Color.gray
        }
    }
}

#Preview {
    BarcodeScannerTestView()
}
