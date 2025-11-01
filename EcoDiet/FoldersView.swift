import SwiftUI

struct FoldersView: View {
    let dataManager: RecipeDataManager
    @State private var showingAddFolder = false
    @State private var newFolderTitle = ""
    @State private var selectedIcon = "folder"
    
    private let availableIcons = [
        "folder", "folder.fill", "figure.run", "snowflake", "leaf.fill",
        "flame", "moon.stars", "sun.max", "heart.fill", "star.fill"
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dataManager.folders) { folder in
                    NavigationLink {
                        FolderDetailView(folder: folder, dataManager: dataManager)
                    } label: {
                        HStack {
                            Image(systemName: folder.imageName)
                                .font(.title2)
                                .foregroundStyle(.secondary)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading) {
                                Text(folder.title)
                                    .font(.headline)
                                Text("\(folder.recipes.count) recette\(folder.recipes.count > 1 ? "s" : "")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteFolder)
            }
            .navigationTitle("Mes dossiers")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddFolder = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFolder) {
                NavigationStack {
                    Form {
                        Section("Informations du dossier") {
                            TextField("Nom du dossier", text: $newFolderTitle)
                            
                            Picker("Icône", selection: $selectedIcon) {
                                ForEach(availableIcons, id: \.self) { icon in
                                    HStack {
                                        Image(systemName: icon)
                                        Text(icon)
                                    }
                                    .tag(icon)
                                }
                            }
                        }
                    }
                    .navigationTitle("Nouveau dossier")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Annuler") {
                                showingAddFolder = false
                                resetForm()
                            }
                        }
                        
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Créer") {
                                addFolder()
                            }
                            .disabled(newFolderTitle.isEmpty)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    private func addFolder() {
        let newFolder = RecipeFolder(
            title: newFolderTitle,
            recipes: [],
            imageName: selectedIcon
        )
        dataManager.addFolder(newFolder)
        showingAddFolder = false
        resetForm()
    }
    
    private func deleteFolder(at offsets: IndexSet) {
        dataManager.deleteFolder(at: offsets)
    }
    
    private func resetForm() {
        newFolderTitle = ""
        selectedIcon = "folder"
    }
}

#Preview {
    let sampleDataManager = RecipeDataManager()
    
    return FoldersView(dataManager: sampleDataManager)
}