//
//  ContentView.swift
//  EcoDiet
//
//  Created by Guillaume Demergès on 30/10/2025.
//
//  SYSTÈME D'AUTHENTIFICATION AVEC PROFILS HARDCODÉS
//  ==================================================
//
//  Ce fichier utilise des profils hardcodés pour l'authentification en attendant
//  l'intégration avec PostgreSQL.
//
//  COMPTES DE TEST DISPONIBLES:
//  - demo@ecodiet.com / demo123 (Utilisateur standard)
//  - veggie@ecodiet.com / veggie123 (Végétarien)
//  - sport@ecodiet.com / sport123 (Sportif)
//  - allergic@ecodiet.com / allergic123 (Avec allergies)
//  - vegan@ecodiet.com / vegan123 (Vegan)
//
//  FONCTIONNALITÉS:
//  - Authentification via AuthenticationManager
//  - Synchronisation automatique avec SwiftData
//  - Liste des comptes de test dans l'interface
//  - Geste secret (shake) pour afficher les comptes après connexion
//
//  TODO: Migrer vers PostgreSQL (voir HARDCODED_PROFILES_README.md)
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var isPresentingSignup = false
    @State private var profileManager = UserProfileManager()
    @State private var authManager = AuthenticationManager()
    @State private var dataManager: SwiftDataManager?
    @State private var fridgeManager: FridgeManager?
    
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            Group {
                if let dataManager = dataManager, let fridgeManager = fridgeManager {
                    if isAuthenticated {
                        MainTabView(
                            dataManager: dataManager,
                            profileManager: profileManager,
                            fridgeManager: fridgeManager,
                            isAuthenticated: $isAuthenticated
                        )
                    } else {
                        LoginView(
                            authManager: authManager,
                            profileManager: profileManager,
                            isAuthenticated: $isAuthenticated,
                            onSignup: { isPresentingSignup = true }
                        )
                        .sheet(isPresented: $isPresentingSignup) {
                            SignupFlowView(onComplete: handleSignupCompletion)
                                .presentationBackground(.clear)
                        }
                    }
                } else {
                    ProgressView("Chargement...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground))
                }
            }
        }
        .onAppear {
            setupDataManager()
        }
    }
    
    private func setupDataManager() {
        if dataManager == nil {
            let swiftDataManager = SwiftDataManager(modelContext: modelContext)
            dataManager = swiftDataManager
            profileManager.configure(with: swiftDataManager)
            fridgeManager = FridgeManager(modelContext: modelContext)
        }
    }

    private func handleSignupCompletion(email: String, password: String, profile: UserProfile) {
        profileManager.createProfileFromSignup(
            email: email,
            password: password,
            profile: profile
        )
        isPresentingSignup = false
        isAuthenticated = true
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Recipe.self, RecipeFolder.self, UserProfile.self], inMemory: true)
}
