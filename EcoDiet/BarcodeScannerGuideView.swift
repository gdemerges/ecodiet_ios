//
//  BarcodeScannerGuideView.swift
//  EcoDiet
//
//  Created by Guillaume Demergès on 13/11/2025.
//

import SwiftUI

/// Vue de guide pour expliquer l'utilisation du scanner de code-barres
struct BarcodeScannerGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    private let pages: [GuidePage] = [
        GuidePage(
            icon: "barcode.viewfinder",
            title: "Scanner des produits",
            description: "Utilisez la caméra pour scanner les codes-barres de vos produits alimentaires",
            iconColor: Color(red: 0.5, green: 0.4, blue: 0.9)
        ),
        GuidePage(
            icon: "network",
            title: "Base de données mondiale",
            description: "Accédez à plus de 2 millions de produits référencés sur OpenFoodFacts",
            iconColor: Color(red: 0.3, green: 0.7, blue: 0.4)
        ),
        GuidePage(
            icon: "chart.bar.fill",
            title: "Informations nutritionnelles",
            description: "Découvrez l'Eco-Score et le Nutri-Score de vos aliments",
            iconColor: Color(red: 0.9, green: 0.6, blue: 0.2)
        ),
        GuidePage(
            icon: "refrigerator.fill",
            title: "Ajout automatique",
            description: "Les informations du produit remplissent automatiquement votre frigo",
            iconColor: Color(red: 0.4, green: 0.6, blue: 0.9)
        )
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Pages défilables
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        GuidePageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Indicateurs de page personnalisés
                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? pages[index].iconColor : Color.gray.opacity(0.3))
                            .frame(width: currentPage == index ? 10 : 8, height: currentPage == index ? 10 : 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 24)
                
                // Boutons de navigation
                HStack(spacing: 16) {
                    if currentPage > 0 {
                        Button {
                            withAnimation {
                                currentPage -= 1
                            }
                        } label: {
                            Text("Précédent")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                )
                        }
                    }
                    
                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            dismiss()
                        }
                    } label: {
                        Text(currentPage < pages.count - 1 ? "Suivant" : "Commencer")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [
                                        pages[currentPage].iconColor,
                                        pages[currentPage].iconColor.opacity(0.8)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: pages[currentPage].iconColor.opacity(0.3), radius: 12, x: 0, y: 6)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationTitle("Guide d'utilisation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct GuidePage {
    let icon: String
    let title: String
    let description: String
    let iconColor: Color
}

struct GuidePageView: View {
    let page: GuidePage
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(page.iconColor.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .opacity(isAnimating ? 0.5 : 0.8)
                
                Circle()
                    .fill(page.iconColor.opacity(0.3))
                    .frame(width: 160, height: 160)
                
                Image(systemName: page.icon)
                    .font(.system(size: 70, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                page.iconColor,
                                page.iconColor.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: page.iconColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
            }
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title.weight(.bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    BarcodeScannerGuideView()
}
