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
        Group {
            if isAuthenticated {
                NavigationSplitView {
                    List {
                        ForEach(items) { item in
                            NavigationLink {
                                Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                            } label: {
                                Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                        }
                        ToolbarItem {
                            Button(action: addItem) {
                                Label("Add Item", systemImage: "plus")
                            }
                        }
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Déconnexion") { isAuthenticated = false }
                        }
                    }
                } detail: {
                    Text("Select an item")
                }
            } else {
                LoginView(isAuthenticated: $isAuthenticated, onSignup: { isPresentingSignup = true })
                    .frame(maxHeight: 500, alignment: .top)
                    .padding(.top, 40)
                    .sheet(isPresented: $isPresentingSignup) {
                        SignupFlowView { email, password, prefs in
                            // TODO: Persister l’utilisateur si nécessaire
                            isAuthenticated = true
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
