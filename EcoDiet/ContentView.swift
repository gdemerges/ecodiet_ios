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
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        ZStack {
            Group {
                if isAuthenticated {
                    NavigationStack {
                        HomeView()
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    Button("Déconnexion") { isAuthenticated = false }
                                }
                            }
                    }
                } else {
                    LoginView(isAuthenticated: $isAuthenticated, onSignup: { isPresentingSignup = true })
                        .sheet(isPresented: $isPresentingSignup) {
                            SignupFlowView { email, password, prefs in
                                // TODO: Persister l’utilisateur si nécessaire
                                isAuthenticated = true
                            }
                            .presentationBackground(.clear)
                        }
                }
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
