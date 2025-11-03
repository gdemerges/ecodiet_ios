//
//  ContentView.swift
//  EcoDiet
//
//  Created by Guillaume Demergès on 30/10/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var isPresentingSignup = false
    @State private var profileManager = UserProfileManager()
    @State private var dataManager: SwiftDataManager?
    
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ZStack {
            Group {
                if let _ = dataManager {
                    if isAuthenticated {
                        NavigationStack {
                            HomeView(dataManager: dataManager!, profileManager: profileManager)
                                .toolbar {
                                    ToolbarItem(placement: .topBarLeading) {
                                        Button("Déconnexion") {
                                            isAuthenticated = false
                                            // Les données restent persistantes avec SwiftData
                                        }
                                    }
                                }
                        }
                    } else {
                        LoginView(
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

